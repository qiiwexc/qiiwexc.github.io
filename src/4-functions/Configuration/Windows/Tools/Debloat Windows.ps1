function Start-WindowsDebloat {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$UsePreset,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
    )

    Write-LogInfo 'Starting Windows 10/11 debloat utility...'

    Set-Variable -Option Constant TargetPath "$PATH_TEMP_DIR\Win11Debloat"
    New-Item -ItemType Directory $TargetPath -ErrorAction SilentlyContinue

    Set-Variable -Option Constant CustomAppsListFile "$TargetPath\CustomAppsList"
    $CONFIG_DEBLOAT_APP_LIST | Out-File $CustomAppsListFile

    Set-Variable -Option Constant SavedSettingsFile "$TargetPath\SavedSettings"
    $CONFIG_DEBLOAT_PRESET | Out-File $SavedSettingsFile

    Set-Variable -Option Constant UsePresetParam $(if ($UsePreset) { '-RunSavedSettings' } else { '' })
    Set-Variable -Option Constant SilentParam $(if ($Silent) { '-Silent' } else { '' })
    Set-Variable -Option Constant Params "-Sysprep $UsePresetParam $SilentParam"

    Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"

    Out-Success
}
