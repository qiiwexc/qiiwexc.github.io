Set-Variable -Option Constant GROUP_Ninite (New-Object System.Windows.Forms.GroupBox)
$GROUP_Ninite.Text = 'Ninite'
$GROUP_Ninite.Height = $INTERVAL_GROUP_TOP + $INTERVAL_CHECKBOX_SHORT * 6 + $INTERVAL_SHORT + $INTERVAL_BUTTON_LONG * 2
$GROUP_Ninite.Width = $WIDTH_GROUP
$GROUP_Ninite.Location = $INITIAL_LOCATION_GROUP
$TAB_DOWNLOADS.Controls.Add($GROUP_Ninite)


Set-Variable -Option Constant CHECKBOX_Chrome (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_Chrome.Checked = $True
$CHECKBOX_Chrome.Size = $CHECKBOX_SIZE
$CHECKBOX_Chrome.Text = 'Google Chrome'
$CHECKBOX_Chrome.Name = 'chrome'
$CHECKBOX_Chrome.Location = $INITIAL_LOCATION_BUTTON
$CHECKBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_Chrome)


Set-Variable -Option Constant CHECKBOX_7zip (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_7zip.Checked = $True
$CHECKBOX_7zip.Size = $CHECKBOX_SIZE
$CHECKBOX_7zip.Text = '7-Zip'
$CHECKBOX_7zip.Name = '7zip'
$CHECKBOX_7zip.Location = $CHECKBOX_Chrome.Location + $SHIFT_CHECKBOX
$CHECKBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_7zip)


Set-Variable -Option Constant CHECKBOX_VLC (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_VLC.Checked = $True
$CHECKBOX_VLC.Size = $CHECKBOX_SIZE
$CHECKBOX_VLC.Text = 'VLC'
$CHECKBOX_VLC.Name = 'vlc'
$CHECKBOX_VLC.Location = $CHECKBOX_7zip.Location + $SHIFT_CHECKBOX
$CHECKBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_VLC)


Set-Variable -Option Constant CHECKBOX_TeamViewer (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_TeamViewer.Checked = $True
$CHECKBOX_TeamViewer.Size = $CHECKBOX_SIZE
$CHECKBOX_TeamViewer.Text = 'TeamViewer'
$CHECKBOX_TeamViewer.Name = 'teamviewer15'
$CHECKBOX_TeamViewer.Location = $CHECKBOX_VLC.Location + $SHIFT_CHECKBOX
$CHECKBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_TeamViewer)


Set-Variable -Option Constant CHECKBOX_qBittorrent (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_qBittorrent.Size = $CHECKBOX_SIZE
$CHECKBOX_qBittorrent.Text = 'qBittorrent'
$CHECKBOX_qBittorrent.Name = 'qbittorrent'
$CHECKBOX_qBittorrent.Location = $CHECKBOX_TeamViewer.Location + $SHIFT_CHECKBOX
$CHECKBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_qBittorrent)


Set-Variable -Option Constant CHECKBOX_Malwarebytes (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_Malwarebytes.Size = $CHECKBOX_SIZE
$CHECKBOX_Malwarebytes.Text = 'Malwarebytes'
$CHECKBOX_Malwarebytes.Name = 'malwarebytes'
$CHECKBOX_Malwarebytes.Location = $CHECKBOX_qBittorrent.Location + $SHIFT_CHECKBOX
$CHECKBOX_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_Malwarebytes)


Set-Variable -Option Constant BUTTON_DownloadNinite (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadNinite, 'Download Ninite universal installer for selected applications')
$BUTTON_DownloadNinite.Font = $BUTTON_FONT
$BUTTON_DownloadNinite.Height = $HEIGHT_BUTTON
$BUTTON_DownloadNinite.Width = $WIDTH_BUTTON
$BUTTON_DownloadNinite.Text = "Download selected$REQUIRES_ELEVATION"
$BUTTON_DownloadNinite.Location = $CHECKBOX_Malwarebytes.Location + $SHIFT_BUTTON_SHORT
$BUTTON_DownloadNinite.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) } )
$GROUP_Ninite.Controls.Add($BUTTON_DownloadNinite)


Set-Variable -Option Constant CHECKBOX_StartNinite (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_StartNinite.Checked = $True
$CHECKBOX_StartNinite.Size = $CHECKBOX_SIZE
$CHECKBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartNinite.Location = $BUTTON_DownloadNinite.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartNinite.Add_CheckStateChanged( { $BUTTON_DownloadNinite.Text = "Download selected$(if ($CHECKBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Ninite.Controls.Add($CHECKBOX_StartNinite)


Set-Variable -Option Constant BUTTON_OpenNiniteInBrowser (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
$BUTTON_OpenNiniteInBrowser.Font = $BUTTON_FONT
$BUTTON_OpenNiniteInBrowser.Height = $HEIGHT_BUTTON
$BUTTON_OpenNiniteInBrowser.Width = $WIDTH_BUTTON
$BUTTON_OpenNiniteInBrowser.Text = 'View other'
$BUTTON_OpenNiniteInBrowser.Location = $BUTTON_DownloadNinite.Location + $SHIFT_BUTTON_LONG
$BUTTON_OpenNiniteInBrowser.Add_Click( {
        Set-Variable -Option Constant Query (Set-NiniteQuery); Open-InBrowser $(if ($Query) { "ninite.com/?select=$($Query)" } else { 'ninite.com' })
    } )
$GROUP_Ninite.Controls.Add($BUTTON_OpenNiniteInBrowser)


Set-Variable -Option Constant LABEL_OpenNiniteInBrowser (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartNinite, $TXT_TIP_START_AFTER_DOWNLOAD)
$LABEL_OpenNiniteInBrowser.Size = $CHECKBOX_SIZE
$LABEL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LABEL_OpenNiniteInBrowser.Location = $BUTTON_OpenNiniteInBrowser.Location + $SHIFT_LABEL_BROWSER
$GROUP_Ninite.Controls.Add($LABEL_OpenNiniteInBrowser)
