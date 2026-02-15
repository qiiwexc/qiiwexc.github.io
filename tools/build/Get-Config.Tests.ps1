BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\types.ps1'
    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Read-JsonFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestResourcesPath ([String]'TEST_RESOURCES_PATH')
    Set-Variable -Option Constant TestVersion ([Version]'1.2.3')

    Set-Variable -Option Constant TestDependencies (
        [Dependency[]]@(
            @{name = 'test dependency-name 1'; version = 'v1.0.0' },
            @{name = 'test dependency-name 2'; version = '2.0.0' }
        )
    )
    Set-Variable -Option Constant TestUrlsTemplate (
        [PSCustomObject]@{
            URL_TEST_DEPENDENCY_NAME_1 = 'https://example.com/{VERSION}/download'
            URL_TEST_DEPENDENCY_NAME_2 = 'https://example.com/file-{VERSION}.zip'
            URL_STATIC = 'https://example.com/static'
        }
    )
}

Describe 'Get-Config' {
    BeforeEach {
        Mock New-Activity {}
        Mock Read-JsonFile { return $TestDependencies } -ParameterFilter { $Path -match 'dependencies' }
        Mock Read-JsonFile { return $TestUrlsTemplate } -ParameterFilter { $Path -match 'urls' }
        Mock Write-ActivityCompleted {}
    }

    It 'Should load config with resolved URLs and project version' {
        Set-Variable -Option Constant Result (Get-Config $TestResourcesPath $TestVersion)

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 2
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq "$TestResourcesPath\dependencies.json" }
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq "$TestResourcesPath\urls.json" }
        Should -Invoke Write-ActivityCompleted -Exactly 1

        $Result.URL_TEST_DEPENDENCY_NAME_1 | Should -BeExactly 'https://example.com/1.0.0/download'
        $Result.URL_TEST_DEPENDENCY_NAME_2 | Should -BeExactly 'https://example.com/file-2.0.0.zip'
        $Result.URL_STATIC | Should -BeExactly 'https://example.com/static'
        $Result.PROJECT_VERSION | Should -BeExactly $TestVersion
    }

    It 'Should handle dependencies Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException } -ParameterFilter { $Path -match 'dependencies' }

        { Get-Config $TestResourcesPath $TestVersion } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle urls Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException } -ParameterFilter { $Path -match 'urls' }

        { Get-Config $TestResourcesPath $TestVersion } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 2
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
