$GRP_Ninite = New-Object System.Windows.Forms.GroupBox
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_NORMAL + $CBOX_INT_SHORT * 10 + $BTN_INT_NORMAL * 2
$GRP_Ninite.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Ninite.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_INSTALLERS.Controls.Add($GRP_Ninite)


$CBOX_Chrome = New-Object System.Windows.Forms.CheckBox
$CBOX_Chrome.Text = "Google Chrome"
$CBOX_Chrome.Name = "chrome"
$CBOX_Chrome.Checked = $True
$CBOX_Chrome.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$CBOX_Chrome.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_Chrome.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_7zip = New-Object System.Windows.Forms.CheckBox
$CBOX_7zip.Text = "7-Zip"
$CBOX_7zip.Name = "7zip"
$CBOX_7zip.Checked = $True
$CBOX_7zip.Location = $CBOX_Chrome.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_7zip.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_7zip.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_VLC = New-Object System.Windows.Forms.CheckBox
$CBOX_VLC.Text = "VLC"
$CBOX_VLC.Name = "vlc"
$CBOX_VLC.Checked = $True
$CBOX_VLC.Location = $CBOX_7zip.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_VLC.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_VLC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_TeamViewer = New-Object System.Windows.Forms.CheckBox
$CBOX_TeamViewer.Text = "TeamViewer"
$CBOX_TeamViewer.Name = "teamviewer14"
$CBOX_TeamViewer.Checked = $True
$CBOX_TeamViewer.Location = $CBOX_VLC.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_TeamViewer.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_TeamViewer.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_Skype = New-Object System.Windows.Forms.CheckBox
$CBOX_Skype.Text = "Skype"
$CBOX_Skype.Name = "skype"
$CBOX_Skype.Checked = $True
$CBOX_Skype.Location = $CBOX_TeamViewer.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_Skype.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_Skype.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_qBittorrent = New-Object System.Windows.Forms.CheckBox
$CBOX_qBittorrent.Text = "qBittorrent"
$CBOX_qBittorrent.Name = "qbittorrent"
$CBOX_qBittorrent.Location = $CBOX_Skype.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_qBittorrent.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_qBittorrent.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_GoogleDrive = New-Object System.Windows.Forms.CheckBox
$CBOX_GoogleDrive.Text = "Google Drive"
$CBOX_GoogleDrive.Name = "googlebackupandsync"
$CBOX_GoogleDrive.Location = $CBOX_qBittorrent.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_GoogleDrive.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_GoogleDrive.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_VSCode = New-Object System.Windows.Forms.CheckBox
$CBOX_VSCode.Text = "Visual Studio Code"
$CBOX_VSCode.Name = "vscode"
$CBOX_VSCode.Location = $CBOX_GoogleDrive.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_VSCode.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_VSCode.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )


$BTN_DownloadNinite = New-Object System.Windows.Forms.Button
$BTN_DownloadNinite.Text = 'Download selected'
$BTN_DownloadNinite.Height = $BTN_HEIGHT
$BTN_DownloadNinite.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadNinite.Location = $CBOX_VSCode.Location + $BTN_SHIFT_VER_SHORT
$BTN_DownloadNinite.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadNinite, 'Download Ninite universal installer for selected applications')
$BTN_DownloadNinite.Add_Click( {DownloadFile "https://ninite.com/$(NiniteQueryBuilder)/ninite.exe" $(NiniteNameBuilder) $CBOX_ExecuteNinite.Checked} )

$CBOX_ExecuteNinite = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteNinite.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteNinite.Location = $BTN_DownloadNinite.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteNinite, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteNinite.Size = $CBOX_SIZE_DOWNLOAD


$BTN_OpenNiniteInBrowser = New-Object System.Windows.Forms.Button
$BTN_OpenNiniteInBrowser.Text = 'View other'
$BTN_OpenNiniteInBrowser.Height = $BTN_HEIGHT
$BTN_OpenNiniteInBrowser.Width = $BTN_WIDTH_NORMAL
$BTN_OpenNiniteInBrowser.Location = $BTN_DownloadNinite.Location + $CBOX_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_OpenNiniteInBrowser.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OpenNiniteInBrowser, 'Open Ninite universal installer web page')
$BTN_OpenNiniteInBrowser.Add_Click( {
        $Query = NiniteQueryBuilder
        OpenInBrowser $(if ($Query) {"ninite.com/?select=$($Query)"} else {'ninite.com'})
    } )

$LBL_OpenNiniteInBrowser = New-Object System.Windows.Forms.Label
$LBL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_OpenNiniteInBrowser.Location = $BTN_OpenNiniteInBrowser.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_OpenNiniteInBrowser.Size = $CBOX_SIZE_DOWNLOAD


$GRP_Ninite.Controls.AddRange(@(
        $BTN_DownloadNinite, $BTN_OpenNiniteInBrowser, $LBL_OpenNiniteInBrowser, $CBOX_ExecuteNinite,
        $CBOX_7zip, $CBOX_VLC, $CBOX_TeamViewer, $CBOX_Skype, $CBOX_Chrome, $CBOX_qBittorrent, $CBOX_GoogleDrive, $CBOX_VSCode
    ))
