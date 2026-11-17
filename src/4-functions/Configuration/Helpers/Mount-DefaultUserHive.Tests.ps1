BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\Invoke-RegCommand.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
    Set-Variable -Option Constant TestProfilePath ([String]'D:\Users\Default')
}

Describe 'Mount-DefaultUserHive' {
    BeforeAll {
        Mock Get-ItemProperty { return [PSCustomObject]@{ Default = $TestProfilePath } }
        Mock Invoke-RegCommand { return 0 }
        Mock Write-LogDebug {}
        Mock Write-LogWarning {}
    }

    It 'Should load the default user profile from where Windows keeps it' {
        Mount-DefaultUserHive | Should -BeExactly $True

        Should -Invoke Get-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -and
            $Name -eq 'Default'
        }
        Should -Invoke Invoke-RegCommand -Exactly 1
        Should -Invoke Invoke-RegCommand -Exactly 1 -ParameterFilter {
            ($Arguments -join ' ') -eq "load HKU\DefaultUser `"$TestProfilePath\NTUSER.DAT`""
        }
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should warn and report that nothing was loaded when reg.exe fails' {
        Mock Invoke-RegCommand { return 1 }

        Mount-DefaultUserHive | Should -BeExactly $False

        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -match 'reg\.exe exited with code 1' }
    }

    It 'Should warn and report that nothing was loaded when the profile path cannot be read' {
        Mock Get-ItemProperty { throw $TestException }

        Mount-DefaultUserHive | Should -BeExactly $False

        Should -Invoke Invoke-RegCommand -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -match $TestException }
    }

    It 'Should warn and report that nothing was loaded when reg.exe cannot be started' {
        Mock Invoke-RegCommand { throw $TestException }

        Mount-DefaultUserHive | Should -BeExactly $False

        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -match $TestException }
    }
}
