function Set-NiniteButtonState () {
    $BTN_DownloadNinite.Enabled = $CBOX_7zip.Checked -or $CBOX_VLC.Checked -or $CBOX_TeamViewer.Checked -or $CBOX_Skype.Checked -or `
        $CBOX_Chrome.Checked -or $CBOX_qBittorrent.Checked -or $CBOX_GoogleDrive.Checked -or $CBOX_VSCode.Checked
    $CBOX_ExecuteNinite.Enabled = $BTN_DownloadNinite.Enabled
}


function Build-NiniteQuery () {
    $Array = @()
    if ($CBOX_7zip.Checked) {$Array += $CBOX_7zip.Name}
    if ($CBOX_VLC.Checked) {$Array += $CBOX_VLC.Name}
    if ($CBOX_TeamViewer.Checked) {$Array += $CBOX_TeamViewer.Name}
    if ($CBOX_Skype.Checked) {$Array += $CBOX_Skype.Name}
    if ($CBOX_Chrome.Checked) {$Array += $CBOX_Chrome.Name}
    if ($CBOX_qBittorrent.Checked) {$Array += $CBOX_qBittorrent.Name}
    if ($CBOX_GoogleDrive.Checked) {$Array += $CBOX_GoogleDrive.Name}
    if ($CBOX_VSCode.Checked) {$Array += $CBOX_VSCode.Name}
    return $Array -Join '-'
}


function Build-NiniteFileName () {
    $Array = @()
    if ($CBOX_7zip.Checked) {$Array += $CBOX_7zip.Text}
    if ($CBOX_VLC.Checked) {$Array += $CBOX_VLC.Text}
    if ($CBOX_TeamViewer.Checked) {$Array += $CBOX_TeamViewer.Text}
    if ($CBOX_Skype.Checked) {$Array += $CBOX_Skype.Text}
    if ($CBOX_Chrome.Checked) {$Array += $CBOX_Chrome.Text}
    if ($CBOX_qBittorrent.Checked) {$Array += $CBOX_qBittorrent.Text}
    if ($CBOX_GoogleDrive.Checked) {$Array += $CBOX_GoogleDrive.Text}
    if ($CBOX_VSCode.Checked) {$Array += $CBOX_VSCode.Text}
    return "Ninite $($Array -Join ' ') Installer.exe"
}
