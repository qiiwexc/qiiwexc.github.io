BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Invoke-CustomCommand.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\New-Directory.ps1'
    . '.\src\4-functions\Configuration\Windows\Tools\Assertions.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

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
        Mock Assert-WinUtilIsRunning {}
        Mock Assert-WindowsDebloatIsRunning {}
        Mock Assert-OOShutUp10IsRunning {}
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock New-Directory {}
        Mock Set-Content {}
        Mock Invoke-CustomCommand {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should start WinUtil with configuration' {
        Start-WinUtil

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $PATH_WINUTIL }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestConfigFile -and
            $Value -eq $CONFIG_WINUTIL -and
            $NoNewline -eq $True
        }
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter { $Command -eq $TestCommand }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should start WinUtil with personalisation configuration' {
        Start-WinUtil -Personalisation

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestConfigFile -and
            $Value -eq $TestConfigWithPersonalization -and
            $NoNewline -eq $True
        }
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should start WinUtil and automatically apply' {
        Start-WinUtil -AutomaticallyApply

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter { $Command -eq "$TestCommand -Run" }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if already running' {
        Mock Assert-WinUtilIsRunning { return @(@{ ProcessName = 'powershell' }) }

        Start-WinUtil

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 0
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if Windows debloat is running' {
        Mock Assert-WindowsDebloatIsRunning { return @(@{ ProcessName = 'powershell' }) }

        Start-WinUtil

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if OOShutUp10 is running' {
        Mock Assert-OOShutUp10IsRunning { return @(@{ ProcessName = 'OOSU10' }) }

        Start-WinUtil

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Start-WinUtil

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Assert-WinUtilIsRunning failure' {
        Mock Assert-WinUtilIsRunning { throw $TestException }

        { Start-WinUtil } | Should -Throw $TestException

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 0
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Assert-WindowsDebloatIsRunning failure' {
        Mock Assert-WindowsDebloatIsRunning { throw $TestException }

        { Start-WinUtil } | Should -Throw $TestException

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Assert-OOShutUp10IsRunning failure' {
        Mock Assert-OOShutUp10IsRunning { throw $TestException }

        { Start-WinUtil } | Should -Throw $TestException

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        { Start-WinUtil } | Should -Throw $TestException

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle New-Directory failure' {
        Mock New-Directory { throw $TestException }

        Start-WinUtil

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        Start-WinUtil

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Invoke-CustomCommand failure' {
        Mock Invoke-CustomCommand { throw $TestException }

        Start-WinUtil

        Should -Invoke Assert-WinUtilIsRunning -Exactly 1
        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Assert-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
