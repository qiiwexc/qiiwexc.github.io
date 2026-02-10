function Start-WindowsDebloat {
    param(
        [Switch]$UsePreset,
        [Switch]$Personalisation,
        [Switch]$Silent
    )

    Write-LogInfo 'Starting Windows 10/11 debloat utility...'

    if (Assert-WindowsDebloatIsRunning) {
        Write-LogWarning 'Windows debloat utility is already running'
        return
    }

    if (Assert-OOShutUp10IsRunning) {
        Write-LogWarning 'OOShutUp10++ utility is running, which may interfere with the Windows debloat utility'
        Write-LogWarning 'Repeat the attempt after OOShutUp10++ utility has finished running'
        return
    }

    if (-not (Test-NetworkConnection)) {
        return
    }

    try {
        Set-Variable -Option Constant TargetPath ([String]"$PATH_TEMP_DIR\Win11Debloat")

        New-Directory $TargetPath

        if ($UsePreset -and $Personalisation) {
            Set-Variable -Option Constant AppsList ([String]($CONFIG_DEBLOAT_APP_LIST + 'Microsoft.OneDrive'))
        } else {
            Set-Variable -Option Constant AppsList ([String]$CONFIG_DEBLOAT_APP_LIST)
        }

        Set-Content "$TargetPath\CustomAppsList" $AppsList -NoNewline -ErrorAction Stop

        if ($UsePreset -and $Personalisation) {
            Set-Variable -Option Constant Configuration ([String]($CONFIG_DEBLOAT_PRESET_PERSONALISATION))
        } else {
            Set-Variable -Option Constant Configuration ([String]$CONFIG_DEBLOAT_PRESET_BASE)
        }

        Set-Content "$TargetPath\LastUsedSettings.json" $Configuration -NoNewline -ErrorAction Stop
    } catch {
        Write-LogWarning "Failed to initialize Windows debloat utility configuration: $_"
    }

    try {
        if ($UsePreset -or $Personalisation) {
            Set-Variable -Option Constant UsePresetParam ([String]' -RunSavedSettings -RemoveAppsCustom')
        }

        if ($Silent) {
            Set-Variable -Option Constant SilentParam ([String]' -Silent')
        }

        if ($OS_VERSION -ge 11) {
            Set-Variable -Option Constant SysprepParam ([String]' -Sysprep')
        }

        Set-Variable -Option Constant Params ([String]"-NoRestartExplorer$SysprepParam$UsePresetParam$SilentParam")

        Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"

        Out-Success
    } catch {
        Out-Failure "Failed to start Windows debloat utility: $_"
    }
}
