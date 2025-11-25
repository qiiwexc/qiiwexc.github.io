function Start-WindowsDebloat {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$UsePreset,
        [Switch][Parameter(Position = 1, Mandatory)]$Personalisation,
        [Switch][Parameter(Position = 2, Mandatory)]$Silent
    )

    Write-LogInfo 'Starting Windows 10/11 debloat utility...'

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    Set-Variable -Option Constant TargetPath "$PATH_TEMP_DIR\Win11Debloat"

    New-Item -Force -ItemType Directory $TargetPath | Out-Null

    if ($Personalisation) {
        Set-Variable -Option Constant AppsList ($CONFIG_DEBLOAT_APP_LIST + 'Microsoft.OneDrive')
    } else {
        Set-Variable -Option Constant AppsList $CONFIG_DEBLOAT_APP_LIST
    }

    $AppsList | Out-File "$TargetPath\CustomAppsList" -Encoding UTF8

    if ($Personalisation) {
        Set-Variable -Option Constant Configuration ($CONFIG_DEBLOAT_PRESET_BASE + $CONFIG_DEBLOAT_PRESET_PERSONALISATION)
    } else {
        Set-Variable -Option Constant Configuration $CONFIG_DEBLOAT_PRESET_BASE
    }

    $Configuration | Out-File "$TargetPath\SavedSettings" -Encoding UTF8

    if ($UsePreset) {
        Set-Variable -Option Constant UsePresetParam '-RunSavedSettings'
    }

    if ($Silent) {
        Set-Variable -Option Constant SilentParam '-Silent'
    }

    if ($OS_VERSION -gt 10) {
        Set-Variable -Option Constant SysprepParam '-Sysprep'
    }

    Set-Variable -Option Constant Params "-NoRestartExplorer $SysprepParam $UsePresetParam $SilentParam"

    Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"

    Out-Success
}
