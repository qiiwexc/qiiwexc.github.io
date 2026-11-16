BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\Helpers\Add-SysPrepConfig.ps1"
    . "$PSScriptRoot\..\Helpers\Import-RegistryConfiguration.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_SECURITY ([String]"[HKEY_LOCAL_MACHINE\TEST_MACHINE_KEY]`n`"TEST_VALUE`"=dword:00000001`n`n[HKEY_CURRENT_USER\TEST_USER_KEY]`n`"TEST_VALUE`"=dword:00000001`n")
}

Describe 'Set-SecurityConfiguration' {
    BeforeAll {
        Mock Import-RegistryConfiguration {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should import the security configuration for the machine, the current user and the default user' {
        Set-SecurityConfiguration

        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            [String]$Keys = -join $Content
            $AppName -eq 'Windows Security Config' -and
            $Keys.Contains('[HKEY_LOCAL_MACHINE\TEST_MACHINE_KEY]') -and
            $Keys.Contains('[HKEY_CURRENT_USER\TEST_USER_KEY]') -and
            $Keys.Contains('[HKEY_USERS\.DEFAULT\TEST_USER_KEY]')
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should report a failed import' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-SecurityConfiguration

        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match $TestException }
    }
}
