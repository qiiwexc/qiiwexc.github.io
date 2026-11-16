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
        Mock powercfg { $global:LASTEXITCODE = 0 }
        Mock Test-PowerSetting { return $True }
        Mock Write-LogDebug {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should set power scheme configuration' {
        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 6
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
        Should -Invoke powercfg -Exactly 1 -ParameterFilter {
            $args[0] -eq '/SetActive' -and
            $args[1] -eq 'SCHEME_CURRENT'
        }
        Should -Invoke Test-PowerSetting -Exactly 2
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should activate the current scheme again only once every value is set' {
        [Collections.Generic.List[String]]$script:Calls = @()
        Mock powercfg { $script:Calls.Add($args[0]); $global:LASTEXITCODE = 0 }

        Set-PowerSchemeConfiguration

        $script:Calls[-1] | Should -BeExactly '/SetActive'
    }

    It 'Should skip a setting this system does not have' {
        Mock Test-PowerSetting { return $False } -ParameterFilter { $SubGroup -eq $CONFIG_POWER_SETTINGS[0].SubGroup }

        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 4
        Should -Invoke powercfg -Exactly 0 -ParameterFilter { $args[2] -eq $CONFIG_POWER_SETTINGS[0].SubGroup }
        Should -Invoke powercfg -Exactly 2 -ParameterFilter { $args[2] -eq $CONFIG_POWER_SETTINGS[1].SubGroup }
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should name a setting powercfg refuses through its exit code, set the rest, and not report done' {
        Mock powercfg { $global:LASTEXITCODE = 1 } -ParameterFilter { $args[0] -eq '/SetDcValueIndex' -and $args[2] -eq $CONFIG_POWER_SETTINGS[0].SubGroup }

        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 6
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -eq "Could not apply $($CONFIG_POWER_SETTINGS[0].SubGroup) $($CONFIG_POWER_SETTINGS[0].Setting)" }
    }

    It 'Should name a setting powercfg refuses by throwing, and set the rest' {
        Mock powercfg { throw $TestException } -ParameterFilter { $args[0] -eq '/SetAcValueIndex' -and $args[2] -eq $CONFIG_POWER_SETTINGS[1].SubGroup }

        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 1 -ParameterFilter { $args[0] -eq '/SetActive' }
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -eq "Could not apply $($CONFIG_POWER_SETTINGS[1].SubGroup) $($CONFIG_POWER_SETTINGS[1].Setting)" }
    }

    It 'Should report a power mode or a reactivation that fails' {
        Mock powercfg { $global:LASTEXITCODE = 1 } -ParameterFilter { $args[0] -in @('/OverlaySetActive', '/SetActive') }

        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 6
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -eq 'Could not apply the power mode, the reactivation of the current power scheme' }
    }

    It 'Should handle powercfg failure' {
        Mock powercfg { throw $TestException }

        Set-PowerSchemeConfiguration

        Should -Invoke powercfg -Exactly 4
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -like "Failed to apply power settings configuration: *$TestException*" }
    }
}
