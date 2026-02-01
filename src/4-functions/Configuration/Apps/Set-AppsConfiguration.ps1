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
        Write-ActivityProgress 11 "Applying configuration to $($7zip.Text)..."
        Set-7zipConfiguration $7zip.Text
    }

    if ($VLC.Checked) {
        Write-ActivityProgress 22 "Applying configuration to $($VLC.Text)..."
        Set-VlcConfiguration $VLC.Text
    }

    if ($AnyDesk.Checked) {
        Write-ActivityProgress 33 "Applying configuration to $($AnyDesk.Text)..."
        Set-AnyDeskConfiguration $AnyDesk.Text
    }

    if ($qBittorrent.Checked) {
        Write-ActivityProgress 44 "Applying configuration to $($qBittorrent.Text)..."
        Set-qBittorrentConfiguration $qBittorrent.Text
    }

    if ($Edge.Checked) {
        Write-ActivityProgress 55 "Applying configuration to $($Edge.Text)..."
        Set-MicrosoftEdgeConfiguration $Edge.Text
    }

    if ($Chrome.Checked) {
        Write-ActivityProgress 77 "Applying configuration to $($Chrome.Text)..."
        Set-GoogleChromeConfiguration $Chrome.Text
    }

    Write-ActivityCompleted
}
