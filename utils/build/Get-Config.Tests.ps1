BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestBuildPath 'TEST_BUILD_PATH'
    Set-Variable -Option Constant TestVersion 'TEST_VERSION'
    Set-Variable -Option Constant TestContent '[{"key":"TEST_KEY_1","value":"TEST_VALUE_1"},{"key":"TEST_KEY_2","value":"TEST_VALUE_2"}]'

    Set-Variable -Option Constant TestKey1 'TEST_KEY_1'
    Set-Variable -Option Constant TestValue1 'TEST_VALUE_1'
    Set-Variable -Option Constant TestKey2 'TEST_KEY_2'
    Set-Variable -Option Constant TestValue2 'TEST_VALUE_2'

    function Write-LogInfo {}
    function Out-Success {}
}

Describe 'Get-Config' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Get-Content { return $TestContent }
        Mock Out-Success {}
    }

    It 'Should load config' {
        Set-Variable -Option Constant Result (Get-Config $TestBuildPath $TestVersion)

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestBuildPath\urls.json" }
        Should -Invoke Out-Success -Exactly 1

        $Result[0].key | Should -Be $TestKey1
        $Result[0].value | Should -Be $TestValue1
        $Result[1].key | Should -Be $TestKey2
        $Result[1].value | Should -Be $TestValue2
        $Result[2].key | Should -Be 'PROJECT_VERSION'
        $Result[2].value | Should -Be $TestVersion
    }

    It 'Should handle Get-Content failure' {
        Mock ConvertFrom-Json {}
        Mock Get-Content { throw $TestException }

        { Get-Config $TestBuildPath $TestVersion } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestBuildPath\urls.json" }
        Should -Invoke ConvertFrom-Json -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle ConvertFrom-Json failure' {
        Mock ConvertFrom-Json { throw $TestException }

        { Get-Config $TestBuildPath $TestVersion } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq "$TestBuildPath\urls.json" }
        Should -Invoke ConvertFrom-Json -Exactly 1
        Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $InputObject -eq $TestContent }
        Should -Invoke Out-Success -Exactly 0
    }
}
