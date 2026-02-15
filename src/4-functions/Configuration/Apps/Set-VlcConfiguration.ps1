function Set-VlcConfiguration {
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName
    )

    try {
        Write-ConfigurationFile $AppName $CONFIG_VLC -Path "$env:AppData\vlc\vlcrc"
        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
