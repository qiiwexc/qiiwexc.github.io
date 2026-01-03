BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestConfigPath 'TEST_CONFIG_PATH'
    Set-Variable -Option Constant TestTemplatesPath 'TEST_TEMPLATES_PATH'
    Set-Variable -Option Constant TestBuildPath 'TEST_BUILD_PATH'

    Set-Variable -Option Constant TestDependenciesContent '[{"name":"test dependency-name 1","version":"TEST_VERSION_1"},{"name":"test-dependency name 2","version":"vTEST_VERSION_2"}]'
    Set-Variable -Option Constant TestTemplateContent '[{"key":"URL_TEST_DEPENDENCY_NAME_1","value":"TEST_VALUE_1_{VERSION}"},{"key":"URL_TEST_DEPENDENCY_NAME_2","value":"{VERSION}_TEST_VALUE_2"}]'

    Set-Variable -Option Constant TestKey1 'URL_TEST_DEPENDENCY_NAME_1'
    Set-Variable -Option Constant TestValue1 'TEST_VALUE_1_{VERSION}'
    Set-Variable -Option Constant TestKey2 'URL_TEST_DEPENDENCY_NAME_2'
    Set-Variable -Option Constant TestValue2 '{VERSION}_TEST_VALUE_2'
    Set-Variable -Option Constant TestUrlsTemplate @(
        @{key = $TestKey1; value = $TestValue1 }
        @{key = $TestKey2; value = $TestValue2 }
    )

    function Write-LogInfo {}
    function Out-Success {}
}

Describe 'Set-Urls' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Get-Content { return $TestDependenciesContent } -ParameterFilter { $Path -match $TestConfigPath }
        Mock Get-Content { return $TestTemplateContent } -ParameterFilter { $Path -match $TestTemplatesPath }
        Mock Write-File {}
        Mock Out-Success {}
    }

    It 'Should set URLs correctly' {
        Set-Urls $TestConfigPath $TestTemplatesPath $TestBuildPath

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigPath\dependencies.json" }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestTemplatesPath\urls.json" }
        Should -Invoke Write-File -Exactly 1
        Should -Invoke Write-File -Exactly 1 -ParameterFilter {
            $Content -match 'URL_TEST_DEPENDENCY_NAME_1' -and
            $Content -match 'URL_TEST_DEPENDENCY_NAME_2' -and
            $Content -match 'TEST_VALUE_1_TEST_VERSION_1' -and
            $Content -match 'TEST_VERSION_2_TEST_VALUE_2' -and
            $Path -eq "$TestBuildPath\urls.json"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle first Get-Content failure' {
        Mock Get-Content { throw $TestException } -ParameterFilter { $Path -match $TestConfigPath }

        { Set-Urls $TestConfigPath $TestTemplatesPath $TestBuildPath } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigPath\dependencies.json" }
        Should -Invoke Write-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle second Get-Content failure' {
        Mock Get-Content { throw $TestException } -ParameterFilter { $Path -match $TestTemplatesPath }

        { Set-Urls $TestConfigPath $TestTemplatesPath $TestBuildPath } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigPath\dependencies.json" }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestTemplatesPath\urls.json" }
        Should -Invoke Write-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle first ConvertFrom-Json failure' {
        Mock ConvertFrom-Json { throw $TestException } -ParameterFilter { $InputObject -eq $TestDependenciesContent }

        { Set-Urls $TestConfigPath $TestTemplatesPath $TestBuildPath } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigPath\dependencies.json" }
        Should -Invoke Write-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle second ConvertFrom-Json failure' {
        Mock ConvertFrom-Json { throw $TestException } -ParameterFilter { $InputObject -eq $TestTemplateContent }

        { Set-Urls $TestConfigPath $TestTemplatesPath $TestBuildPath } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigPath\dependencies.json" }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestTemplatesPath\urls.json" }
        Should -Invoke Write-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle ConvertTo-Json failure' {
        Mock ConvertTo-Json { throw $TestException }

        { Set-Urls $TestConfigPath $TestTemplatesPath $TestBuildPath } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigPath\dependencies.json" }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestTemplatesPath\urls.json" }
        Should -Invoke Write-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Write-File failure' {
        Mock Write-File { throw $TestException }

        { Set-Urls $TestConfigPath $TestTemplatesPath $TestBuildPath } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigPath\dependencies.json" }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestTemplatesPath\urls.json" }
        Should -Invoke Write-File -Exactly 1
        Should -Invoke Write-File -Exactly 1 -ParameterFilter {
            $Content -match 'URL_TEST_DEPENDENCY_NAME_1' -and
            $Content -match 'URL_TEST_DEPENDENCY_NAME_2' -and
            $Content -match 'TEST_VALUE_1_TEST_VERSION_1' -and
            $Content -match 'TEST_VERSION_2_TEST_VALUE_2' -and
            $Path -eq "$TestBuildPath\urls.json"
        }
        Should -Invoke Out-Success -Exactly 0
    }
}
