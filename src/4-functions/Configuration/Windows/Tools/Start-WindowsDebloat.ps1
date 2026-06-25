function Start-WindowsDebloat {
    param(
        [Switch]$UsePreset,
        [Switch]$Personalization,
        [Switch]$Silent
    )

    Write-LogInfo 'Starting Windows 10/11 debloat utility...'

    if (Test-WindowsDebloatIsRunning) {
        Write-LogWarning 'Windows debloat utility is already running'
        return
    }

    if (Test-OOShutUp10IsRunning) {
        Write-LogWarning 'OOShutUp10++ utility is running, which may interfere with the Windows debloat utility'
        Write-LogWarning 'Repeat the attempt after OOShutUp10++ utility has finished running'
        return
    }

    if (-not (Test-NetworkConnection)) {
        return
    }

    try {
        Set-Variable -Option Constant TargetPath ([String]"$PATH_TEMP_DIR\Win11Debloat\Config")

        New-Directory $TargetPath

        if ($UsePreset -and $Personalization) {
            Set-Variable -Option Constant Configuration ([String]($CONFIG_DEBLOAT_PRESET_PERSONALIZATION))
        } else {
            Set-Variable -Option Constant Configuration ([String]$CONFIG_DEBLOAT_PRESET_BASE)
        }

        Set-Content "$TargetPath\LastUsedSettings.json" $Configuration -NoNewline -ErrorAction Stop
    } catch {
        Write-LogWarning "Failed to initialize Windows debloat utility configuration: $_"
    }

    try {
        [String]$UsePresetParam = ''
        [String]$SilentParam = ''
        [String]$SysprepParam = ''

        if ($UsePreset -or $Personalization) {
            Set-Variable -Option Constant CustomAppsList ([String[]]($CONFIG_DEBLOAT_APP_LIST_BASE | ConvertFrom-Json | ForEach-Object { $_.AppId }))
            $UsePresetParam = "-RunSavedSettings -RemoveApps -Apps '$($CustomAppsList -join ',')'"
        }

        if ($Silent) {
            $SilentParam = '-Silent'
        }

        if ($UsePreset -and $OS_VERSION -ge 11) {
            $SysprepParam = '-Sysprep'
        }

        Set-Variable -Option Constant Params ([String]"-NoRestartExplorer $SysprepParam $UsePresetParam $SilentParam".TrimEnd())

        Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"

        Out-Success
    } catch {
        Out-Failure "Failed to start Windows debloat utility: $_"
    }
}
