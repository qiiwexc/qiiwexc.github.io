Function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.Enabled = $BUTTON_DownloadNinite.Enabled = $CHECKBOX_7zip.Checked -or $CHECKBOX_VLC.Checked -or `
        $CHECKBOX_TeamViewer.Checked -or $CHECKBOX_Chrome.Checked -or $CHECKBOX_qBittorrent.Checked -or $CHECKBOX_Malwarebytes.Checked
}


Function Set-NiniteQuery {
    [String[]]$Array = @()
    if ($CHECKBOX_7zip.Checked) { $Array += $CHECKBOX_7zip.Name }
    if ($CHECKBOX_VLC.Checked) { $Array += $CHECKBOX_VLC.Name }
    if ($CHECKBOX_TeamViewer.Checked) { $Array += $CHECKBOX_TeamViewer.Name }
    if ($CHECKBOX_Chrome.Checked) { $Array += $CHECKBOX_Chrome.Name }
    if ($CHECKBOX_qBittorrent.Checked) { $Array += $CHECKBOX_qBittorrent.Name }
    if ($CHECKBOX_Malwarebytes.Checked) { $Array += $CHECKBOX_Malwarebytes.Name }
    Return $Array -Join '-'
}


Function Set-NiniteFileName {
    [String[]]$Array = @()
    if ($CHECKBOX_7zip.Checked) { $Array += $CHECKBOX_7zip.Text }
    if ($CHECKBOX_VLC.Checked) { $Array += $CHECKBOX_VLC.Text }
    if ($CHECKBOX_TeamViewer.Checked) { $Array += $CHECKBOX_TeamViewer.Text }
    if ($CHECKBOX_Chrome.Checked) { $Array += $CHECKBOX_Chrome.Text }
    if ($CHECKBOX_qBittorrent.Checked) { $Array += $CHECKBOX_qBittorrent.Text }
    if ($CHECKBOX_Malwarebytes.Checked) { $Array += $CHECKBOX_Malwarebytes.Text }
    Return "Ninite $($Array -Join ' ') Installer.exe"
}
