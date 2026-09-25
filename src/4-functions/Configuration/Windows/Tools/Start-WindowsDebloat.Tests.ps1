BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\..\Common\Network.ps1"
    . "$PSScriptRoot\..\..\..\Common\New-Directory.ps1"
    . "$PSScriptRoot\..\..\..\Common\Start-Download.ps1"
    . "$PSScriptRoot\Assertions.ps1"
    . "$PSScriptRoot\Expand-WindowsDebloat.ps1"
    . "$PSScriptRoot\..\..\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_TEMP_DIR ([String]'TEST_PATH_TEMP_DIR\')
    Set-Variable -Option Constant PATH_SYSTEM_32 ([String]'TEST_PATH_SYSTEM_32')
    Set-Variable -Option Constant CONFIG_DEBLOAT_APP_LIST_BASE ([String]'[{"AppId":"TestApp1"},{"AppId":"TestApp2"}]')
    Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET_BASE ([String]"TEST_CONFIG_DEBLOAT_PRESET_BASE1`nTEST_CONFIG_DEBLOAT_PRESET_BASE2")
    Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET_PERSONALIZATION ([String]"TEST_CONFIG_DEBLOAT_PRESET_PERSONALIZATION1`nTEST_CONFIG_DEBLOAT_PRESET_PERSONALIZATION2")

    Set-Variable -Option Constant TestZipPath ([String]'TEST_PATH_APP_DIR\Win11Debloat.zip')
    Set-Variable -Option Constant TestToolPath ([String]'TEST_PATH_TEMP_DIR\Win11Debloat')
    Set-Variable -Option Constant TestScriptPath ([String]"$TestToolPath\Win11Debloat.ps1")
    Set-Variable -Option Constant TestConfigPath ([String]"$TestToolPath\Config")
    Set-Variable -Option Constant TestSettingsPath ([String]"$TestConfigPath\LastUsedSettings.json")
    Set-Variable -Option Constant TestPowerShell ([String]'TEST_PATH_SYSTEM_32\WindowsPowerShell\v1.0\powershell.exe')
    Set-Variable -Option Constant TestArguments ([String]"-NoProfile -ExecutionPolicy Bypass -File `"$TestScriptPath`" -SkipExplorerRestart")
    Set-Variable -Option Constant TestPresetParams ([String]'-RunSavedSettings -RemoveApps -Apps "TestApp1,TestApp2"')
}

Describe 'Start-WindowsDebloat' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Test-WindowsDebloatIsRunning {}
        Mock Test-OOShutUp10IsRunning {}
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock Start-Download { return $TestZipPath }
        Mock Expand-WindowsDebloat { return $TestScriptPath }
        Mock New-Directory {}
        Mock Set-Content {}
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    BeforeEach {
        [Int]$OS_VERSION = 11
    }

    It 'Should run the pinned release with the base configuration' {
        Start-WindowsDebloat

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Start-Download -Exactly 1 -ParameterFilter {
            $URL -eq '{URL_WIN11DEBLOAT}' -and
            $SaveAs -eq 'Win11Debloat.zip' -and
            $Sha256 -eq '{SHA256_WIN11DEBLOAT}' -and
            $Temp -eq $True -and
            $NoBits -eq $True
        }
        Should -Invoke Expand-WindowsDebloat -Exactly 1
        Should -Invoke Expand-WindowsDebloat -Exactly 1 -ParameterFilter {
            $ZipPath -eq $TestZipPath -and
            $ToolPath -eq $TestToolPath
        }
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $TestConfigPath }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestSettingsPath -and
            $Value -eq $CONFIG_DEBLOAT_PRESET_BASE -and
            $NoNewline -eq $True
        }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestPowerShell -and
            $ArgumentList -eq $TestArguments
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should run the pinned release on Windows versions older than 11' {
        [Int]$OS_VERSION = 10

        Start-WindowsDebloat

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq $TestArguments }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should run with the custom preset' {
        Start-WindowsDebloat -UsePreset

        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestSettingsPath -and
            $Value -eq $CONFIG_DEBLOAT_PRESET_BASE
        }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq "$TestArguments -Sysprep $TestPresetParams" }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should run with the custom preset on Windows versions older than 11' {
        [Int]$OS_VERSION = 10

        Start-WindowsDebloat -UsePreset

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq "$TestArguments  $TestPresetParams" }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should run with the personalization configuration' {
        Start-WindowsDebloat -UsePreset -Personalization

        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestSettingsPath -and
            $Value -eq $CONFIG_DEBLOAT_PRESET_PERSONALIZATION -and
            $NoNewline -eq $True
        }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq "$TestArguments -Sysprep $TestPresetParams" }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should run and apply automatically' {
        Start-WindowsDebloat -Silent

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq "$TestArguments   -Silent" }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should run with the custom preset and apply automatically' {
        Start-WindowsDebloat -UsePreset -Silent

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $ArgumentList -eq "$TestArguments -Sysprep $TestPresetParams -Silent" }
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
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if OOShutUp10 is running' {
        Mock Test-OOShutUp10IsRunning { return @(@{ ProcessName = 'OOSU10' }) }

        Start-WindowsDebloat

        Should -Invoke Test-OOShutUp10IsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Start-WindowsDebloat

        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Test-WindowsDebloatIsRunning failure' {
        Mock Test-WindowsDebloatIsRunning { throw $TestException }

        { Start-WindowsDebloat } | Should -Throw $TestException

        Should -Invoke Test-OOShutUp10IsRunning -Exactly 0
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
    }

    It 'Should handle Test-OOShutUp10IsRunning failure' {
        Mock Test-OOShutUp10IsRunning { throw $TestException }

        { Start-WindowsDebloat } | Should -Throw $TestException

        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        { Start-WindowsDebloat } | Should -Throw $TestException

        Should -Invoke Start-Download -Exactly 0
        Should -Invoke Start-Process -Exactly 0
    }

    It 'Should not run anything if the download fails' {
        Mock Start-Download { throw $TestException }

        Start-WindowsDebloat

        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-WindowsDebloat -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should not run anything if the extraction fails' {
        Mock Expand-WindowsDebloat { throw $TestException }

        Start-WindowsDebloat

        Should -Invoke Expand-WindowsDebloat -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should still run if the configuration folder cannot be created' {
        Mock New-Directory { throw $TestException }

        Start-WindowsDebloat

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should still run if the configuration cannot be written' {
        Mock Set-Content { throw $TestException }

        Start-WindowsDebloat

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        Start-WindowsDebloat

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
