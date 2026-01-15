BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\Invoke-CustomCommand.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_WINUTIL ([String]'TEST_PATH_WINUTIL')
    Set-Variable -Option Constant CONFIG_WINUTIL ([String]"TEST_CONFIG_WINUTIL_1    `"WPFTweaks`":  [
 TEST_CONFIG_WINUTIL_2")
    Set-Variable -Option Constant CONFIG_WINUTIL_PERSONALISATION ([String]'TEST_CONFIG_WINUTIL_PERSONALISATION')

    Set-Variable -Option Constant TestConfigFile ([String]"$PATH_WINUTIL\WinUtil.json")
    Set-Variable -Option Constant TestConfigWithPersonalization ([String]"TEST_CONFIG_WINUTIL_1    `"WPFTweaks`":  [
TEST_CONFIG_WINUTIL_PERSONALISATION TEST_CONFIG_WINUTIL_2")
    Set-Variable -Option Constant TestCommand ([String]"& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) -Config $TestConfigFile")
}

Describe 'Start-WinUtil' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Test-NetworkConnection { return $True }
        Mock New-Item {}
        Mock Set-Content {}
        Mock Invoke-CustomCommand {}
        Mock Out-Success {}

        [Bool]$TestPersonalisation = $False
        [Bool]$TestAutomaticallyApply = $False
    }

    It 'Should start WinUtil with configuration' {
        Start-WinUtil -Personalisation:$TestPersonalisation -AutomaticallyApply:$TestAutomaticallyApply

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter {
            $Path -eq $PATH_WINUTIL -and
            $ItemType -eq 'Directory' -and
            $Force -eq $True
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestConfigFile -and
            $Value -eq $CONFIG_WINUTIL -and
            $NoNewline -eq $True
        }
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter { $Command -eq $TestCommand }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should start WinUtil with personalisation configuration' {
        [Bool]$TestPersonalisation = $True

        Start-WinUtil -Personalisation:$TestPersonalisation -AutomaticallyApply:$TestAutomaticallyApply

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestConfigFile -and
            $Value -eq $TestConfigWithPersonalization -and
            $NoNewline -eq $True
        }
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should start WinUtil and automatically apply' {
        [Bool]$TestAutomaticallyApply = $True

        Start-WinUtil -Personalisation:$TestPersonalisation -AutomaticallyApply:$TestAutomaticallyApply

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter { $Command -eq "$TestCommand -Run" }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Start-WinUtil -Personalisation:$TestPersonalisation -AutomaticallyApply:$TestAutomaticallyApply

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        { Start-WinUtil -Personalisation:$TestPersonalisation -AutomaticallyApply:$TestAutomaticallyApply } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        { Start-WinUtil -Personalisation:$TestPersonalisation -AutomaticallyApply:$TestAutomaticallyApply } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Start-WinUtil -Personalisation:$TestPersonalisation -AutomaticallyApply:$TestAutomaticallyApply } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Invoke-CustomCommand failure' {
        Mock Invoke-CustomCommand { throw $TestException }

        { Start-WinUtil -Personalisation:$TestPersonalisation -AutomaticallyApply:$TestAutomaticallyApply } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
