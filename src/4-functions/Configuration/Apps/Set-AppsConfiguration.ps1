function Set-AppsConfiguration {
    param(
        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$7zip,
        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$VLC,
        [Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory)]$TeamViewer,
        [Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory)]$qBittorrent,
        [Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory)]$Edge,
        [Windows.Forms.CheckBox][Parameter(Position = 5, Mandatory)]$Chrome
    )

    New-Activity 'Configuring apps...'

    if ($VLC.Checked) {
        Set-VlcConfiguration $VLC.Text
    }

    if ($qBittorrent.Checked) {
        Set-qBittorrentConfiguration $qBittorrent.Text
    }

    if ($7zip.Checked) {
        Set-7zipConfiguration $7zip.Text
    }

    if ($TeamViewer.Checked) {
        Set-TeamViewerConfiguration $TeamViewer.Text
    }

    if ($Edge.Checked) {
        Set-MicrosoftEdgeConfiguration $Edge.Text
    }

    if ($Chrome.Checked) {
        Set-GoogleChromeConfiguration $Chrome.Text
    }

    Write-ActivityCompleted
}
