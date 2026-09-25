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

    # Where the project's own launcher puts it too, so the registry backups of earlier runs stay where
    # the tool's window looks for them
    Set-Variable -Option Constant ToolPath ([String]"$($PATH_TEMP_DIR)Win11Debloat")

    try {
        # The release pinned in dependencies.json, checked against its recorded checksum, rather than
        # whatever the project's launcher fetches at the moment of the click. GitHub builds the archive
        # on request and sends no length for it, which BITS needs
        Set-Variable -Option Constant ZipPath ([String](Start-Download '{URL_WIN11DEBLOAT}' 'Win11Debloat.zip' -Sha256 '{SHA256_WIN11DEBLOAT}' -Temp -NoBits))
        Set-Variable -Option Constant ScriptPath ([String](Expand-WindowsDebloat $ZipPath $ToolPath))
    } catch {
        Out-Failure "Failed to prepare Windows debloat utility: $_"
        return
    }

    try {
        Set-Variable -Option Constant ConfigPath ([String]"$ToolPath\Config")

        New-Directory $ConfigPath

        if ($UsePreset -and $Personalization) {
            Set-Variable -Option Constant Configuration ([String]($CONFIG_DEBLOAT_PRESET_PERSONALIZATION))
        } else {
            Set-Variable -Option Constant Configuration ([String]$CONFIG_DEBLOAT_PRESET_BASE)
        }

        Set-Content "$ConfigPath\LastUsedSettings.json" $Configuration -NoNewline -ErrorAction Stop
    } catch {
        Write-LogWarning "Failed to initialize Windows debloat utility configuration: $_"
    }

    try {
        [String]$UsePresetParam = ''
        [String]$SilentParam = ''
        [String]$SysprepParam = ''

        if ($UsePreset -or $Personalization) {
            Set-Variable -Option Constant CustomAppsList ([String[]]($CONFIG_DEBLOAT_APP_LIST_BASE | ConvertFrom-Json | ForEach-Object { $_.AppId }))
            # Double quotes: PowerShell's -File passes single quotes on as part of the value
            $UsePresetParam = "-RunSavedSettings -RemoveApps -Apps `"$($CustomAppsList -join ',')`""
        }

        if ($Silent) {
            $SilentParam = '-Silent'
        }

        if ($UsePreset -and $OS_VERSION -ge 11) {
            $SysprepParam = '-Sysprep'
        }

        Set-Variable -Option Constant Params ([String]"-SkipExplorerRestart $SysprepParam $UsePresetParam $SilentParam".TrimEnd())

        # A window of its own, as it can ask for input. The app is elevated, so Win11Debloat runs in this
        # process rather than relaunching itself, and Test-WindowsDebloatIsRunning finds it by its path
        Start-Process "$PATH_SYSTEM_32\WindowsPowerShell\v1.0\powershell.exe" "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" $Params" -ErrorAction Stop

        Out-Success
    } catch {
        Out-Failure "Failed to start Windows debloat utility: $_"
    }
}
