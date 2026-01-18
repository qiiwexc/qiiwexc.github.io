function Start-WindowsDebloat {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$UsePreset,
        [Switch][Parameter(Position = 1, Mandatory)]$Personalisation,
        [Switch][Parameter(Position = 2, Mandatory)]$Silent
    )

    Write-LogInfo 'Starting Windows 10/11 debloat utility...'

    Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
    if (-not $IsConnected) {
        return
    }

    try {
        Set-Variable -Option Constant TargetPath ([String]"$PATH_TEMP_DIR\Win11Debloat")

        $Null = New-Item -Force -ItemType Directory $TargetPath -ErrorAction Stop

        if ($UsePreset -and $Personalisation) {
            Set-Variable -Option Constant AppsList ([String]($CONFIG_DEBLOAT_APP_LIST + 'Microsoft.OneDrive'))
        } else {
            Set-Variable -Option Constant AppsList ([String]$CONFIG_DEBLOAT_APP_LIST)
        }

        $AppsList | Set-Content "$TargetPath\CustomAppsList" -NoNewline -ErrorAction Stop

        if ($UsePreset -and $Personalisation) {
            Set-Variable -Option Constant Configuration ([String]($CONFIG_DEBLOAT_PRESET_PERSONALISATION))
        } else {
            Set-Variable -Option Constant Configuration ([String]$CONFIG_DEBLOAT_PRESET_BASE)
        }

        $Configuration | Set-Content "$TargetPath\LastUsedSettings.json" -NoNewline -ErrorAction Stop
    } catch {
        Write-LogWarning "Failed to initialize Windows debloat utility configuration: $_"
    }

    try {
        if ($UsePreset -or $Personalisation) {
            Set-Variable -Option Constant UsePresetParam ([String]' -RunSavedSettings')
        }

        if ($Silent) {
            Set-Variable -Option Constant SilentParam ([String]' -Silent')
        }

        if ($OS_VERSION -gt 10) {
            Set-Variable -Option Constant SysprepParam ([String]' -Sysprep')
        }

        Set-Variable -Option Constant Params ([String]"-NoRestartExplorer$SysprepParam$UsePresetParam$SilentParam")

        Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"

        Out-Success
    } catch {
        Write-LogError "Failed to start Windows debloat utility: $_"
    }
}
