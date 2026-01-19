function Set-VlcConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        Write-ActivityProgress 24 "Configuring $AppName..."

        Write-ConfigurationFile $AppName $CONFIG_VLC "$env:AppData\vlc\vlcrc"
    } catch {
        Write-LogError "Failed to configure '$AppName': $_"
    }
}
