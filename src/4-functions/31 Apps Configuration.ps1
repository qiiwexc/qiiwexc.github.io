Function Set-VlcConfiguration {
    Set-Variable -Option Constant AppName $CHECKBOX_Config_VLC.Text
    Write-ConfigurationFile $AppName $CONFIG_VLC "$PATH_PROFILE_ROAMING\vlc\vlcrc"
}


Function Set-qBittorrentConfiguration {
    Set-Variable -Option Constant AppName $CHECKBOX_Config_qBittorrent.Text
    Set-Variable -Option Constant Content ($CONFIG_QBITTORRENT_BASE + $(if ($SYSTEM_LANGUAGE -Match 'ru') { $CONFIG_QBITTORRENT_RUSSIAN } else { $CONFIG_QBITTORRENT_ENGLISH }))
    Write-ConfigurationFile $AppName $Content "$PATH_PROFILE_ROAMING\$AppName\$AppName.ini"
}


Function Set-MicrosoftEdgeConfiguration {
    Set-Variable -Option Constant AppName $CHECKBOX_Config_Edge.Text
    Set-Variable -Option Constant ProcessName 'msedge'

    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$PATH_PROFILE_LOCAL\Microsoft\Edge\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$PATH_PROFILE_LOCAL\Microsoft\Edge\User Data\Default\Preferences"
}


Function Set-GoogleChromeConfiguration {
    Set-Variable -Option Constant AppName $CHECKBOX_Config_Chrome.Text
    Set-Variable -Option Constant ProcessName 'chrome'

    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$PATH_PROFILE_LOCAL\Google\Chrome\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$PATH_PROFILE_LOCAL\Google\Chrome\User Data\Default\Preferences"
}
