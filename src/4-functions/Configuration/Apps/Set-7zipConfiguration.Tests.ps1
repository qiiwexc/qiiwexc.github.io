BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\Configuration\Helpers\Add-SysPrepConfig.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_7ZIP ([String]'TEST_CONFIG_7ZIP')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestSysprepConfig ([String]'TEST_SYSPREP_CONFIG')
}

Describe 'Set-7zipConfiguration' {
    BeforeEach {
        Mock Add-SysPrepConfig { return $TestSysprepConfig }
        Mock Import-RegistryConfiguration {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should configure 7zip' {
        Set-7zipConfiguration $TestAppName

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

        Set-7zipConfiguration $TestAppName

        Should -Invoke Add-SysPrepConfig -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
