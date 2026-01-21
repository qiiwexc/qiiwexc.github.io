BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Helpers\Write-ConfigurationFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_ANYDESK ([String]'TEST_CONFIG_ANYDESK')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestExistingConfig ([String]'TEST_EXISTING_CONFIG_ANYDESK')
    Set-Variable -Option Constant TestConfigPath ([String]"\\AppData\\Roaming\\$TestAppName\\user.conf$")
}

Describe 'Set-AnyDeskConfiguration' {
    BeforeEach {
        Mock Write-ActivityProgress {}
        Mock Test-Path { return $False }
        Mock Get-Content { return $TestExistingConfig }
        Mock Write-ConfigurationFile {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should configure AnyDesk with no existing config' {
        Set-AnyDeskConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -match $TestConfigPath }
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Write-ConfigurationFile -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $Content -eq $CONFIG_ANYDESK -and
            $Path -match $TestConfigPath
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should configure AnyDesk with existing config' {
        Mock Test-Path { return $True }

        Set-AnyDeskConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -match $TestConfigPath -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Write-ConfigurationFile -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $Content -eq ($TestExistingConfig + $CONFIG_ANYDESK) -and
            $Path -match $TestConfigPath
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        Set-AnyDeskConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Write-ConfigurationFile -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Get-Content failure' {
        Mock Test-Path { return $True }
        Mock Get-Content { throw $TestException }

        Set-AnyDeskConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Write-ConfigurationFile failure' {
        Mock Write-ConfigurationFile { throw $TestException }

        Set-AnyDeskConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Write-ConfigurationFile -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
