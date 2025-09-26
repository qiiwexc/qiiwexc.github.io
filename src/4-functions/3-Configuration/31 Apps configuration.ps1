function Set-VlcConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    Write-ConfigurationFile $AppName $CONFIG_VLC "$env:AppData\vlc\vlcrc"
}


function Set-qBittorrentConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    Set-Variable -Option Constant Content ($CONFIG_QBITTORRENT_BASE + $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_QBITTORRENT_RUSSIAN } else { $CONFIG_QBITTORRENT_ENGLISH }))
    Write-ConfigurationFile $AppName $Content "$env:AppData\$AppName\$AppName.ini"
}


function Set-MicrosoftEdgeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    Set-Variable -Option Constant ProcessName 'msedge'

    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$env:LocalAppData\Microsoft\Edge\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$env:LocalAppData\Microsoft\Edge\User Data\Default\Preferences"
}


function Set-GoogleChromeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    Set-Variable -Option Constant ProcessName 'chrome'

    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$env:LocalAppData\Google\Chrome\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"
}
