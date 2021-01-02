Set-Variable -Option Constant GRP_Ninite (New-Object System.Windows.Forms.GroupBox)
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_GROUP_TOP + $INT_CBOX_SHORT * 7 + $INT_SHORT + $INT_BTN_LONG * 2
$GRP_Ninite.Width = $GRP_WIDTH
$GRP_Ninite.Location = $GRP_INIT_LOCATION
$TAB_INSTALLERS.Controls.Add($GRP_Ninite)

Set-Variable -Option Constant CBOX_Chrome        (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_7zip          (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_VLC           (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_TeamViewer    (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_Skype         (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_qBittorrent   (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_Malwarebytes  (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadNinite (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartNinite   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_OpenNiniteInBrowser (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_OpenNiniteInBrowser (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadNinite, 'Download Ninite universal installer for selected applications')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartNinite, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadNinite.Font = $BTN_OpenNiniteInBrowser.Font = $BTN_FONT
$BTN_DownloadNinite.Height = $BTN_OpenNiniteInBrowser.Height = $BTN_HEIGHT
$BTN_DownloadNinite.Width = $BTN_OpenNiniteInBrowser.Width = $BTN_WIDTH

$CBOX_Chrome.Checked = $CBOX_7zip.Checked = $CBOX_VLC.Checked = $CBOX_TeamViewer.Checked = $CBOX_StartNinite.Checked = $True
$CBOX_Chrome.Size = $CBOX_7zip.Size = $CBOX_VLC.Size = $CBOX_TeamViewer.Size = $CBOX_Skype.Size = `
    $CBOX_qBittorrent.Size = $CBOX_Malwarebytes.Size = $CBOX_StartNinite.Size = $LBL_OpenNiniteInBrowser.Size = $CBOX_SIZE

$GRP_Ninite.Controls.AddRange(
    @($BTN_DownloadNinite, $BTN_OpenNiniteInBrowser, $LBL_OpenNiniteInBrowser, $CBOX_StartNinite,
        $CBOX_7zip, $CBOX_VLC, $CBOX_TeamViewer, $CBOX_Skype, $CBOX_Chrome, $CBOX_qBittorrent, $CBOX_Malwarebytes)
)



$CBOX_Chrome.Text = 'Google Chrome'
$CBOX_Chrome.Name = 'chrome'
$CBOX_Chrome.Location = $BTN_INIT_LOCATION
$CBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_7zip.Text = '7-Zip'
$CBOX_7zip.Name = '7zip'
$CBOX_7zip.Location = $CBOX_Chrome.Location + $SHIFT_CBOX_SHORT
$CBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VLC.Text = 'VLC'
$CBOX_VLC.Name = 'vlc'
$CBOX_VLC.Location = $CBOX_7zip.Location + $SHIFT_CBOX_SHORT
$CBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_TeamViewer.Text = 'TeamViewer'
$CBOX_TeamViewer.Name = 'teamviewer15'
$CBOX_TeamViewer.Location = $CBOX_VLC.Location + $SHIFT_CBOX_SHORT
$CBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_Skype.Text = 'Skype'
$CBOX_Skype.Name = 'skype'
$CBOX_Skype.Location = $CBOX_TeamViewer.Location + $SHIFT_CBOX_SHORT
$CBOX_Skype.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_qBittorrent.Text = 'qBittorrent'
$CBOX_qBittorrent.Name = 'qbittorrent'
$CBOX_qBittorrent.Location = $CBOX_Skype.Location + $SHIFT_CBOX_SHORT
$CBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_Malwarebytes.Text = 'Malwarebytes'
$CBOX_Malwarebytes.Name = 'malwarebytes'
$CBOX_Malwarebytes.Location = $CBOX_qBittorrent.Location + $SHIFT_CBOX_SHORT
$CBOX_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )


$BTN_DownloadNinite.Text = "Download selected$REQUIRES_ELEVATION"
$BTN_DownloadNinite.Location = $CBOX_Malwarebytes.Location + $SHIFT_BTN_SHORT
$BTN_DownloadNinite.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartNinite.Checked "ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) } )

$CBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartNinite.Location = $BTN_DownloadNinite.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartNinite.Add_CheckStateChanged( { $BTN_DownloadNinite.Text = "Download selected$(if ($CBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_OpenNiniteInBrowser.Text = 'View other'
$BTN_OpenNiniteInBrowser.Location = $BTN_DownloadNinite.Location + $SHIFT_BTN_LONG
$BTN_OpenNiniteInBrowser.Add_Click( {
        Set-Variable -Option Constant Query (Set-NiniteQuery); Open-InBrowser $(if ($Query) { "ninite.com/?select=$($Query)" } else { 'ninite.com' })
    } )

$LBL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_OpenNiniteInBrowser.Location = $BTN_OpenNiniteInBrowser.Location + $SHIFT_LBL_BROWSER
