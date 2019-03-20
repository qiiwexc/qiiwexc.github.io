function HandleNiniteCheckBoxStateChange () {
    $ButtonNiniteDownload.Enabled = $CheckBoxNinite7zip.Checked -or $CheckBoxNiniteVLC.Checked -or `
        $CheckBoxNiniteTeamViewer.Checked -or $CheckBoxNiniteSkype.Checked -or $CheckBoxNiniteChrome.Checked -or `
        $CheckBoxNiniteqBittorrent.Checked -or $CheckBoxNiniteGoogleDrive.Checked -or $CheckBoxNiniteVSC.Checked
    $CheckBoxNiniteExecute.Enabled = $ButtonNiniteDownload.Enabled
}


function NiniteQueryBuilder () {
    $Array = @()
    if ($CheckBoxNinite7zip.Checked) {$Array += $CheckBoxNinite7zip.Name}
    if ($CheckBoxNiniteVLC.Checked) {$Array += $CheckBoxNiniteVLC.Name}
    if ($CheckBoxNiniteTeamViewer.Checked) {$Array += $CheckBoxNiniteTeamViewer.Name}
    if ($CheckBoxNiniteSkype.Checked) {$Array += $CheckBoxNiniteSkype.Name}
    if ($CheckBoxNiniteChrome.Checked) {$Array += $CheckBoxNiniteChrome.Name}
    if ($CheckBoxNiniteqBittorrent.Checked) {$Array += $CheckBoxNiniteqBittorrent.Name}
    if ($CheckBoxNiniteGoogleDrive.Checked) {$Array += $CheckBoxNiniteGoogleDrive.Name}
    if ($CheckBoxNiniteVSC.Checked) {$Array += $CheckBoxNiniteVSC.Name}
    return $Array -join '-'
}


function NiniteNameBuilder () {
    $Array = @()
    if ($CheckBoxNinite7zip.Checked) {$Array += $CheckBoxNinite7zip.Text}
    if ($CheckBoxNiniteVLC.Checked) {$Array += $CheckBoxNiniteVLC.Text}
    if ($CheckBoxNiniteTeamViewer.Checked) {$Array += $CheckBoxNiniteTeamViewer.Text}
    if ($CheckBoxNiniteSkype.Checked) {$Array += $CheckBoxNiniteSkype.Text}
    if ($CheckBoxNiniteChrome.Checked) {$Array += $CheckBoxNiniteChrome.Text}
    if ($CheckBoxNiniteqBittorrent.Checked) {$Array += $CheckBoxNiniteqBittorrent.Text}
    if ($CheckBoxNiniteGoogleDrive.Checked) {$Array += $CheckBoxNiniteGoogleDrive.Text}
    if ($CheckBoxNiniteVSC.Checked) {$Array += $CheckBoxNiniteVSC.Text}
    return "Ninite $($Array -join ' ') Installer.exe"
}
