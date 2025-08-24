New-GroupBox 'Ninite'


$CHECKBOX_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
$CHECKBOX_Chrome.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
$CHECKBOX_7zip.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
$CHECKBOX_VLC.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_TeamViewer = New-CheckBox 'TeamViewer' -Name 'teamviewer15' -Checked
$CHECKBOX_TeamViewer.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
$CHECKBOX_qBittorrent.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
$CHECKBOX_Malwarebytes.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$BUTTON_DownloadNinite = New-Button -UAC 'Download selected'
$BUTTON_DownloadNinite.Add_Click( {
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "$URL_NINITE/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName)
} )

$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartNinite.Add_CheckStateChanged( {
    $BUTTON_DownloadNinite.Text = "Download selected$(if ($CHECKBOX_StartNinite.Checked) { $REQUIRES_ELEVATION })"
} )

$BUTTON_FUNCTION = { Open-InBrowser "$URL_NINITE/?select=$(Set-NiniteQuery)" }
New-ButtonBrowser 'View other' $BUTTON_FUNCTION
