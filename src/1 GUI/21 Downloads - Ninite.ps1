$GRP_Ninite = New-Object System.Windows.Forms.GroupBox
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_GROUP_TOP + $INT_CBOX_SHORT * 8 + $INT_SHORT + $INT_BTN_LONG * 2
$GRP_Ninite.Width = $GRP_WIDTH
$GRP_Ninite.Location = $GRP_INIT_LOCATION
$TAB_INSTALLERS.Controls.Add($GRP_Ninite)


$CBOX_Chrome = New-Object System.Windows.Forms.CheckBox
$CBOX_Chrome.Text = "Google Chrome"
$CBOX_Chrome.Name = "chrome"
$CBOX_Chrome.Checked = $True
$CBOX_Chrome.Size = $CBOX_SIZE
$CBOX_Chrome.Location = $BTN_INIT_LOCATION
$CBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_7zip = New-Object System.Windows.Forms.CheckBox
$CBOX_7zip.Text = "7-Zip"
$CBOX_7zip.Name = "7zip"
$CBOX_7zip.Checked = $True
$CBOX_7zip.Size = $CBOX_SIZE
$CBOX_7zip.Location = $CBOX_Chrome.Location + $SHIFT_CBOX_SHORT
$CBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VLC = New-Object System.Windows.Forms.CheckBox
$CBOX_VLC.Text = "VLC"
$CBOX_VLC.Name = "vlc"
$CBOX_VLC.Checked = $True
$CBOX_VLC.Size = $CBOX_SIZE
$CBOX_VLC.Location = $CBOX_7zip.Location + $SHIFT_CBOX_SHORT
$CBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_TeamViewer = New-Object System.Windows.Forms.CheckBox
$CBOX_TeamViewer.Text = "TeamViewer"
$CBOX_TeamViewer.Name = "teamviewer14"
$CBOX_TeamViewer.Checked = $True
$CBOX_TeamViewer.Size = $CBOX_SIZE
$CBOX_TeamViewer.Location = $CBOX_VLC.Location + $SHIFT_CBOX_SHORT
$CBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_Skype = New-Object System.Windows.Forms.CheckBox
$CBOX_Skype.Text = "Skype"
$CBOX_Skype.Name = "skype"
$CBOX_Skype.Checked = $True
$CBOX_Skype.Size = $CBOX_SIZE
$CBOX_Skype.Location = $CBOX_TeamViewer.Location + $SHIFT_CBOX_SHORT
$CBOX_Skype.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_qBittorrent = New-Object System.Windows.Forms.CheckBox
$CBOX_qBittorrent.Text = "qBittorrent"
$CBOX_qBittorrent.Name = "qbittorrent"
$CBOX_qBittorrent.Size = $CBOX_SIZE
$CBOX_qBittorrent.Location = $CBOX_Skype.Location + $SHIFT_CBOX_SHORT
$CBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_GoogleDrive = New-Object System.Windows.Forms.CheckBox
$CBOX_GoogleDrive.Text = "Google Drive"
$CBOX_GoogleDrive.Name = "googlebackupandsync"
$CBOX_GoogleDrive.Size = $CBOX_SIZE
$CBOX_GoogleDrive.Location = $CBOX_qBittorrent.Location + $SHIFT_CBOX_SHORT
$CBOX_GoogleDrive.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VSCode = New-Object System.Windows.Forms.CheckBox
$CBOX_VSCode.Text = "Visual Studio Code"
$CBOX_VSCode.Name = "vscode"
$CBOX_VSCode.Size = $CBOX_SIZE
$CBOX_VSCode.Location = $CBOX_GoogleDrive.Location + $SHIFT_CBOX_SHORT
$CBOX_VSCode.Add_CheckStateChanged( { Set-NiniteButtonState } )


$BTN_DownloadNinite = New-Object System.Windows.Forms.Button
$BTN_DownloadNinite.Text = 'Download selected'
$BTN_DownloadNinite.Height = $BTN_HEIGHT
$BTN_DownloadNinite.Width = $BTN_WIDTH
$BTN_DownloadNinite.Location = $CBOX_VSCode.Location + $SHIFT_BTN_SHORT
$BTN_DownloadNinite.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadNinite, 'Download Ninite universal installer for selected applications')
$BTN_DownloadNinite.Add_Click( { Start-DownloadExtractExecute "ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) -Execute:$CBOX_StartNinite.Checked } )

$CBOX_StartNinite = New-Object System.Windows.Forms.CheckBox
$CBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartNinite.Size = $CBOX_SIZE
$CBOX_StartNinite.Location = $BTN_DownloadNinite.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartNinite, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartNinite.Add_CheckStateChanged( { $BTN_DownloadNinite.Text = "Download selected$(if ($CBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_OpenNiniteInBrowser = New-Object System.Windows.Forms.Button
$BTN_OpenNiniteInBrowser.Text = 'View other'
$BTN_OpenNiniteInBrowser.Height = $BTN_HEIGHT
$BTN_OpenNiniteInBrowser.Width = $BTN_WIDTH
$BTN_OpenNiniteInBrowser.Location = $BTN_DownloadNinite.Location + $SHIFT_BTN_LONG
$BTN_OpenNiniteInBrowser.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
$BTN_OpenNiniteInBrowser.Add_Click( {
        $Query = Set-NiniteQuery
        Open-InBrowser $(if ($Query) { "ninite.com/?select=$($Query)" } else { 'ninite.com' })
    } )

$LBL_OpenNiniteInBrowser = New-Object System.Windows.Forms.Label
$LBL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_OpenNiniteInBrowser.Size = $CBOX_SIZE
$LBL_OpenNiniteInBrowser.Location = $BTN_OpenNiniteInBrowser.Location + $SHIFT_LBL_BROWSER


$GRP_Ninite.Controls.AddRange(@(
        $BTN_DownloadNinite, $BTN_OpenNiniteInBrowser, $LBL_OpenNiniteInBrowser, $CBOX_StartNinite,
        $CBOX_7zip, $CBOX_VLC, $CBOX_TeamViewer, $CBOX_Skype, $CBOX_Chrome, $CBOX_qBittorrent, $CBOX_GoogleDrive, $CBOX_VSCode
    ))
