Function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.Enabled = $BUTTON_DownloadNinite.Enabled = $CHECKBOX_Ninite_7zip.Checked -or $CHECKBOX_Ninite_VLC.Checked -or `
        $CHECKBOX_Ninite_TeamViewer.Checked -or $CHECKBOX_Ninite_Chrome.Checked -or $CHECKBOX_Ninite_qBittorrent.Checked -or $CHECKBOX_Ninite_Malwarebytes.Checked
}


Function Set-NiniteQuery {
    [String[]]$Array = @()
    if ($CHECKBOX_Ninite_7zip.Checked) {
        $Array += $CHECKBOX_Ninite_7zip.Name
    }
    if ($CHECKBOX_Ninite_VLC.Checked) {
        $Array += $CHECKBOX_Ninite_VLC.Name
    }
    if ($CHECKBOX_Ninite_TeamViewer.Checked) {
        $Array += $CHECKBOX_Ninite_TeamViewer.Name
    }
    if ($CHECKBOX_Ninite_Chrome.Checked) {
        $Array += $CHECKBOX_Ninite_Chrome.Name
    }
    if ($CHECKBOX_Ninite_qBittorrent.Checked) {
        $Array += $CHECKBOX_Ninite_qBittorrent.Name
    }
    if ($CHECKBOX_Ninite_Malwarebytes.Checked) {
        $Array += $CHECKBOX_Ninite_Malwarebytes.Name
    }
    Return $Array -Join '-'
}


Function Set-NiniteFileName {
    [String[]]$Array = @()
    if ($CHECKBOX_Ninite_7zip.Checked) {
        $Array += $CHECKBOX_Ninite_7zip.Text
    }
    if ($CHECKBOX_Ninite_VLC.Checked) {
        $Array += $CHECKBOX_Ninite_VLC.Text
    }
    if ($CHECKBOX_Ninite_TeamViewer.Checked) {
        $Array += $CHECKBOX_Ninite_TeamViewer.Text
    }
    if ($CHECKBOX_Ninite_Chrome.Checked) {
        $Array += $CHECKBOX_Ninite_Chrome.Text
    }
    if ($CHECKBOX_Ninite_qBittorrent.Checked) {
        $Array += $CHECKBOX_Ninite_qBittorrent.Text
    }
    if ($CHECKBOX_Ninite_Malwarebytes.Checked) {
        $Array += $CHECKBOX_Ninite_Malwarebytes.Text
    }
    Return "Ninite $($Array -Join ' ') Installer.exe"
}
