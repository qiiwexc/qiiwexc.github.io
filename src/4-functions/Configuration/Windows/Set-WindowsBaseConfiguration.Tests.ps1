BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\logger.ps1'
    . '.\src\4-functions\Common\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Helpers\Get-UsersRegistryKeys.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-WindowsSecurityConfiguration.ps1'
    . '.\src\4-functions\Configuration\Windows\Set-PowerSchemeConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_WINDOWS_RUSSIAN ([String]"[HKEY_CURRENT_USER\Test]`nTEST_CONFIG_WINDOWS_RUSSIAN")
    Set-Variable -Option Constant CONFIG_WINDOWS_ENGLISH ([String]"[HKEY_CURRENT_USER\Test]`nTEST_CONFIG_WINDOWS_ENGLISH")
    Set-Variable -Option Constant CONFIG_WINDOWS_HKEY_CURRENT_USER ([String]"[HKEY_CURRENT_USER\Test]`nTEST_CONFIG_WINDOWS_HKEY_CURRENT")
    Set-Variable -Option Constant CONFIG_WINDOWS_HKEY_LOCAL_MACHINE ([String]'TEST_CONFIG_WINDOWS_HKEY_LOCAL_MACHINE')

    Set-Variable -Option Constant TestInternationalKey ([String]'HKCU:\Control Panel\International')
    Set-Variable -Option Constant TestTimeZoneKey ([String]'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate')

    Set-Variable -Option Constant TestUnelevatedExplorerTaskName ([String]'CreateExplorerShellUnelevatedTask')
    Set-Variable -Option Constant TestScheduledTask ([PSCustomObject[]]@(@{ TaskName = $TestUnelevatedExplorerTaskName }))

    Set-Variable -Option Constant TestUsers ([String[]]@('TEST_USER_1', 'TEST_USER_2'))
    Set-Variable -Option Constant TestVolumes (
        [PSCustomObject[]]@(
            @{Name = 'TEST_VOLUME_1' },
            @{Name = 'TEST_VOLUME_2' }
        )
    )
}

Describe 'Set-WindowsBaseConfiguration' {
    BeforeEach {
        Mock Set-WindowsSecurityConfiguration {}
        Mock Set-PowerSchemeConfiguration {}
        Mock Write-ActivityProgress {}
        Mock Set-ItemProperty {} -ParameterFilter { $Path -eq $TestInternationalKey }
        Mock Set-ItemProperty {} -ParameterFilter { $Path -eq $TestTimeZoneKey }
        Mock Out-Success {}
        Mock Out-Failure {}
        Mock Get-ScheduledTask { return $TestScheduledTask }
        Mock Unregister-ScheduledTask {}
        Mock Disable-ScheduledTask {}
        Mock Get-UsersRegistryKeys { return $TestUsers }
        Mock Get-Item { return $TestVolumes }
        Mock Import-RegistryConfiguration {}

        [String]$SYSTEM_LANGUAGE = 'en-GB'
    }

    It 'Should apply English Windows base configuration' {
        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Set-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq $TestInternationalKey -and
            $Name -eq 'sCurrency' -and
            $Value -eq ([Char]0x20AC)
        }
        Should -Invoke Set-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq $TestTimeZoneKey -and
            $Name -eq 'Start' -and
            $Value -eq 3
        }
        Should -Invoke Out-Success -Exactly 5
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq $TestUnelevatedExplorerTaskName -and
            $Confirm -eq $False
        }
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'Consolidator' -and
            $TaskPath -eq 'Microsoft\Windows\Customer Experience Improvement Program'
        }
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'DmClient' -and
            $TaskPath -eq 'Microsoft\Windows\Feedback\Siuf'
        }
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'StartupAppTask' -and
            $TaskPath -eq 'Microsoft\Windows\Application Experience'
        }
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'Microsoft-Windows-DiskDiagnosticDataCollector' -and
            $TaskPath -eq 'Microsoft\Windows\DiskDiagnostic'
        }
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*' }
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq 'Windows Base Config' -and
            $Content -match "\[HKEY_USERS\\\.DEFAULT\\Test\]`nTEST_CONFIG_WINDOWS_HKEY_CURRENT" -and
            $Content -match "\[HKEY_CURRENT_USER\\Test\]`nTEST_CONFIG_WINDOWS_HKEY_CURRENT" -and
            $Content -match $CONFIG_WINDOWS_HKEY_LOCAL_MACHINE -and
            $Content -match "\[HKEY_USERS\\\.DEFAULT\\Test\]`nTEST_CONFIG_WINDOWS_ENGLISH" -and
            $Content -match "\[HKEY_CURRENT_USER\\Test\]`nTEST_CONFIG_WINDOWS_ENGLISH" -and
            $Content -match "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\Creative\\$($TestUsers[0])\]`n" -and
            $Content -match "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\Creative\\$($TestUsers[1])\]`n" -and
            $Content -match "`"RotatingLockScreenOverlayEnabled`"=dword:00000000`n" -and
            $Content -match "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\InstallService\\Stubification\\$($TestUsers[0])\]`n" -and
            $Content -match "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\InstallService\\Stubification\\$($TestUsers[1])\]`n" -and
            $Content -match "`"EnableAppOffloading`"=dword:00000000`n" -and
            $Content -match "`n\[HKEY_USERS\\$($TestUsers[0])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\Main\]`n" -and
            $Content -match "`n\[HKEY_USERS\\$($TestUsers[1])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\Main\]`n" -and
            $Content -match "`"DoNotTrack`"=dword:00000001`n" -and
            $Content -match "`n\[HKEY_USERS\\$($TestUsers[0])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\ServiceUI\]`n" -and
            $Content -match "`n\[HKEY_USERS\\$($TestUsers[1])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\ServiceUI\]`n" -and
            $Content -match "`"EnableCortana`"=dword:00000000`n" -and
            $Content -match "`n\[$($TestVolumes[0].Name)\]`n" -and
            $Content -match "`n\[$($TestVolumes[1].Name)\]`n" -and
            $Content -match "`"MaxCapacity`"=dword:000FFFFF`n"
        }
    }

    It 'Should apply Russian Windows base configuration' {
        [String]$SYSTEM_LANGUAGE = 'ru-RU'

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 5
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $Content -match "\[HKEY_USERS\\\.DEFAULT\\Test\]`nTEST_CONFIG_WINDOWS_RUSSIAN" -and
            $Content -match "\[HKEY_CURRENT_USER\\Test\]`nTEST_CONFIG_WINDOWS_RUSSIAN"
        }
    }

    It 'Should skip removing unelevated Explorer scheduled task if not present' {
        Mock Get-ScheduledTask { return @() }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 5
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 0
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should skip user registry keys if none found' {
        Mock Get-UsersRegistryKeys { return @() }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 5
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $Content -match $CONFIG_WINDOWS_HKEY_LOCAL_MACHINE -and
            $Content -notmatch "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\Creative\\$($TestUsers[0])\]`n" -and
            $Content -notmatch "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI\\Creative\\$($TestUsers[1])\]`n" -and
            $Content -notmatch "`"RotatingLockScreenOverlayEnabled`"=dword:00000000`n" -and
            $Content -notmatch "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\InstallService\\Stubification\\$($TestUsers[0])\]`n" -and
            $Content -notmatch "`n\[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\InstallService\\Stubification\\$($TestUsers[1])\]`n" -and
            $Content -notmatch "`"EnableAppOffloading`"=dword:00000000`n" -and
            $Content -notmatch "`n\[HKEY_USERS\\$($TestUsers[0])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\Main\]`n" -and
            $Content -notmatch "`n\[HKEY_USERS\\$($TestUsers[1])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\Main\]`n" -and
            $Content -notmatch "`"DoNotTrack`"=dword:00000001`n" -and
            $Content -notmatch "`n\[HKEY_USERS\\$($TestUsers[0])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\ServiceUI\]`n" -and
            $Content -notmatch "`n\[HKEY_USERS\\$($TestUsers[1])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\ServiceUI\]`n" -and
            $Content -notmatch "`"EnableCortana`"=dword:00000000`n"
        }
    }

    It 'Should skip volume registries if none found' {
        Mock Get-Item { return @() }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 5
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $Content -match $CONFIG_WINDOWS_HKEY_LOCAL_MACHINE -and
            $Content -notmatch "`n\[$($TestVolumes[0].Name)\]`n" -and
            $Content -notmatch "`n\[$($TestVolumes[1].Name)\]`n" -and
            $Content -notmatch "`"MaxCapacity`"=dword:000FFFFF`n"
        }
    }

    It 'Should handle Set-WindowsSecurityConfiguration failure' {
        Mock Set-WindowsSecurityConfiguration { throw $TestException }

        { Set-WindowsBaseConfiguration } | Should -Throw $TestException

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 0
        Should -Invoke Write-ActivityProgress -Exactly 0
        Should -Invoke Set-ItemProperty -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 0
        Should -Invoke Unregister-ScheduledTask -Exactly 0
        Should -Invoke Disable-ScheduledTask -Exactly 0
        Should -Invoke Get-UsersRegistryKeys -Exactly 0
        Should -Invoke Get-Item -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 0
    }

    It 'Should handle Set-PowerSchemeConfiguration failure' {
        Mock Set-PowerSchemeConfiguration { throw $TestException }

        { Set-WindowsBaseConfiguration } | Should -Throw $TestException

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 0
        Should -Invoke Set-ItemProperty -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 0
        Should -Invoke Unregister-ScheduledTask -Exactly 0
        Should -Invoke Disable-ScheduledTask -Exactly 0
        Should -Invoke Get-UsersRegistryKeys -Exactly 0
        Should -Invoke Get-Item -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 0
    }

    It 'Should handle Set-ItemProperty (currency symbol) failure' {
        Mock Set-ItemProperty { throw $TestException } -ParameterFilter { $Path -eq $TestInternationalKey }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Set-ItemProperty (timezone auto update) failure' {
        Mock Set-ItemProperty { throw $TestException } -ParameterFilter { $Path -eq $TestTimeZoneKey }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Get-ScheduledTask failure' {
        Mock Get-ScheduledTask { throw $TestException }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 5
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 0
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Unregister-ScheduledTask failure' {
        Mock Unregister-ScheduledTask { throw $TestException }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 5
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Disable-ScheduledTask failure' {
        Mock Disable-ScheduledTask { throw $TestException }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Get-UsersRegistryKeys failure' {
        Mock Get-UsersRegistryKeys { throw $TestException }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Get-Item failure' {
        Mock Get-Item { throw $TestException }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-WindowsBaseConfiguration

        Should -Invoke Set-WindowsSecurityConfiguration -Exactly 1
        Should -Invoke Set-PowerSchemeConfiguration -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Set-ItemProperty -Exactly 2
        Should -Invoke Out-Success -Exactly 4
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
    }
}
