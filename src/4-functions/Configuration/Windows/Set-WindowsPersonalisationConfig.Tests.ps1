BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\logger.ps1'
    . '.\src\4-functions\Common\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Helpers\Get-UsersRegistryKeys.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER ([String]"[HKEY_CURRENT_USER\Test]`nTEST_CONFIG_WINDOWS_PERSONALISATION")
    Set-Variable -Option Constant CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE ([String]'TEST_CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE')

    Set-Variable -Option Constant TestUsers ([String[]]@('TEST_USER_1', 'TEST_USER_2'))
    Set-Variable -Option Constant TestNotificationRegistries (
        [PSCustomObject[]]@(
            @{Name = 'TEST_NOTIFICATION_REGISTRY_1' },
            @{Name = 'TEST_NOTIFICATION_REGISTRY_2' }
        )
    )
}

Describe 'Set-WindowsPersonalisationConfig' {
    BeforeEach {
        Set-Variable -Option Constant TestLanguageList (
            [Collections.Generic.List[PSCustomObject]]@(
                @{LanguageTag = 'en' },
                @{LanguageTag = 'ru' }
            )
        )

        Mock Write-ActivityProgress {}
        Mock Set-WinHomeLocation {}
        Mock Out-Success {}
        Mock Out-Failure {}
        Mock Get-WinUserLanguageList { return $TestLanguageList }
        Mock Set-WinUserLanguageList {}
        Mock Get-Item { return $TestNotificationRegistries }
        Mock Get-UsersRegistryKeys { return $TestUsers }
        Mock Import-RegistryConfiguration {}

        [Int]$OS_VERSION = 11
    }

    It 'Should apply Windows personalisation configuration' {
        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Set-WinHomeLocation -Exactly 1 -ParameterFilter { $GeoId -eq 140 }
        # Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Success -Exactly 3
        # Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq 'HKCU:\Control Panel\NotifyIconSettings\*' }
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq 'Windows Personalisation Config' -and
            $Content -match "\[HKEY_USERS\\\.DEFAULT\\Test\]`nTEST_CONFIG_WINDOWS_PERSONALISATION" -and
            $Content -match "\[HKEY_CURRENT_USER\\Test\]`nTEST_CONFIG_WINDOWS_PERSONALISATION" -and
            $Content -match $CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE -and
            $Content -match "`n\[$($TestNotificationRegistries[0].Name)\]`n" -and
            $Content -match "`n\[$($TestNotificationRegistries[1].Name)\]`n" -and
            $Content -match "`"IsPromoted`"=dword:00000001`n" -and
            $Content -match "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\Creative\\$($TestUsers[0])\]`n" -and
            $Content -match "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\Creative\\$($TestUsers[1])\]`n" -and
            $Content -match "`"RotatingLockScreenEnabled`"=dword:00000001`n"
        }
    }

    It 'Should skip notification configuration on Windows older than 11' {
        [Int]$OS_VERSION = 10

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        # Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Success -Exactly 3
        # Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 0
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $Content -match $CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE -and
            $Content -notmatch "`n\[$($TestNotificationRegistries[0].Name)\]`n" -and
            $Content -notmatch "`n\[$($TestNotificationRegistries[1].Name)\]`n" -and
            $Content -notmatch "`"IsPromoted`"=dword:00000001`n"
        }
    }

    It 'Should skip setting Latvian language if already present' {
        Mock Get-WinUserLanguageList { return ([Collections.Generic.List[PSCustomObject]](@(@{LanguageTag = 'lv' }))) }

        Mock Get-ScheduledTask { return @() }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 3
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Out-Success -Exactly 3
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should skip notification registry keys if none found' {
        Mock Get-Item { return @() }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        # Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Success -Exactly 3
        # Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should skip user registry keys if none found' {
        Mock Get-UsersRegistryKeys { return @() }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        # Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Success -Exactly 3
        # Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Set-WinHomeLocation failure' {
        Mock Set-WinHomeLocation { throw $TestException }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        # Should -Invoke Out-Success -Exactly 3
        Should -Invoke Out-Success -Exactly 2
        # Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 2
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Get-WinUserLanguageList failure' {
        Mock Get-WinUserLanguageList { throw $TestException }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 3
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Out-Success -Exactly 3
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Set-WinUserLanguageList failure' {
        Mock Set-WinUserLanguageList { throw $TestException }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Out-Success -Exactly 3
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Get-Item failure' {
        Mock Get-Item { throw $TestException }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        # Should -Invoke Out-Success -Exactly 3
        Should -Invoke Out-Success -Exactly 2
        # Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 2
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Get-UsersRegistryKeys failure' {
        Mock Get-UsersRegistryKeys { throw $TestException }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        # Should -Invoke Out-Success -Exactly 3
        Should -Invoke Out-Success -Exactly 2
        # Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 2
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-WindowsPersonalisationConfig

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Set-WinHomeLocation -Exactly 1
        # Should -Invoke Out-Success -Exactly 3
        Should -Invoke Out-Success -Exactly 2
        # Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 2
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        # Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }
}
