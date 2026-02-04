function Set-AppsConfiguration {
    param(
        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$7zip,
        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$VLC,
        [Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory)]$AnyDesk,
        [Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory)]$qBittorrent,
        [Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory)]$Edge,
        [Windows.Forms.CheckBox][Parameter(Position = 5, Mandatory)]$Chrome
    )

    New-Activity 'Configuring apps'

    if ($7zip.Checked) {
        Write-ActivityProgress 11 "Applying configuration to $($7zip.Name)..."
        Set-7zipConfiguration $7zip.Name
    }

    if ($VLC.Checked) {
        Write-ActivityProgress 22 "Applying configuration to $($VLC.Name)..."
        Set-VlcConfiguration $VLC.Name
    }

    if ($AnyDesk.Checked) {
        Write-ActivityProgress 33 "Applying configuration to $($AnyDesk.Name)..."
        Set-AnyDeskConfiguration $AnyDesk.Name
    }

    if ($qBittorrent.Checked) {
        Write-ActivityProgress 44 "Applying configuration to $($qBittorrent.Name)..."
        Set-qBittorrentConfiguration $qBittorrent.Name
    }

    if ($Edge.Checked) {
        Write-ActivityProgress 55 "Applying configuration to $($Edge.Name)..."
        Set-MicrosoftEdgeConfiguration $Edge.Name
    }

    if ($Chrome.Checked) {
        Write-ActivityProgress 77 "Applying configuration to $($Chrome.Name)..."
        Set-GoogleChromeConfiguration $Chrome.Name
    }

    Write-ActivityCompleted
}
