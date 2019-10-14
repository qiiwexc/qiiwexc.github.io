Function Set-NiniteButtonState {
    $CBOX_StartNinite.Enabled = $BTN_DownloadNinite.Enabled = $CBOX_7zip.Checked -or $CBOX_VLC.Checked -or `
        $CBOX_TeamViewer.Checked -or $CBOX_Skype.Checked -or $CBOX_Chrome.Checked -or $CBOX_qBittorrent.Checked
}


Function Set-NiniteQuery {
    [String[]]$Array = @()
    if ($CBOX_7zip.Checked) { $Array += $CBOX_7zip.Name }
    if ($CBOX_VLC.Checked) { $Array += $CBOX_VLC.Name }
    if ($CBOX_TeamViewer.Checked) { $Array += $CBOX_TeamViewer.Name }
    if ($CBOX_Skype.Checked) { $Array += $CBOX_Skype.Name }
    if ($CBOX_Chrome.Checked) { $Array += $CBOX_Chrome.Name }
    if ($CBOX_qBittorrent.Checked) { $Array += $CBOX_qBittorrent.Name }
    Return $Array -Join '-'
}


Function Set-NiniteFileName {
    [String[]]$Array = @()
    if ($CBOX_7zip.Checked) { $Array += $CBOX_7zip.Text }
    if ($CBOX_VLC.Checked) { $Array += $CBOX_VLC.Text }
    if ($CBOX_TeamViewer.Checked) { $Array += $CBOX_TeamViewer.Text }
    if ($CBOX_Skype.Checked) { $Array += $CBOX_Skype.Text }
    if ($CBOX_Chrome.Checked) { $Array += $CBOX_Chrome.Text }
    if ($CBOX_qBittorrent.Checked) { $Array += $CBOX_qBittorrent.Text }
    Return "Ninite $($Array -Join ' ') Installer.exe"
}
