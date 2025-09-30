function Start-WindowsDebloat {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$UsePreset,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$Personalisation,
        [Switch][Parameter(Position = 2, Mandatory = $True)]$Silent
    )

    Write-LogInfo 'Starting Windows 10/11 debloat utility...'

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    Set-Variable -Option Constant TargetPath "$PATH_TEMP_DIR\Win11Debloat"

    New-Item -Force -ItemType Directory $TargetPath | Out-Null

    Set-Variable -Option Constant CustomAppsListFile "$TargetPath\CustomAppsList"
    Set-Variable -Option Constant AppsList ($CONFIG_DEBLOAT_APP_LIST + $(if ($Personalisation) { 'Microsoft.OneDrive' } else { '' }))
    $AppsList | Out-File $CustomAppsListFile -Encoding UTF8

    Set-Variable -Option Constant SavedSettingsFile "$TargetPath\SavedSettings"
    Set-Variable -Option Constant Configuration ($CONFIG_DEBLOAT_PRESET_BASE + $(if ($Personalisation) { $CONFIG_DEBLOAT_PRESET_PERSONALISATION } else { '' }))
    $Configuration | Out-File $SavedSettingsFile -Encoding UTF8

    Set-Variable -Option Constant UsePresetParam $(if ($UsePreset) { '-RunSavedSettings' } else { '' })
    Set-Variable -Option Constant SilentParam $(if ($Silent) { '-Silent' } else { '' })
    Set-Variable -Option Constant Params "-Sysprep $UsePresetParam $SilentParam"

    Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"

    Out-Success
}
