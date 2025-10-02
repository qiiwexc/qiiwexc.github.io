function Set-qBittorrentConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    Set-Variable -Option Constant Content ($CONFIG_QBITTORRENT_BASE + $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_QBITTORRENT_RUSSIAN } else { $CONFIG_QBITTORRENT_ENGLISH }))
    Write-ConfigurationFile $AppName $Content "$env:AppData\$AppName\$AppName.ini"
}
