BeforeAll {
    # Untyped stubs so Pester can mock Windows-only commands on any host —
    # mocks and ParameterFilters bind against these simple parameters on every platform
    function Get-ScheduledTask { [CmdletBinding()] param([String]$TaskName, [String]$TaskPath) }
    function Disable-ScheduledTask { [CmdletBinding()] param([String]$TaskName, [String]$TaskPath) }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\Helpers\Add-SysPrepConfig.ps1"
    . "$PSScriptRoot\..\Helpers\Import-RegistryConfiguration.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_PRIVACY ([String]"[HKEY_LOCAL_MACHINE\TEST_MACHINE_KEY]`n`"TEST_VALUE`"=dword:00000001`n`n[HKEY_CURRENT_USER\TEST_USER_KEY]`n`"TEST_VALUE`"=dword:00000001`n")
}

Describe 'Set-PrivacyConfiguration' {
    BeforeAll {
        Mock Get-ScheduledTask { return [PSCustomObject]@{ TaskName = $TaskName } }
        Mock Disable-ScheduledTask {}
        Mock Write-LogDebug {}
        Mock Out-Failure {}
        Mock Import-RegistryConfiguration {}
        Mock Out-Success {}
    }

    It 'Should apply Windows privacy configuration' {
        Set-PrivacyConfiguration

        Should -Invoke Disable-ScheduledTask -Exactly 5
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'DmClient' -and
            $TaskPath -eq '\Microsoft\Windows\Feedback\Siuf\'
        }
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'DmClientOnScenarioDownload' -and
            $TaskPath -eq '\Microsoft\Windows\Feedback\Siuf\'
        }
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'PcaPatchDbTask' -and
            $TaskPath -eq '\Microsoft\Windows\Application Experience\'
        }
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'QueueReporting' -and
            $TaskPath -eq '\Microsoft\Windows\Windows Error Reporting\'
        }
        Should -Invoke Disable-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'MareBackup' -and
            $TaskPath -eq '\Microsoft\Windows\Application Experience\'
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            [String]$Keys = -join $Content
            $AppName -eq 'Windows Privacy Config' -and
            $Keys.Contains('[HKEY_LOCAL_MACHINE\TEST_MACHINE_KEY]') -and
            $Keys.Contains('[HKEY_CURRENT_USER\TEST_USER_KEY]') -and
            $Keys.Contains('[HKEY_USERS\.DEFAULT\TEST_USER_KEY]')
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip a task this system does not have without reporting a failure' {
        Mock Get-ScheduledTask {} -ParameterFilter { $TaskName -eq 'MareBackup' }

        Set-PrivacyConfiguration

        Should -Invoke Get-ScheduledTask -Exactly 5
        Should -Invoke Get-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq 'MareBackup' -and
            $TaskPath -eq '\Microsoft\Windows\Application Experience\' -and
            $ErrorAction -eq 'SilentlyContinue'
        }
        Should -Invoke Disable-ScheduledTask -Exactly 4
        Should -Invoke Disable-ScheduledTask -Exactly 0 -ParameterFilter { $TaskName -eq 'MareBackup' }
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1 -ParameterFilter { $Message -match 'MareBackup' }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should continue with the remaining tasks when one cannot be disabled' {
        Mock Disable-ScheduledTask { throw $TestException } -ParameterFilter { $TaskName -eq 'PcaPatchDbTask' }

        Set-PrivacyConfiguration

        Should -Invoke Disable-ScheduledTask -Exactly 5
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match 'PcaPatchDbTask' }
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Disable-ScheduledTask failure' {
        Mock Disable-ScheduledTask { throw $TestException }

        Set-PrivacyConfiguration

        Should -Invoke Disable-ScheduledTask -Exactly 5
        Should -Invoke Out-Failure -Exactly 5
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-PrivacyConfiguration

        Should -Invoke Disable-ScheduledTask -Exactly 5
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match $TestException }
        Should -Invoke Out-Success -Exactly 0
    }
}
