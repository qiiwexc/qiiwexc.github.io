BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\Configuration\Helpers\Add-SysPrepConfig.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_BASELINE_RUSSIAN ([String]'TEST_CONFIG_BASELINE_RUSSIAN')
    Set-Variable -Option Constant CONFIG_BASELINE_ENGLISH ([String]'TEST_CONFIG_BASELINE_ENGLISH')
    Set-Variable -Option Constant CONFIG_BASELINE ([String]'TEST_CONFIG_BASELINE')

    Set-Variable -Option Constant TestUnelevatedExplorerTaskName ([String]'CreateExplorerShellUnelevatedTask')
    Set-Variable -Option Constant TestScheduledTask ([PSObject[]]@(@{ TaskName = $TestUnelevatedExplorerTaskName }))

    Set-Variable -Option Constant TestSysPrepConfig ([String]'TEST_SYSPREP_CONFIG')
    Set-Variable -Option Constant TestVolumes (
        [PSObject[]]@(
            @{Name = 'TEST_VOLUME_1' },
            @{Name = 'TEST_VOLUME_2' }
        )
    )
}

Describe 'Set-BaselineConfiguration' {
    BeforeEach {
        Mock Set-ItemProperty {}
        Mock Out-Success {}
        Mock Out-Failure {}
        Mock Get-ScheduledTask { return $TestScheduledTask }
        Mock Unregister-ScheduledTask {}
        Mock Add-SysPrepConfig { return $TestSysPrepConfig }
        Mock Get-Item { return $TestVolumes }
        Mock Import-RegistryConfiguration {}

        [String]$SYSTEM_LANGUAGE = 'en-GB'
    }

    It 'Should apply English Windows baseline configuration' {
        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -and
            $Name -eq 'Start' -and
            $Value -eq 3
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1 -ParameterFilter {
            $TaskName -eq $TestUnelevatedExplorerTaskName -and
            $Confirm -eq $False
        }
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Add-SysPrepConfig -Exactly 1 -ParameterFilter { $Config -eq $CONFIG_BASELINE_ENGLISH }
        Should -Invoke Add-SysPrepConfig -Exactly 1 -ParameterFilter { $Config -eq $CONFIG_BASELINE }
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*' }
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq 'Windows Baseline Config' -and
            $Content -match $TestSysPrepConfig -and
            $Content -match "`n\[$($TestVolumes[0].Name)\]`n" -and
            $Content -match "`n\[$($TestVolumes[1].Name)\]`n" -and
            $Content -match "`"MaxCapacity`"=dword:000FFFFF`n"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should apply Russian Windows baseline configuration' {
        [String]$SYSTEM_LANGUAGE = 'ru-RU'

        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Add-SysPrepConfig -Exactly 1 -ParameterFilter { $Config -eq $CONFIG_BASELINE_RUSSIAN }
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip removing unelevated Explorer scheduled task if not present' {
        Mock Get-ScheduledTask { return @() }

        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 0
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip volume registries if none found' {
        Mock Get-Item { return @() }

        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $Content -match $TestSysPrepConfig -and
            $Content -notmatch "`n\[$($TestVolumes[0].Name)\]`n" -and
            $Content -notmatch "`n\[$($TestVolumes[1].Name)\]`n" -and
            $Content -notmatch "`"MaxCapacity`"=dword:000FFFFF`n"
            Should -Invoke Out-Success -Exactly 1
        }
    }

    It 'Should handle Set-ItemProperty failure' {
        Mock Set-ItemProperty { throw $TestException }

        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-ScheduledTask failure' {
        Mock Get-ScheduledTask { throw $TestException }

        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 0
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Unregister-ScheduledTask failure' {
        Mock Unregister-ScheduledTask { throw $TestException }

        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-Item failure' {
        Mock Get-Item { throw $TestException }

        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-BaselineConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-ScheduledTask -Exactly 1
        Should -Invoke Unregister-ScheduledTask -Exactly 1
        Should -Invoke Add-SysPrepConfig -Exactly 2
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
