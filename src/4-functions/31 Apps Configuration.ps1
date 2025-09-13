Function Write-ConfigurationFile {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Path,
        [String][Parameter(Position = 2, Mandatory = $True)]$Content
    )

    Add-Log $INF "Writing $AppName configuration to '$Path'..."

    Set-Content $Path $Content

    Out-Success
}


Function Update-JsonFile {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Path,
        [String][Parameter(Position = 2, Mandatory = $True)]$Content
    )

    Add-Log $INF "Writing $AppName configuration to '$Path'..."

    $CurrentConfig = Get-Content $Path -Raw | ConvertFrom-Json
    $PatchConfig = $Content | ConvertFrom-Json

    $UpdatedConfig = Merge-JsonObjects $CurrentConfig $PatchConfig | ConvertTo-Json -Depth 100 -Compress

    Set-Content $Path $UpdatedConfig

    Out-Success
}


Function Import-RegistryConfiguration {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Content
    )

    Add-Log $INF "Importing $AppName configuration into registry..."

    Set-Variable -Option Constant RegFilePath "$PATH_TEMP_DIR\$AppName.reg"
    Set-Content $RegFilePath $Content

    try {
        Start-Process -Verb RunAs -Wait 'regedit' "/s $RegFilePath"
    } catch [Exception] {
        Add-Log $ERR "Failed to import file: $($_.Exception.Message)"
        Return
    }

    Out-Success
}


Function Set-AppsConfiguration {
    if ($CHECKBOX_Config_VLC.Checked) {
        $AppName = $CHECKBOX_Config_VLC.Text
        $Path = "$PATH_PROFILE_ROAMING\vlc\vlcrc"
        $Content = $CONFIG_VLC
        Write-ConfigurationFile $AppName $Path $Content
    }

    if ($CHECKBOX_Config_qBittorrent.Checked) {
        $AppName = $CHECKBOX_Config_qBittorrent.Text
        $Path = "$PATH_PROFILE_ROAMING\$AppName\$AppName.ini"
        $Content = $CONFIG_QBITTORRENT_BASE + $(if ($SYSTEM_LANGUAGE -Match 'ru') { $CONFIG_QBITTORRENT_RUSSIAN } else { $CONFIG_QBITTORRENT_ENGLISH })
        Write-ConfigurationFile $AppName $Path $Content
    }

    if ($CHECKBOX_Config_7zip.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_7zip.Text $CONFIG_7ZIP
    }

    if ($CHECKBOX_Config_TeamViewer.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_TeamViewer.Text $CONFIG_TEAMVIEWER
    }

    if ($CHECKBOX_Config_Chrome.Checked) {
        $AppName = $CHECKBOX_Config_Chrome.Text

        $Path = "$PATH_PROFILE_LOCAL\Google\Chrome\User Data\Local State"
        Update-JsonFile $AppName $Path $CONFIG_CHROME_LOCAL_STATE

        $Path = "$PATH_PROFILE_LOCAL\Google\Chrome\User Data\Default\Preferences"
        Update-JsonFile $AppName $Path $CONFIG_CHROME_PREFERENCES
    }
}
