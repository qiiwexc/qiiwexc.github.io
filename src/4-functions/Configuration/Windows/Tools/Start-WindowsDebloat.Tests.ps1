BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Invoke-CustomCommand.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\New-Directory.ps1'
    . '.\src\4-functions\Configuration\Windows\Tools\Assertions.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_TEMP_DIR ([String]'TEST_PATH_TEMP_DIR')
    Set-Variable -Option Constant CONFIG_DEBLOAT_APP_LIST ([String]"TEST_CONFIG_DEBLOAT_APP_LIST1`nTEST_CONFIG_DEBLOAT_APP_LIST2`n")
    Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET_BASE ([String]"TEST_CONFIG_DEBLOAT_PRESET_BASE1`nTEST_CONFIG_DEBLOAT_PRESET_BASE2")
    Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET_PERSONALISATION ([String]"TEST_CONFIG_DEBLOAT_PRESET_PERSONALISATION1`nTEST_CONFIG_DEBLOAT_PRESET_PERSONALISATION2")

    Set-Variable -Option Constant TestTargetPath ([String]"$PATH_TEMP_DIR\Win11Debloat")
    Set-Variable -Option Constant TestAppsListPath ([String]"$TestTargetPath\CustomAppsList")
    Set-Variable -Option Constant TestSettingsPath ([String]"$TestTargetPath\LastUsedSettings.json")
    Set-Variable -Option Constant TestCommand ([String]"& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) -NoRestartExplorer")
}

Describe 'Start-WindowsDebloat' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Test-WindowsDebloatIsRunning {}
        Mock Test-OOShutUp10IsRunning {}
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock New-Directory {}
        Mock Set-Content {}
        Mock Invoke-CustomCommand {}
        Mock Out-Success {}
        Mock Out-Failure {}

        [Int]$OS_VERSION = 11
    }

    It 'Should start debloat tool with configuration' {
        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $TestTargetPath }
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestAppsListPath -and
            $Value -eq $CONFIG_DEBLOAT_APP_LIST -and
            $NoNewline -eq $True
        }
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestSettingsPath -and
            $Value -eq $CONFIG_DEBLOAT_PRESET_BASE -and
            $NoNewline -eq $True
        }
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq "$TestCommand -Sysprep"
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should start debloat tool with configuration on Windows versions older than 11' {
        [Int]$OS_VERSION = 10

        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq $TestCommand
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should start debloat tool with custom preset' {
        Start-WindowsDebloat -UsePreset

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq "$TestCommand -Sysprep -RunSavedSettings -RemoveAppsCustom"
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should start debloat tool with personalisation configuration' {
        Start-WindowsDebloat -UsePreset -Personalisation

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestAppsListPath -and
            $Value -eq ($CONFIG_DEBLOAT_APP_LIST + 'Microsoft.OneDrive') -and
            $NoNewline -eq $True
        }
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestSettingsPath -and
            $Value -eq $CONFIG_DEBLOAT_PRESET_PERSONALISATION -and
            $NoNewline -eq $True
        }
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq "$TestCommand -Sysprep -RunSavedSettings -RemoveAppsCustom"
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should start debloat tool and automatically apply' {
        Start-WindowsDebloat -Silent

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq "$TestCommand -Sysprep -Silent"
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if already running' {
        Mock Test-WindowsDebloatIsRunning { return @(@{ ProcessName = 'powershell' }) }

        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if OOShutUp10 is running' {
        Mock Test-OOShutUp10IsRunning { return @(@{ ProcessName = 'OOSU10' }) }

        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
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

        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Test-WindowsDebloatIsRunning failure' {
        Mock Test-WindowsDebloatIsRunning { throw $TestException }

        { Start-WindowsDebloat } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Test-OOShutUp10IsRunning failure' {
        Mock Test-OOShutUp10IsRunning { throw $TestException }

        { Start-WindowsDebloat } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
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

        { Start-WindowsDebloat } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
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

        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
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

        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
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

        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
