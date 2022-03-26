$GROUP_TEXT = 'Ninite'
$GROUP_LOCATION = $INITIAL_LOCATION_GROUP
$GROUP_Ninite = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


Set-Variable -Option Constant CHECKBOX_Chrome (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_Chrome.Checked = $True
$CHECKBOX_Chrome.Size = $CHECKBOX_SIZE
$CHECKBOX_Chrome.Text = 'Google Chrome'
$CHECKBOX_Chrome.Name = 'chrome'
$CHECKBOX_Chrome.Location = $INITIAL_LOCATION_BUTTON
$CHECKBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_Chrome)
$CHECKBOX_Chrome


Set-Variable -Option Constant CHECKBOX_7zip (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_7zip.Checked = $True
$CHECKBOX_7zip.Size = $CHECKBOX_SIZE
$CHECKBOX_7zip.Text = '7-Zip'
$CHECKBOX_7zip.Name = '7zip'
$CHECKBOX_7zip.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_7zip)
$CHECKBOX_7zip


Set-Variable -Option Constant CHECKBOX_VLC (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_VLC.Checked = $True
$CHECKBOX_VLC.Size = $CHECKBOX_SIZE
$CHECKBOX_VLC.Text = 'VLC'
$CHECKBOX_VLC.Name = 'vlc'
$CHECKBOX_VLC.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_VLC)
$CHECKBOX_VLC


Set-Variable -Option Constant CHECKBOX_TeamViewer (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_TeamViewer.Checked = $True
$CHECKBOX_TeamViewer.Size = $CHECKBOX_SIZE
$CHECKBOX_TeamViewer.Text = 'TeamViewer'
$CHECKBOX_TeamViewer.Name = 'teamviewer15'
$CHECKBOX_TeamViewer.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_TeamViewer)
$CHECKBOX_TeamViewer


Set-Variable -Option Constant CHECKBOX_qBittorrent (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_qBittorrent.Size = $CHECKBOX_SIZE
$CHECKBOX_qBittorrent.Text = 'qBittorrent'
$CHECKBOX_qBittorrent.Name = 'qbittorrent'
$CHECKBOX_qBittorrent.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_qBittorrent)
$CHECKBOX_qBittorrent


Set-Variable -Option Constant CHECKBOX_Malwarebytes (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_Malwarebytes.Size = $CHECKBOX_SIZE
$CHECKBOX_Malwarebytes.Text = 'Malwarebytes'
$CHECKBOX_Malwarebytes.Name = 'malwarebytes'
$CHECKBOX_Malwarebytes.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_Malwarebytes)
$CHECKBOX_Malwarebytes


$BUTTON_TEXT = 'Download selected'
$TOOLTIP_TEXT = 'Download Ninite universal installer for selected applications'
$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "https://ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) }
$BUTTON_DownloadNinite = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT


Set-Variable -Option Constant CHECKBOX_StartNinite (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_StartNinite.Checked = $True
$CHECKBOX_StartNinite.Size = $CHECKBOX_SIZE
$CHECKBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartNinite.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartNinite.Add_CheckStateChanged( { $BUTTON_DownloadNinite.Text = "Download selected$(if ($CHECKBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Ninite.Controls.Add($CHECKBOX_StartNinite)
$CHECKBOX_StartNinite


$BUTTON_TEXT = 'View other'
$TOOLTIP_TEXT = 'Open Ninite universal installer web page for other installation options'
$BUTTON_FUNCTION = { Open-InBrowser "https://ninite.com/?select=$(Set-NiniteQuery)" }
New-ButtonBrowser $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null
