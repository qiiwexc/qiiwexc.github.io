function Set-qBittorrentConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        if ($SYSTEM_LANGUAGE -match 'ru') {
            Set-Variable -Option Constant Content ([String]($CONFIG_QBITTORRENT_BASE + $CONFIG_QBITTORRENT_RUSSIAN))
        } else {
            Set-Variable -Option Constant Content ([String]($CONFIG_QBITTORRENT_BASE + $CONFIG_QBITTORRENT_ENGLISH))
        }

        Write-ConfigurationFile $AppName $Content -Path "$env:AppData\$AppName\$AppName.ini"

        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
