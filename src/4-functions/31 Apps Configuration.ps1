function Set-VlcConfiguration {
    Set-Variable -Option Constant AppName $CHECKBOX_Config_VLC.Text
    Write-ConfigurationFile $AppName $CONFIG_VLC "$env:AppData\vlc\vlcrc"
}


function Set-qBittorrentConfiguration {
    Set-Variable -Option Constant AppName $CHECKBOX_Config_qBittorrent.Text
    Set-Variable -Option Constant Content ($CONFIG_QBITTORRENT_BASE + $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_QBITTORRENT_RUSSIAN } else { $CONFIG_QBITTORRENT_ENGLISH }))
    Write-ConfigurationFile $AppName $Content "$env:AppData\$AppName\$AppName.ini"
}


function Set-MicrosoftEdgeConfiguration {
    Set-Variable -Option Constant AppName $CHECKBOX_Config_Edge.Text
    Set-Variable -Option Constant ProcessName 'msedge'

    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$env:LocalAppData\Microsoft\Edge\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$env:LocalAppData\Microsoft\Edge\User Data\Default\Preferences"
}


function Set-GoogleChromeConfiguration {
    Set-Variable -Option Constant AppName $CHECKBOX_Config_Chrome.Text
    Set-Variable -Option Constant ProcessName 'chrome'

    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$env:LocalAppData\Google\Chrome\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"
}
