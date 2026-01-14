BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestBuildPath ([String]'TEST_BUILD_PATH')
    Set-Variable -Option Constant TestVersion ([String]'TEST_VERSION')
    Set-Variable -Option Constant TestContent ([String]'[{"key":"TEST_KEY_1","value":"TEST_VALUE_1"},{"key":"TEST_KEY_2","value":"TEST_VALUE_2"}]')

    Set-Variable -Option Constant TestKey1 ([String]'TEST_KEY_1')
    Set-Variable -Option Constant TestValue1 ([String]'TEST_VALUE_1')
    Set-Variable -Option Constant TestKey2 ([String]'TEST_KEY_2')
    Set-Variable -Option Constant TestValue2 ([String]'TEST_VALUE_2')
}

Describe 'Get-Config' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Get-Content { return $TestContent }
        Mock Out-Success {}
    }

    It 'Should load config' {
        Set-Variable -Option Constant Result (Get-Config $TestBuildPath $TestVersion)

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestBuildPath\urls.json" }
        Should -Invoke Out-Success -Exactly 1

        $Result[0].key | Should -BeExactly $TestKey1
        $Result[0].value | Should -BeExactly $TestValue1
        $Result[1].key | Should -BeExactly $TestKey2
        $Result[1].value | Should -BeExactly $TestValue2
        $Result[2].key | Should -BeExactly 'PROJECT_VERSION'
        $Result[2].value | Should -BeExactly $TestVersion
    }

    It 'Should handle Get-Content failure' {
        Mock ConvertFrom-Json {}
        Mock Get-Content { throw $TestException }

        { Get-Config $TestBuildPath $TestVersion } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestBuildPath\urls.json" }
        Should -Invoke ConvertFrom-Json -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle ConvertFrom-Json failure' {
        Mock ConvertFrom-Json { throw $TestException }

        { Get-Config $TestBuildPath $TestVersion } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestBuildPath\urls.json" }
        Should -Invoke ConvertFrom-Json -Exactly 1
        Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $InputObject -eq $TestContent }
        Should -Invoke Out-Success -Exactly 0
    }
}
