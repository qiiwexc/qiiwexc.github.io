BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\Configuration\Helpers\Add-SysPrepConfig.ps1'
    . '.\src\4-functions\Configuration\Helpers\Get-UsersRegistryKeys.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_PRIVACY ([String]'TEST_CONFIG_PRIVACY')

    Set-Variable -Option Constant TestSysPrepConfig ([String]'TEST_SYSPREP_CONFIG')
    Set-Variable -Option Constant TestUsers ([String[]]@('TEST_USER_1', 'TEST_USER_2'))
}

Describe 'Set-PrivacyConfiguration' {
    BeforeEach {
        Mock Disable-ScheduledTask {}
        Mock Out-Failure {}
        Mock Add-SysPrepConfig { return $TestSysPrepConfig }
        Mock Get-UsersRegistryKeys { return $TestUsers }
        Mock Import-RegistryConfiguration {}
        Mock Out-Success {}
    }

    It 'Should apply Windows privacy configuration' {
        Set-PrivacyConfiguration

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
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 1 -ParameterFilter { $Config -eq $CONFIG_PRIVACY }
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq 'Windows Privacy Config' -and
            $Content -match $TestSysPrepConfig -and
            $Content -match "`n\[HKEY_USERS\\$($TestUsers[0])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\Main\]`n" -and
            $Content -match "`n\[HKEY_USERS\\$($TestUsers[1])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\Main\]`n" -and
            $Content -match "`"DoNotTrack`"=dword:00000001`n"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip user registry keys if none found' {
        Mock Get-UsersRegistryKeys { return @() }

        Set-PrivacyConfiguration

        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $Content -match $TestSysPrepConfig -and
            $Content -notmatch "`n\[HKEY_USERS\\$($TestUsers[0])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\Main\]`n" -and
            $Content -notmatch "`n\[HKEY_USERS\\$($TestUsers[1])_Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppContainer\\Storage\\microsoft\.microsoftedge_8wekyb3d8bbwe\\MicrosoftEdge\\Main\]`n" -and
            $Content -notmatch "`"DoNotTrack`"=dword:00000001`n"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Disable-ScheduledTask failure' {
        Mock Disable-ScheduledTask { throw $TestException }

        Set-PrivacyConfiguration

        Should -Invoke Disable-ScheduledTask -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-UsersRegistryKeys failure' {
        Mock Get-UsersRegistryKeys { throw $TestException }

        Set-PrivacyConfiguration

        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-PrivacyConfiguration

        Should -Invoke Disable-ScheduledTask -Exactly 10
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Get-UsersRegistryKeys -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
