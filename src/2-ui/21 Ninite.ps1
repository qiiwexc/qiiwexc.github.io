New-GroupBox 'Ninite'

[Boolean]$PAD_CHECKBOXES = $False


[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
$CHECKBOX_Ninite_Chrome.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
$CHECKBOX_Ninite_7zip.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
$CHECKBOX_Ninite_VLC.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_TeamViewer = New-CheckBox 'TeamViewer' -Name 'teamviewer15' -Checked
$CHECKBOX_Ninite_TeamViewer.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
$CHECKBOX_Ninite_qBittorrent.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
$CHECKBOX_Ninite_Malwarebytes.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

[ScriptBlock]$BUTTON_FUNCTION = {
    if ($CHECKBOX_StartNinite.Enabled) {
        Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "{URL_NINITE}/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName)
    } else {
        Open-InBrowser "{URL_NINITE}/?select=$(Set-NiniteQuery)"
    }
}
New-Button 'Download selected' $BUTTON_FUNCTION


[System.Windows.Forms.CheckBox]$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked

[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser "{URL_NINITE}/?select=$(Set-NiniteQuery)" }
New-ButtonBrowser 'View other' $BUTTON_FUNCTION
