Set-Variable GRP_Ninite (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_GROUP_TOP + $INT_CBOX_SHORT * 8 + $INT_SHORT + $INT_BTN_LONG * 2
$GRP_Ninite.Width = $GRP_WIDTH
$GRP_Ninite.Location = $GRP_INIT_LOCATION
$TAB_INSTALLERS.Controls.Add($GRP_Ninite)

Set-Variable CBOX_Chrome (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_7zip (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_VLC (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_TeamViewer (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_Skype (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_qBittorrent (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_GoogleDrive (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_VSCode (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadNinite (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_OpenNiniteInBrowser (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartNinite (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable LBL_OpenNiniteInBrowser (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadNinite, 'Download Ninite universal installer for selected applications')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartNinite, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadNinite.Font = $BTN_OpenNiniteInBrowser.Font = $BTN_FONT
$BTN_DownloadNinite.Height = $BTN_OpenNiniteInBrowser.Height = $BTN_HEIGHT
$BTN_DownloadNinite.Width = $BTN_OpenNiniteInBrowser.Width = $BTN_WIDTH

$CBOX_Chrome.Size = $CBOX_7zip.Size = $CBOX_VLC.Size = $CBOX_TeamViewer.Size = $CBOX_Skype.Size = $CBOX_qBittorrent.Size = `
    $CBOX_GoogleDrive.Size = $CBOX_VSCode.Size = $CBOX_StartNinite.Size = $LBL_OpenNiniteInBrowser.Size = $CBOX_SIZE
$CBOX_Chrome.Checked = $CBOX_7zip.Checked = $CBOX_VLC.Checked = $CBOX_TeamViewer.Checked = $CBOX_Skype.Checked = $True

$GRP_Ninite.Controls.AddRange(
    @($BTN_DownloadNinite, $BTN_OpenNiniteInBrowser, $LBL_OpenNiniteInBrowser, $CBOX_StartNinite,
        $CBOX_7zip, $CBOX_VLC, $CBOX_TeamViewer, $CBOX_Skype, $CBOX_Chrome, $CBOX_qBittorrent, $CBOX_GoogleDrive, $CBOX_VSCode)
)



$CBOX_Chrome.Text = "Google Chrome"
$CBOX_Chrome.Name = "chrome"
$CBOX_Chrome.Location = $BTN_INIT_LOCATION
$CBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_7zip.Text = "7-Zip"
$CBOX_7zip.Name = "7zip"
$CBOX_7zip.Location = $CBOX_Chrome.Location + $SHIFT_CBOX_SHORT
$CBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VLC.Text = "VLC"
$CBOX_VLC.Name = "vlc"
$CBOX_VLC.Location = $CBOX_7zip.Location + $SHIFT_CBOX_SHORT
$CBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_TeamViewer.Text = "TeamViewer"
$CBOX_TeamViewer.Name = "teamviewer14"
$CBOX_TeamViewer.Location = $CBOX_VLC.Location + $SHIFT_CBOX_SHORT
$CBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_Skype.Text = "Skype"
$CBOX_Skype.Name = "skype"
$CBOX_Skype.Location = $CBOX_TeamViewer.Location + $SHIFT_CBOX_SHORT
$CBOX_Skype.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_qBittorrent.Text = "qBittorrent"
$CBOX_qBittorrent.Name = "qbittorrent"
$CBOX_qBittorrent.Location = $CBOX_Skype.Location + $SHIFT_CBOX_SHORT
$CBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_GoogleDrive.Text = "Google Drive"
$CBOX_GoogleDrive.Name = "googlebackupandsync"
$CBOX_GoogleDrive.Location = $CBOX_qBittorrent.Location + $SHIFT_CBOX_SHORT
$CBOX_GoogleDrive.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VSCode.Text = "Visual Studio Code"
$CBOX_VSCode.Name = "vscode"
$CBOX_VSCode.Location = $CBOX_GoogleDrive.Location + $SHIFT_CBOX_SHORT
$CBOX_VSCode.Add_CheckStateChanged( { Set-NiniteButtonState } )


$BTN_DownloadNinite.Text = 'Download selected'
$BTN_DownloadNinite.Location = $CBOX_VSCode.Location + $SHIFT_BTN_SHORT
$BTN_DownloadNinite.Add_Click( { Start-DownloadExtractExecute "ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) -Execute:$CBOX_StartNinite.Checked } )

$CBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartNinite.Location = $BTN_DownloadNinite.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartNinite.Add_CheckStateChanged( { $BTN_DownloadNinite.Text = "Download selected$(if ($CBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_OpenNiniteInBrowser.Text = 'View other'
$BTN_OpenNiniteInBrowser.Location = $BTN_DownloadNinite.Location + $SHIFT_BTN_LONG
$BTN_OpenNiniteInBrowser.Add_Click( {
        Set-Variable Query (Set-NiniteQuery) -Option Constant
        Open-InBrowser $(if ($Query) { "ninite.com/?select=$($Query)" } else { 'ninite.com' })
    } )

$LBL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_OpenNiniteInBrowser.Location = $BTN_OpenNiniteInBrowser.Location + $SHIFT_LBL_BROWSER
