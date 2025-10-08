﻿function Set-VlcConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    Write-ActivityProgress -PercentComplete 5 -Task "Configuring $AppName..."

    Write-ConfigurationFile $AppName $CONFIG_VLC "$env:AppData\vlc\vlcrc"
}
