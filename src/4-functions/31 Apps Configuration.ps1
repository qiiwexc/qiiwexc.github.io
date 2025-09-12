Function Set-AppsConfiguration {
    if ($CHECKBOX_Config_7zip.Checked) {
        Set-Content "$PATH_TEMP_DIR\$($CHECKBOX_Config_7zip.Text).reg" $CONFIG_7ZIP
    }

    if ($CHECKBOX_Config_VLC.Checked) {
        Set-Content "$PATH_TEMP_DIR\vlcrc" $CONFIG_VLC
    }

    if ($CHECKBOX_Config_TeamViewer.Checked) {
        Set-Content "$PATH_TEMP_DIR\$($CHECKBOX_Config_TeamViewer.Text).reg" $CONFIG_TEAMVIEWER
        $CONFIG_TEAMVIEWER
    }

    if ($CHECKBOX_Config_qBittorrent.Checked) {
        $CONFIG_QBITTORRENT = $CONFIG_QBITTORRENT_BASE + $(if ($SYSTEM_LANGUAGE -Match 'ru') { $CONFIG_QBITTORRENT_RUSSIAN } else { $CONFIG_QBITTORRENT_ENGLISH })
        Set-Content "$PATH_TEMP_DIR\$($CHECKBOX_Config_qBittorrent.Text).ini" $CONFIG_QBITTORRENT
    }

    if ($CHECKBOX_Config_Chrome.Checked) {
        # $CONFIG_CHROME
    }
}
