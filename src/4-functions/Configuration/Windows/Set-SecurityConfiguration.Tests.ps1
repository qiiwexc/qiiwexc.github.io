BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\Configuration\Helpers\Add-SysPrepConfig.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_SECURITY ([String]'TEST_CONFIG_SECURITY')

    Set-Variable -Option Constant TestAppName ([String]'Windows Security Config')
    Set-Variable -Option Constant TestSysprepConfig ([String]'TEST_SYSPREP_CONFIG')
}

Describe 'Set-SecurityConfiguration' {
    BeforeEach {
        Mock Add-SysPrepConfig { return $TestSysprepConfig }
        Mock Import-RegistryConfiguration {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should set Windows security configuration' {
        Set-SecurityConfiguration $TestAppName

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $Content -eq $TestSysprepConfig
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-SecurityConfiguration $TestAppName

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
