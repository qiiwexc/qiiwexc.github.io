BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\App lifecycle\Get-SignedInUser.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestUrl ([String]'https://TEST_URL/?select=a-b&c=d')
    Set-Variable -Option Constant TestFile ([String]'C:\TEST DIR\TEST_FILE.html')

    Set-Variable -Option Constant TestSessionId ([Int][Diagnostics.Process]::GetCurrentProcess().SessionId)
    Set-Variable -Option Constant TestAppUser ([String][Security.Principal.WindowsIdentity]::GetCurrent().Name)
    Set-Variable -Option Constant TestExplorer ([String]"$env:SystemRoot\explorer.exe")
}

Describe 'Start-FromShell' {
    BeforeAll {
        # Another user's shell in another session, and the one in this session
        Mock Get-Process { return @([PSCustomObject]@{ SessionId = $TestSessionId + 1 }, [PSCustomObject]@{ SessionId = $TestSessionId }) }
        Mock Get-SignedInUser { return $TestAppUser }
        Mock Start-Process {}
        Mock Write-LogDebug {}
    }

    It 'Should hand a URL to the shell of this session' {
        Start-FromShell $TestUrl

        Should -Invoke Get-Process -Exactly 1
        Should -Invoke Get-Process -Exactly 1 -ParameterFilter { $Name -eq 'explorer' }
        # A URL is the same for every account, so whose shell it is does not matter
        Should -Invoke Get-SignedInUser -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExplorer -and
            $ArgumentList -eq "`"$TestUrl`""
        }
        Should -Invoke Write-LogDebug -Exactly 0
    }

    It 'Should start a URL directly when no shell runs in this session: <Case>' -ForEach @(
        @{ Case = 'only in another session'; Shells = @(@{ SessionId = 1 }) }
        @{ Case = 'none at all'; Shells = @() }
    ) {
        Mock Get-Process { return @($Shells | ForEach-Object { [PSCustomObject]@{ SessionId = $TestSessionId + $_.SessionId } }) }

        Start-FromShell $TestUrl

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestUrl -and
            -not $PesterBoundParameters.ContainsKey('ArgumentList')
        }
        Should -Invoke Write-LogDebug -Exactly 1
    }

    It 'Should hand a local file to the shell when the app runs as the signed-in user' {
        Start-FromShell $TestFile

        Should -Invoke Get-SignedInUser -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExplorer -and
            $ArgumentList -eq "`"$TestFile`""
        }
    }

    It 'Should start a local file as the app''s own account when <Case>' -ForEach @(
        @{ Case = 'the signed-in user is someone else'; SignedInUser = 'TEST_DOMAIN\TEST_OTHER_USER' }
        @{ Case = 'the signed-in user cannot be told'; SignedInUser = '' }
    ) {
        Mock Get-SignedInUser { return $SignedInUser }

        Start-FromShell $TestFile

        Should -Invoke Get-SignedInUser -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestFile -and
            -not $PesterBoundParameters.ContainsKey('ArgumentList')
        }
        Should -Invoke Write-LogDebug -Exactly 1
    }

    It 'Should not ask whose shell it is when there is none' {
        Mock Get-Process {}

        Start-FromShell $TestFile

        Should -Invoke Get-SignedInUser -Exactly 0
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestFile }
    }

    It 'Should let a failure to start reach the caller' {
        Mock Start-Process { throw $TestException }

        { Start-FromShell $TestUrl } | Should -Throw $TestException
    }
}
