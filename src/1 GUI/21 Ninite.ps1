$GroupNinite = New-Object System.Windows.Forms.GroupBox
$GroupNinite.Text = 'Ninite'
$GroupNinite.Height = $_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT * 8 + $_BUTTON_INTERVAL_NORMAL * 2 + $_INTERVAL_SHORT
$GroupNinite.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_DOWNLOAD + $_INTERVAL_NORMAL
$GroupNinite.Location = "$_INTERVAL_NORMAL, $_INTERVAL_NORMAL"


$CheckBoxNinite7zip = New-Object System.Windows.Forms.CheckBox
$CheckBoxNinite7zip.Text = "7-Zip"
$CheckBoxNinite7zip.Name = "7zip"
$CheckBoxNinite7zip.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$CheckBoxNinite7zip.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNinite7zip.Checked = $True
$CheckBoxNinite7zip.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteVLC = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteVLC.Text = "VLC"
$CheckBoxNiniteVLC.Name = "vlc"
$CheckBoxNiniteVLC.Location = $CheckBoxNinite7zip.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteVLC.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteVLC.Checked = $True
$CheckBoxNiniteVLC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteTeamViewer = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteTeamViewer.Text = "TeamViewer"
$CheckBoxNiniteTeamViewer.Name = "teamviewer14"
$CheckBoxNiniteTeamViewer.Location = $CheckBoxNiniteVLC.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteTeamViewer.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteTeamViewer.Checked = $True
$CheckBoxNiniteTeamViewer.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteSkype = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteSkype.Text = "Skype"
$CheckBoxNiniteSkype.Name = "skype"
$CheckBoxNiniteSkype.Location = $CheckBoxNiniteTeamViewer.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteSkype.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteSkype.Checked = $True
$CheckBoxNiniteSkype.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteChrome = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteChrome.Text = "Google Chrome"
$CheckBoxNiniteChrome.Name = "chrome"
$CheckBoxNiniteChrome.Location = $CheckBoxNiniteSkype.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteChrome.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteChrome.Checked = $True
$CheckBoxNiniteChrome.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteqBittorrent = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteqBittorrent.Text = "qBittorrent"
$CheckBoxNiniteqBittorrent.Name = "qbittorrent"
$CheckBoxNiniteqBittorrent.Location = $CheckBoxNiniteChrome.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteqBittorrent.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteqBittorrent.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteGoogleDrive = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteGoogleDrive.Text = "Google Drive"
$CheckBoxNiniteGoogleDrive.Name = "googlebackupandsync"
$CheckBoxNiniteGoogleDrive.Location = $CheckBoxNiniteqBittorrent.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteGoogleDrive.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteGoogleDrive.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteVSC = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteVSC.Text = "Visual Studio Code"
$CheckBoxNiniteVSC.Name = "vscode"
$CheckBoxNiniteVSC.Location = $CheckBoxNiniteGoogleDrive.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteVSC.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteVSC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )


$ButtonNiniteDownload = New-Object System.Windows.Forms.Button
$ButtonNiniteDownload.Text = 'Download selected'
$ButtonNiniteDownloadToolTipText = 'Download Ninite universal installer for selected applications'
$ButtonNiniteDownload.Location = $CheckBoxNiniteVSC.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonNiniteDownload.Height = $_BUTTON_HEIGHT
$ButtonNiniteDownload.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonNiniteDownload.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonNiniteDownload, $ButtonNiniteDownloadToolTipText)
$ButtonNiniteDownload.Add_Click( {DownloadFile "https://ninite.com/$(NiniteQueryBuilder)/ninite.exe" $(NiniteNameBuilder)} )


$ButtonNiniteOpenInBrowser = New-Object System.Windows.Forms.Button
$ButtonNiniteOpenInBrowser.Text = 'View other'
$ButtonNiniteOpenInBrowserToolTipText = 'Open Ninite universal installer web page in browser'
$ButtonNiniteOpenInBrowser.Location = $ButtonNiniteDownload.Location + $_BUTTON_SHIFT_VERTICAL_SHORT
$ButtonNiniteOpenInBrowser.Height = $_BUTTON_HEIGHT
$ButtonNiniteOpenInBrowser.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonNiniteOpenInBrowser.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonNiniteOpenInBrowser, $ButtonNiniteOpenInBrowserToolTipText)
$ButtonNiniteOpenInBrowser.Add_Click( {
        $Query = NiniteQueryBuilder
        OpenInBrowser $(if ($Query) {"ninite.com/?select=$($Query)"} else {'ninite.com'})
    } )


$_TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GroupNinite))
$GroupNinite.Controls.AddRange(@($ButtonNiniteDownload, $ButtonNiniteOpenInBrowser))
$GroupNinite.Controls.AddRange(@($CheckBoxNinite7zip, $CheckBoxNiniteVLC, $CheckBoxNiniteTeamViewer, $CheckBoxNiniteSkype))
$GroupNinite.Controls.AddRange(@($CheckBoxNiniteChrome, $CheckBoxNiniteqBittorrent, $CheckBoxNiniteGoogleDrive, $CheckBoxNiniteVSC))

$_TAB_CONTROL.SelectedTab = $_TAB_DOWNLOADS_INSTALLERS
