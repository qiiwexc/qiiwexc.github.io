BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\types.ps1'
    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Read-JsonFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestBuildPath ([String]'TEST_BUILD_PATH')
    Set-Variable -Option Constant TestVersion ([Version]'1.2.3')
    Set-Variable -Option Constant TestContent (
        [Collections.Generic.List[Config]]@(
            @{key = 'TEST_KEY_1'; value = 'TEST_VALUE_1' },
            @{key = 'TEST_KEY_2'; value = 'TEST_VALUE_2' }
        )
    )

    Set-Variable -Option Constant TestKey1 ([String]'TEST_KEY_1')
    Set-Variable -Option Constant TestValue1 ([String]'TEST_VALUE_1')
    Set-Variable -Option Constant TestKey2 ([String]'TEST_KEY_2')
    Set-Variable -Option Constant TestValue2 ([String]'TEST_VALUE_2')
}

Describe 'Get-Config' {
    BeforeEach {
        Mock New-Activity {}
        Mock Read-JsonFile { return $TestContent }
        Mock Write-ActivityCompleted {}
    }

    It 'Should load config' {
        Set-Variable -Option Constant Result (Get-Config $TestBuildPath $TestVersion)

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq "$TestBuildPath\urls.json" }
        Should -Invoke Write-ActivityCompleted -Exactly 1

        $Result[0].key | Should -BeExactly $TestKey1
        $Result[0].value | Should -BeExactly $TestValue1
        $Result[1].key | Should -BeExactly $TestKey2
        $Result[1].value | Should -BeExactly $TestValue2
        $Result[2].key | Should -BeExactly 'PROJECT_VERSION'
        $Result[2].value | Should -BeExactly $TestVersion
    }

    It 'Should handle Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException }

        { Get-Config $TestBuildPath $TestVersion } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
