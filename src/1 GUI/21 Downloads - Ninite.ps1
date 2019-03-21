$GRP_Ninite = New-Object System.Windows.Forms.GroupBox
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_NORMAL + $CBOX_INT_SHORT * 10 + $BTN_INT_NORMAL * 2
$GRP_Ninite.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Ninite.Location = "$INT_NORMAL, $INT_NORMAL"


$CBOX_NiniteChrome = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteChrome.Text = "Google Chrome"
$CBOX_NiniteChrome.Name = "chrome"
$CBOX_NiniteChrome.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$CBOX_NiniteChrome.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteChrome.Checked = $True
$CBOX_NiniteChrome.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_Ninite7zip = New-Object System.Windows.Forms.CheckBox
$CBOX_Ninite7zip.Text = "7-Zip"
$CBOX_Ninite7zip.Name = "7zip"
$CBOX_Ninite7zip.Location = $CBOX_NiniteChrome.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_Ninite7zip.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_Ninite7zip.Checked = $True
$CBOX_Ninite7zip.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteVLC = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteVLC.Text = "VLC"
$CBOX_NiniteVLC.Name = "vlc"
$CBOX_NiniteVLC.Location = $CBOX_Ninite7zip.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteVLC.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteVLC.Checked = $True
$CBOX_NiniteVLC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteTeamViewer = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteTeamViewer.Text = "TeamViewer"
$CBOX_NiniteTeamViewer.Name = "teamviewer14"
$CBOX_NiniteTeamViewer.Location = $CBOX_NiniteVLC.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteTeamViewer.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteTeamViewer.Checked = $True
$CBOX_NiniteTeamViewer.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteSkype = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteSkype.Text = "Skype"
$CBOX_NiniteSkype.Name = "skype"
$CBOX_NiniteSkype.Location = $CBOX_NiniteTeamViewer.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteSkype.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteSkype.Checked = $True
$CBOX_NiniteSkype.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteqBittorrent = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteqBittorrent.Text = "qBittorrent"
$CBOX_NiniteqBittorrent.Name = "qbittorrent"
$CBOX_NiniteqBittorrent.Location = $CBOX_NiniteSkype.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteqBittorrent.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteqBittorrent.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteGoogleDrive = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteGoogleDrive.Text = "Google Drive"
$CBOX_NiniteGoogleDrive.Name = "googlebackupandsync"
$CBOX_NiniteGoogleDrive.Location = $CBOX_NiniteqBittorrent.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteGoogleDrive.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteGoogleDrive.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteVSC = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteVSC.Text = "Visual Studio Code"
$CBOX_NiniteVSC.Name = "vscode"
$CBOX_NiniteVSC.Location = $CBOX_NiniteGoogleDrive.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteVSC.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteVSC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )


$BTN_NiniteDownload = New-Object System.Windows.Forms.Button
$BTN_NiniteDownload.Text = 'Download selected'
$BTN_NiniteDownload.Location = $CBOX_NiniteVSC.Location + $BTN_SHIFT_VER_SHORT
$BTN_NiniteDownload.Height = $BTN_HEIGHT
$BTN_NiniteDownload.Width = $BTN_WIDTH_NORMAL
$BTN_NiniteDownload.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_NiniteDownload, 'Download Ninite universal installer for selected applications')
$BTN_NiniteDownload.Add_Click( {DownloadFile "https://ninite.com/$(NiniteQueryBuilder)/ninite.exe" $(NiniteNameBuilder) $CBOX_NiniteExecute.Checked} )

$CBOX_NiniteExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_NiniteExecute.Location = $BTN_NiniteDownload.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_NiniteExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_NiniteExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_NiniteOpenInBrowser = New-Object System.Windows.Forms.Button
$BTN_NiniteOpenInBrowser.Text = 'View other'
$BTN_NiniteOpenInBrowser.Location = $BTN_NiniteDownload.Location + $CBOX_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_NiniteOpenInBrowser.Height = $BTN_HEIGHT
$BTN_NiniteOpenInBrowser.Width = $BTN_WIDTH_NORMAL
$BTN_NiniteOpenInBrowser.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_NiniteOpenInBrowser, 'Open Ninite universal installer web page')
$BTN_NiniteOpenInBrowser.Add_Click( {
        $Query = NiniteQueryBuilder
        OpenInBrowser $(if ($Query) {"ninite.com/?select=$($Query)"} else {'ninite.com'})
    } )

$LBL_NiniteOpenInBrowser = New-Object System.Windows.Forms.Label
$LBL_NiniteOpenInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_NiniteOpenInBrowser.Location = $BTN_NiniteOpenInBrowser.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_NiniteOpenInBrowser.Size = $CBOX_SIZE_DOWNLOAD


$TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GRP_Ninite))
$GRP_Ninite.Controls.AddRange(@(
        $BTN_NiniteDownload, $BTN_NiniteOpenInBrowser, $CBOX_NiniteExecute, $LBL_NiniteOpenInBrowser, $CBOX_Ninite7zip, $CBOX_NiniteVLC,
        $CBOX_NiniteTeamViewer, $CBOX_NiniteSkype, $CBOX_NiniteChrome, $CBOX_NiniteqBittorrent, $CBOX_NiniteGoogleDrive, $CBOX_NiniteVSC
    ))
