function Set-AppsConfiguration {
    param(
        [Parameter(Position = 0, Mandatory)][Object]$7zip,
        [Parameter(Position = 1, Mandatory)][Object]$VLC,
        [Parameter(Position = 2, Mandatory)][Object]$AnyDesk,
        [Parameter(Position = 3, Mandatory)][Object]$qBittorrent,
        [Parameter(Position = 4, Mandatory)][Object]$Edge,
        [Parameter(Position = 5, Mandatory)][Object]$Chrome
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
