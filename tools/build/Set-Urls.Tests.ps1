BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\types.ps1'
    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Read-JsonFile.ps1'
    . '.\tools\common\Write-JsonFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestResourcesPath ([String]'TEST_RESOURCES_PATH')
    Set-Variable -Option Constant TestBuildPath ([String]'TEST_BUILD_PATH')

    Set-Variable -Option Constant TestDependenciesContent (
        [Dependency[]]@(
            @{name = 'test dependency-name 1'; version = 'TEST_VERSION_1' },
            @{name = 'test dependency-name 2'; version = 'TEST_VERSION_2' }
        )
    )
    Set-Variable -Option Constant TestTemplateContent (
        [PSCustomObject]@{
            URL_TEST_DEPENDENCY_NAME_1 = 'TEST_VALUE_1_{VERSION}'
            URL_TEST_DEPENDENCY_NAME_2 = '{VERSION}_TEST_VALUE_2'
        }
    )

    Set-Variable -Option Constant TestKey1 ([String]'URL_TEST_DEPENDENCY_NAME_1')
    Set-Variable -Option Constant TestValue1 ([String]'TEST_VALUE_1_{VERSION}')
    Set-Variable -Option Constant TestKey2 ([String]'URL_TEST_DEPENDENCY_NAME_2')
    Set-Variable -Option Constant TestValue2 ([String]'{VERSION}_TEST_VALUE_2')
    Set-Variable -Option Constant TestUrlsTemplate (
        [PSCustomObject]@{
            $TestKey1 = $TestValue1
            $TestKey2 = $TestValue2
        }
    )
}

Describe 'Set-Urls' {
    BeforeEach {
        Mock New-Activity {}
        Mock Read-JsonFile { return $TestDependenciesContent } -ParameterFilter { $Path -match 'dependencies' }
        Mock Read-JsonFile { return $TestTemplateContent } -ParameterFilter { $Path -match 'urls' }
        Mock Write-JsonFile {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should set URLs correctly' {
        Set-Urls $TestResourcesPath $TestBuildPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 2
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq "$TestResourcesPath\dependencies.json" }
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq "$TestResourcesPath\urls.json" }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq "$TestBuildPath\urls.json" -and
            $Content.URL_TEST_DEPENDENCY_NAME_1 -eq 'TEST_VALUE_1_TEST_VERSION_1' -and
            $Content.URL_TEST_DEPENDENCY_NAME_2 -eq 'TEST_VERSION_2_TEST_VALUE_2'
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle first Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException } -ParameterFilter { $Path -match 'dependencies' }

        { Set-Urls $TestResourcesPath $TestBuildPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle second Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException } -ParameterFilter { $Path -match 'urls' }

        { Set-Urls $TestResourcesPath $TestBuildPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 2
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-JsonFile failure' {
        Mock Write-JsonFile { throw $TestException }

        { Set-Urls $TestResourcesPath $TestBuildPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 2
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
