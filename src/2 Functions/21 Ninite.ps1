function HandleNiniteCheckBoxStateChange () {
    $BTN_NiniteDownload.Enabled = $CBOX_Ninite7zip.Checked -or $CBOX_NiniteVLC.Checked -or $CBOX_NiniteTeamViewer.Checked -or $CBOX_NiniteSkype.Checked -or `
        $CBOX_NiniteChrome.Checked -or $CBOX_NiniteqBittorrent.Checked -or $CBOX_NiniteGoogleDrive.Checked -or $CBOX_NiniteVSC.Checked
    $CBOX_NiniteExecute.Enabled = $BTN_NiniteDownload.Enabled
}


function NiniteQueryBuilder () {
    $Array = @()
    if ($CBOX_Ninite7zip.Checked) {$Array += $CBOX_Ninite7zip.Name}
    if ($CBOX_NiniteVLC.Checked) {$Array += $CBOX_NiniteVLC.Name}
    if ($CBOX_NiniteTeamViewer.Checked) {$Array += $CBOX_NiniteTeamViewer.Name}
    if ($CBOX_NiniteSkype.Checked) {$Array += $CBOX_NiniteSkype.Name}
    if ($CBOX_NiniteChrome.Checked) {$Array += $CBOX_NiniteChrome.Name}
    if ($CBOX_NiniteqBittorrent.Checked) {$Array += $CBOX_NiniteqBittorrent.Name}
    if ($CBOX_NiniteGoogleDrive.Checked) {$Array += $CBOX_NiniteGoogleDrive.Name}
    if ($CBOX_NiniteVSC.Checked) {$Array += $CBOX_NiniteVSC.Name}
    return $Array -join '-'
}


function NiniteNameBuilder () {
    $Array = @()
    if ($CBOX_Ninite7zip.Checked) {$Array += $CBOX_Ninite7zip.Text}
    if ($CBOX_NiniteVLC.Checked) {$Array += $CBOX_NiniteVLC.Text}
    if ($CBOX_NiniteTeamViewer.Checked) {$Array += $CBOX_NiniteTeamViewer.Text}
    if ($CBOX_NiniteSkype.Checked) {$Array += $CBOX_NiniteSkype.Text}
    if ($CBOX_NiniteChrome.Checked) {$Array += $CBOX_NiniteChrome.Text}
    if ($CBOX_NiniteqBittorrent.Checked) {$Array += $CBOX_NiniteqBittorrent.Text}
    if ($CBOX_NiniteGoogleDrive.Checked) {$Array += $CBOX_NiniteGoogleDrive.Text}
    if ($CBOX_NiniteVSC.Checked) {$Array += $CBOX_NiniteVSC.Text}
    return "Ninite $($Array -join ' ') Installer.exe"
}
