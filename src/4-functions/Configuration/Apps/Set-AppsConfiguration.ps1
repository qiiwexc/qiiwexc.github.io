function Set-AppsConfiguration {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$7zip,
        [Object][Parameter(Position = 1, Mandatory)]$VLC,
        [Object][Parameter(Position = 2, Mandatory)]$AnyDesk,
        [Object][Parameter(Position = 3, Mandatory)]$qBittorrent,
        [Object][Parameter(Position = 4, Mandatory)]$Edge,
        [Object][Parameter(Position = 5, Mandatory)]$Chrome
    )

    New-Activity 'Configuring apps'

    if ($7zip.IsChecked) {
        Write-ActivityProgress 11 "Applying configuration to $($7zip.Tag)..."
        Set-7zipConfiguration $7zip.Tag
    }

    if ($VLC.IsChecked) {
        Write-ActivityProgress 22 "Applying configuration to $($VLC.Tag)..."
        Set-VlcConfiguration $VLC.Tag
    }

    if ($AnyDesk.IsChecked) {
        Write-ActivityProgress 33 "Applying configuration to $($AnyDesk.Tag)..."
        Set-AnyDeskConfiguration $AnyDesk.Tag
    }

    if ($qBittorrent.IsChecked) {
        Write-ActivityProgress 44 "Applying configuration to $($qBittorrent.Tag)..."
        Set-qBittorrentConfiguration $qBittorrent.Tag
    }

    if ($Edge.IsChecked) {
        Write-ActivityProgress 55 "Applying configuration to $($Edge.Tag)..."
        Set-MicrosoftEdgeConfiguration $Edge.Tag
    }

    if ($Chrome.IsChecked) {
        Write-ActivityProgress 77 "Applying configuration to $($Chrome.Tag)..."
        Set-GoogleChromeConfiguration $Chrome.Tag
    }

    Write-ActivityCompleted
}
