BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\Configuration\Helpers\Add-SysPrepConfig.ps1'
    . '.\src\4-functions\Configuration\Helpers\Get-UsersRegistryKeys.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_PERSONALIZATION ([String]'TEST_CONFIG_PERSONALIZATION')

    Set-Variable -Option Constant TestSysPrepConfig ([String]'TEST_SYSPREP_CONFIG')
    Set-Variable -Option Constant TestUsers ([String[]]@('TEST_USER_1', 'TEST_USER_2'))
    Set-Variable -Option Constant TestNotificationRegistries (
        [PSObject[]]@(
            @{Name = 'TEST_NOTIFICATION_REGISTRY_1' },
            @{Name = 'TEST_NOTIFICATION_REGISTRY_2' }
        )
    )
}

Describe 'Set-PersonalizationConfiguration' {
    BeforeEach {
        Mock Add-SysPrepConfig { return $TestSysPrepConfig }
        Mock Get-Item { return $TestNotificationRegistries }
        Mock Out-Failure {}
        Mock Get-UsersRegistryKeys { return $TestUsers }
        Mock Import-RegistryConfiguration {}
        Mock Out-Success {}

        [Int]$OS_VERSION = 11
    }

    It 'Should apply Windows personalization configuration' {
        Set-PersonalizationConfiguration

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 1 -ParameterFilter { $Config -eq $CONFIG_PERSONALIZATION }
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq 'HKCU:\Control Panel\NotifyIconSettings\*' }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq 'Windows Personalization Config' -and
            $Content -match $TestSysPrepConfig -and
            $Content -match "`n\[$($TestNotificationRegistries[0].Name)\]`n" -and
            $Content -match "`n\[$($TestNotificationRegistries[1].Name)\]`n" -and
            $Content -match "`"IsPromoted`"=dword:00000001`n" -and
            $Content -match "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\Creative\\$($TestUsers[0])\]`n" -and
            $Content -match "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\Creative\\$($TestUsers[1])\]`n" -and
            $Content -match "`"RotatingLockScreenEnabled`"=dword:00000001`n"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip notification configuration on Windows older than 11' {
        [Int]$OS_VERSION = 10

        Set-PersonalizationConfiguration

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-Item -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $Content -match $TestSysPrepConfig -and
            $Content -notmatch "`n\[$($TestNotificationRegistries[0].Name)\]`n" -and
            $Content -notmatch "`n\[$($TestNotificationRegistries[1].Name)\]`n" -and
            $Content -notmatch "`"IsPromoted`"=dword:00000001`n"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip notification registry keys if none found' {
        Mock Get-Item { return @() }

        Set-PersonalizationConfiguration

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip user registry keys if none found' {
        Mock Get-UsersRegistryKeys { return @() }

        Set-PersonalizationConfiguration

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-Item failure' {
        Mock Get-Item { throw $TestException }

        Set-PersonalizationConfiguration

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-UsersRegistryKeys failure' {
        Mock Get-UsersRegistryKeys { throw $TestException }

        Set-PersonalizationConfiguration

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-PersonalizationConfiguration

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
