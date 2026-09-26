BeforeAll {
    # Untyped stubs so Pester can mock Windows-only commands on any host —
    # mocks and ParameterFilters bind against these simple parameters on every platform
    function powercfg { }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestSubGroup ([String]'TEST_SUB_GROUP')
    Set-Variable -Option Constant TestSetting ([String]'TEST_SETTING')
}

Describe 'Test-PowerSetting' {
    It 'Should find a setting this system has' {
        Mock powercfg { $global:LASTEXITCODE = 0 }

        Test-PowerSetting $TestSubGroup $TestSetting | Should -BeTrue

        Should -Invoke powercfg -Exactly 1 -ParameterFilter {
            $args[0] -eq '/Query' -and
            $args[1] -eq 'SCHEME_CURRENT' -and
            $args[2] -eq $TestSubGroup -and
            $args[3] -eq $TestSetting
        }
    }

    It 'Should not find a setting powercfg reports missing through its exit code' {
        Mock powercfg { $global:LASTEXITCODE = 1 }

        Test-PowerSetting $TestSubGroup $TestSetting | Should -BeFalse
    }

    It 'Should not find a setting powercfg reports missing through an error' {
        Mock powercfg { throw 'The power scheme, subgroup or setting specified does not exist.' }

        Test-PowerSetting $TestSubGroup $TestSetting | Should -BeFalse
    }
}
