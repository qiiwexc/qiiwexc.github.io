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

    if ($CHECKBOX_Config_Edge.Checked) {
        $AppName = $CHECKBOX_Config_Edge.Text

        $Path = "$PATH_PROFILE_LOCAL\Microsoft\Edge\User Data\Local State"
        Update-JsonFile $AppName $Path $CONFIG_EDGE_LOCAL_STATE "msedge"

        $Path = "$PATH_PROFILE_LOCAL\Microsoft\Edge\User Data\Default\Preferences"
        Update-JsonFile $AppName $Path $CONFIG_EDGE_PREFERENCES "msedge"
    }

    if ($CHECKBOX_Config_Chrome.Checked) {
        $AppName = $CHECKBOX_Config_Chrome.Text

        $Path = "$PATH_PROFILE_LOCAL\Google\Chrome\User Data\Local State"
        Update-JsonFile $AppName $Path $CONFIG_CHROME_LOCAL_STATE "chrome"

        $Path = "$PATH_PROFILE_LOCAL\Google\Chrome\User Data\Default\Preferences"
        Update-JsonFile $AppName $Path $CONFIG_CHROME_PREFERENCES "chrome"
    }
}
