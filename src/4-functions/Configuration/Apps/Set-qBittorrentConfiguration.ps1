function Set-qBittorrentConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        Write-ActivityProgress -PercentComplete 15 -Task "Configuring $AppName..."


        if ($SYSTEM_LANGUAGE -match 'ru') {
            Set-Variable -Option Constant Content ([String]($CONFIG_QBITTORRENT_BASE + $CONFIG_QBITTORRENT_RUSSIAN))
        } else {
            Set-Variable -Option Constant Content ([String]($CONFIG_QBITTORRENT_BASE + $CONFIG_QBITTORRENT_ENGLISH))
        }

        Write-ConfigurationFile $AppName $Content "$env:AppData\$AppName\$AppName.ini"
    } catch [Exception] {
        Write-LogException $_ "Failed to configure $AppName"
    }
}
