function Set-AppsConfiguration {
    if ($CHECKBOX_Config_VLC.Checked) {
        Set-VlcConfiguration $CHECKBOX_Config_VLC.Text
    }

    if ($CHECKBOX_Config_qBittorrent.Checked) {
        Set-qBittorrentConfiguration $CHECKBOX_Config_qBittorrent.Text
    }

    if ($CHECKBOX_Config_7zip.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_7zip.Text $CONFIG_7ZIP
    }

    if ($CHECKBOX_Config_TeamViewer.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_TeamViewer.Text $CONFIG_TEAMVIEWER
    }

    if ($CHECKBOX_Config_Edge.Checked) {
        Set-MicrosoftEdgeConfiguration $CHECKBOX_Config_Edge.Text
    }

    if ($CHECKBOX_Config_Chrome.Checked) {
        Set-GoogleChromeConfiguration $CHECKBOX_Config_Chrome.Text
    }
}
