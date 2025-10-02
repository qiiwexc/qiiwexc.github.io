function Set-AppsConfiguration {
    param(
        [System.Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory = $True)]$7zip,
        [System.Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory = $True)]$VLC,
        [System.Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory = $True)]$TeamViewer,
        [System.Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory = $True)]$qBittorrent,
        [System.Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory = $True)]$Edge,
        [System.Windows.Forms.CheckBox][Parameter(Position = 5, Mandatory = $True)]$Chrome
    )

    if ($VLC.Checked) {
        Set-VlcConfiguration $VLC.Text
    }

    if ($qBittorrent.Checked) {
        Set-qBittorrentConfiguration $qBittorrent.Text
    }

    if ($7zip.Checked) {
        Import-RegistryConfiguration $7zip.Text $CONFIG_7ZIP
    }

    if ($TeamViewer.Checked) {
        Import-RegistryConfiguration $TeamViewer.Text $CONFIG_TEAMVIEWER
    }

    if ($Edge.Checked) {
        Set-MicrosoftEdgeConfiguration $Edge.Text
    }

    if ($Chrome.Checked) {
        Set-GoogleChromeConfiguration $Chrome.Text
    }
}
