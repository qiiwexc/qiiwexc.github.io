BeforeAll {
    # Untyped stubs so Pester can mock Windows-only commands on any host —
    # mocks and ParameterFilters bind against these simple parameters on every platform
    function powercfg { }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\Helpers\Test-PowerSetting.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_POWER_SETTINGS (
        [Hashtable[]]@(
            @{SubGroup = 'SUB_PCIEXPRESS'; Setting = 'ASPM'; Value = 0 },
            @{SubGroup = 'SUB_PROCESSOR'; Setting = 'SYSCOOLPOL'; Value = 1 }
        )
    )
}

Describe 'Set-PowerSchemeConfiguration' {
    BeforeAll {
        Mock powercfg {}
        Mock Test-PowerSetting { return $True }
        Mock Write-LogDebug {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should set power scheme configuration' {
        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 5
        Should -Invoke powercfg -Exactly 1 -ParameterFilter {
            $args[0] -eq '/OverlaySetActive' -and
            $args[1] -eq 'OVERLAY_SCHEME_MAX'
        }
        Should -Invoke powercfg -Exactly 1 -ParameterFilter {
            $args[0] -eq '/SetAcValueIndex' -and
            $args[1] -eq 'SCHEME_ALL' -and
            $args[2] -eq $CONFIG_POWER_SETTINGS[0].SubGroup -and
            $args[3] -eq $CONFIG_POWER_SETTINGS[0].Setting -and
            $args[4] -eq $CONFIG_POWER_SETTINGS[0].Value
        }
        Should -Invoke powercfg -Exactly 1 -ParameterFilter {
            $args[0] -eq '/SetDcValueIndex' -and
            $args[1] -eq 'SCHEME_ALL' -and
            $args[2] -eq $CONFIG_POWER_SETTINGS[0].SubGroup -and
            $args[3] -eq $CONFIG_POWER_SETTINGS[0].Setting -and
            $args[4] -eq $CONFIG_POWER_SETTINGS[0].Value
        }
        Should -Invoke powercfg -Exactly 1 -ParameterFilter {
            $args[0] -eq '/SetAcValueIndex' -and
            $args[1] -eq 'SCHEME_ALL' -and
            $args[2] -eq $CONFIG_POWER_SETTINGS[1].SubGroup -and
            $args[3] -eq $CONFIG_POWER_SETTINGS[1].Setting -and
            $args[4] -eq $CONFIG_POWER_SETTINGS[1].Value
        }
        Should -Invoke powercfg -Exactly 1 -ParameterFilter {
            $args[0] -eq '/SetDcValueIndex' -and
            $args[1] -eq 'SCHEME_ALL' -and
            $args[2] -eq $CONFIG_POWER_SETTINGS[1].SubGroup -and
            $args[3] -eq $CONFIG_POWER_SETTINGS[1].Setting -and
            $args[4] -eq $CONFIG_POWER_SETTINGS[1].Value
        }
        Should -Invoke Test-PowerSetting -Exactly 2
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should skip a setting this system does not have' {
        Mock Test-PowerSetting { return $False } -ParameterFilter { $SubGroup -eq $CONFIG_POWER_SETTINGS[0].SubGroup }

        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 3
        Should -Invoke powercfg -Exactly 0 -ParameterFilter { $args[2] -eq $CONFIG_POWER_SETTINGS[0].SubGroup }
        Should -Invoke powercfg -Exactly 2 -ParameterFilter { $args[2] -eq $CONFIG_POWER_SETTINGS[1].SubGroup }
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle powercfg failure' {
        Mock powercfg { throw $TestException }

        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
