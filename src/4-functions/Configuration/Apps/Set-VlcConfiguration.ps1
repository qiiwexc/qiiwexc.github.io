function Set-VlcConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        Write-ActivityProgress -PercentComplete 5 -Task "Configuring $AppName..."

        Write-ConfigurationFile $AppName $CONFIG_VLC "$env:AppData\vlc\vlcrc"
    } catch [Exception] {
        Write-LogException $_ "Failed to configure $AppName"
    }
}
