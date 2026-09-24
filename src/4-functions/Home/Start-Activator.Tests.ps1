BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\Common\Find-RunningScript.ps1"
    . "$PSScriptRoot\..\Common\Network.ps1"
    . "$PSScriptRoot\..\Common\Start-Download.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_SYSTEM_32 ([String]'TEST_SYSTEM_32')

    Set-Variable -Option Constant TestDownloadPath ([String]'C:\Users\TEST_USER\AppData\Local\Temp\qiiwexc\MAS_AIO.cmd')
    Set-Variable -Option Constant TestScriptPattern ([String]"$env:SystemRoot\Temp\MAS_*.cmd")
}

Describe 'Start-Activator' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Find-RunningScript {}
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock Start-Download { return $TestDownloadPath }
        Mock Copy-Item { $script:CopiedTo = $Destination }
        Mock Test-FileChecksum {}
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    BeforeEach {
        $script:CopiedTo = $Null
    }

    It 'Should run a checked copy of the pinned release from the system temp folder' {
        Start-Activator

        Should -Invoke Find-RunningScript -Exactly 1
        Should -Invoke Find-RunningScript -Exactly 1 -ParameterFilter { $CommandLinePart -eq '\Temp\MAS_' }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Start-Download -Exactly 1 -ParameterFilter {
            $URL -eq '{URL_MICROSOFT_ACTIVATION_SCRIPTS}' -and
            $Sha256 -eq '{SHA256_MICROSOFT_ACTIVATION_SCRIPTS}' -and
            $Temp -eq $True
        }
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Copy-Item -Exactly 1 -ParameterFilter {
            $LiteralPath -eq $TestDownloadPath -and
            $Destination -like $TestScriptPattern
        }
        Should -Invoke Test-FileChecksum -Exactly 1
        Should -Invoke Test-FileChecksum -Exactly 1 -ParameterFilter {
            $Path -eq $script:CopiedTo -and
            $Sha256 -eq '{SHA256_MICROSOFT_ACTIVATION_SCRIPTS}'
        }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq "$PATH_SYSTEM_32\cmd.exe" -and
            $ArgumentList -eq "/c `"`"$script:CopiedTo`" -el`""
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should run each time under a new name' {
        Start-Activator
        Set-Variable -Option Constant FirstPath ([String]$script:CopiedTo)

        Start-Activator

        $script:CopiedTo | Should -Not -Be $FirstPath
    }

    It 'Should automatically activate Windows' {
        Start-Activator -ActivateWindows

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq "/c `"`"$script:CopiedTo`" -el /HWID`"" }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should automatically activate Office' {
        Start-Activator -ActivateOffice

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq "/c `"`"$script:CopiedTo`" -el /Ohook`"" }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should automatically activate both Windows and Office' {
        Start-Activator -ActivateWindows -ActivateOffice

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq "/c `"`"$script:CopiedTo`" -el /HWID /Ohook`"" }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if already running' {
        Mock Find-RunningScript { return @(@{ ProcessName = 'cmd' }) }

        Start-Activator

        Should -Invoke Find-RunningScript -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Start-Activator

        Should -Invoke Find-RunningScript -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Find-RunningScript failure' {
        Mock Find-RunningScript { throw $TestException }

        Start-Activator

        Should -Invoke Find-RunningScript -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        Start-Activator

        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should not run anything if the download fails' {
        Mock Start-Download { throw $TestException }

        Start-Activator

        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should not run anything if the copy fails' {
        Mock Copy-Item { throw $TestException }

        Start-Activator

        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Test-FileChecksum -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should not run a copy that does not match the checksum' {
        Mock Test-FileChecksum { throw $TestException }

        Start-Activator

        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Test-FileChecksum -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        Start-Activator

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
