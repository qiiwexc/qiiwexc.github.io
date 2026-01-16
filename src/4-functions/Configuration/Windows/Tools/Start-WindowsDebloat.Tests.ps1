BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\Invoke-CustomCommand.ps1'

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
        Mock Test-NetworkConnection { return $True }
        Mock New-Item {}
        Mock Set-Content {}
        Mock Invoke-CustomCommand {}
        Mock Write-LogWarning {}
        Mock Out-Success {}
        Mock Write-LogError {}

        [Int]$OS_VERSION = 11

        [Bool]$TestUsePreset = $False
        [Bool]$TestPersonalisation = $False
        [Bool]$TestSilent = $False
    }

    It 'Should start debloat tool with configuration' {
        Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestTargetPath -and
            $ItemType -eq 'Directory' -and
            $Force -eq $True
        }
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
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq "$TestCommand -Sysprep"
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should start debloat tool with configuration on Windows versions older than 11' {
        [Int]$OS_VERSION = 10

        Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq $TestCommand
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should start debloat tool with custom preset' {
        [Bool]$TestUsePreset = $True

        Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq "$TestCommand -Sysprep -RunSavedSettings"
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should start debloat tool with personalisation configuration' {
        [Bool]$TestUsePreset = $True
        [Bool]$TestPersonalisation = $True

        Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
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
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq "$TestCommand -Sysprep -RunSavedSettings"
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should start debloat tool and automatically apply' {
        [Bool]$TestSilent = $True

        Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $HideWindow -eq $True -and
            $Command -eq "$TestCommand -Sysprep -Silent"
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        { Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        { Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent } | Should -Not -Throw
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should handle Invoke-CustomCommand failure' {
        Mock Invoke-CustomCommand { throw $TestException }

        { Start-WindowsDebloat -UsePreset:$TestUsePreset -Personalisation:$TestPersonalisation -Silent:$TestSilent } | Should -Not -Throw
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 2
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogError -Exactly 1
    }
}
