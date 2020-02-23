Set-Variable -Option Constant GRP_DownloadTools (New-Object System.Windows.Forms.GroupBox)
$GRP_DownloadTools.Text = 'Tools (General)'
$GRP_DownloadTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_DownloadTools.Width = $GRP_WIDTH
$GRP_DownloadTools.Location = $GRP_Activators.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_DownloadTools)

Set-Variable -Option Constant BTN_DownloadRufus (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_DownloadDSE   (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartRufus   (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_StartDSE     (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_WindowsPE     (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_WindowsPE     (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadDSE, 'Download Driver Store Explorer')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 8')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRufus, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartDSE, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadRufus.Font = $BTN_DownloadDSE.Font = $BTN_WindowsPE.Font = $BTN_FONT
$BTN_DownloadRufus.Height = $BTN_DownloadDSE.Height = $BTN_WindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadRufus.Width = $BTN_DownloadDSE.Width = $BTN_WindowsPE.Width = $BTN_WIDTH

$CBOX_StartRufus.Size = $CBOX_StartDSE.Size = $LBL_WindowsPE.Size = $CBOX_SIZE

$GRP_DownloadTools.Controls.AddRange(@($BTN_DownloadRufus, $CBOX_StartRufus, $BTN_DownloadDSE, $CBOX_StartDSE, $BTN_WindowsPE, $LBL_WindowsPE))


$BTN_DownloadRufus.Text = "Rufus (bootable USB)$REQUIRES_ELEVATION"
$BTN_DownloadRufus.Location = $BTN_INIT_LOCATION
$BTN_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartRufus.Checked 'github.com/pbatard/rufus/releases/download/v3.8/rufus-3.8.exe' -Params:'-g' } )

$CBOX_StartRufus.Location = $BTN_DownloadRufus.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartRufus.Checked = $True
$CBOX_StartRufus.Add_CheckStateChanged( { $BTN_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadDSE.Text = "Driver Store Explorer$REQUIRES_ELEVATION"
$BTN_DownloadDSE.Location = $BTN_DownloadRufus.Location + $SHIFT_BTN_LONG
$BTN_DownloadDSE.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartDSE.Checked 'github.com/lostindark/DriverStoreExplorer/releases/download/v0.10.58/DriverStoreExplorer.v0.10.58.zip' } )

$CBOX_StartDSE.Location = $BTN_DownloadDSE.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartDSE.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartDSE.Checked = $True
$CBOX_StartDSE.Add_CheckStateChanged( { $BTN_DownloadDSE.Text = "Driver Store Explorer$(if ($CBOX_StartDSE.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_WindowsPE.Text = 'Windows PE (Live CD)'
$BTN_WindowsPE.Location = $BTN_DownloadDSE.Location + $SHIFT_BTN_LONG
$BTN_WindowsPE.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_' } )

$LBL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsPE.Location = $BTN_WindowsPE.Location + $SHIFT_LBL_BROWSER
