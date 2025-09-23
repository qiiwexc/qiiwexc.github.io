Function Start-WindowsDebloat {
    Write-Log $INF 'Starting Windows 10/11 debloat utility...'

    Set-Variable -Option Constant TargetPath "$PATH_TEMP_DIR\Win11Debloat"
    New-Item -ItemType Directory $TargetPath -ErrorAction SilentlyContinue

    Set-Variable -Option Constant CustomAppsListFile "$TargetPath\CustomAppsList"
    $CONFIG_DEBLOAT_APP_LIST | Out-File $CustomAppsListFile

    Set-Variable -Option Constant SavedSettingsFile "$TargetPath\SavedSettings"
    $CONFIG_DEBLOAT | Out-File $SavedSettingsFile

    Set-Variable -Option Constant UsePresetParam $(if ($CHECKBOX_UseDebloatPreset.Checked) { '-RunSavedSettings' } else { '' })
    Set-Variable -Option Constant SilentParam $(if ($CHECKBOX_SilentlyRunDebloat.Checked) { '-Silent' } else { '' })
    Set-Variable -Option Constant Params "-Sysprep $UsePresetParam $SilentParam"

    Start-Script -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"

    Out-Success
}


Function Start-ShutUp10 {
    Param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
    )

    Write-Log $INF 'Starting ShutUp10++ utility...'

    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_APP_DIR } else { $PATH_CURRENT_DIR })
    Set-Variable -Option Constant ConfigFile "$TargetPath\ooshutup10.cfg"

    $CONFIG_SHUTUP10 | Out-File $ConfigFile

    if ($Silent) {
        Start-DownloadExtractExecute -Execute:$Execute '{URL_SHUTUP10}' -Params $ConfigFile
    } else {
        Start-DownloadExtractExecute -Execute:$Execute '{URL_SHUTUP10}'
    }
}
