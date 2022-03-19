Set-Variable -Option Constant GRP_Tools (New-Object System.Windows.Forms.GroupBox)
$GRP_Tools.Text = 'Tools'
$GRP_Tools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Tools.Width = $GRP_WIDTH
$GRP_Tools.Location = $GRP_General.Location + "0, $($GRP_General.Height + $INT_NORMAL)"
$TAB_HOME.Controls.Add($GRP_Tools)

Set-Variable -Option Constant BTN_DownloadCCleaner (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartCCleaner   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadRufus    (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartRufus      (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_WindowsPE        (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_WindowsPE        (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartCCleaner, $TIP_START_AFTER_DOWNLOAD)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 10')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRufus, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadCCleaner.Font = $BTN_DownloadRufus.Font = $BTN_WindowsPE.Font = $BTN_FONT
$BTN_DownloadCCleaner.Height = $BTN_DownloadRufus.Height = $BTN_WindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_DownloadRufus.Width = $BTN_WindowsPE.Width = $BTN_WIDTH
$CBOX_StartCCleaner.Size = $CBOX_StartRufus.Size = $LBL_WindowsPE.Size = $CBOX_SIZE

$GRP_Tools.Controls.AddRange(@($BTN_DownloadCCleaner, $CBOX_StartCCleaner, $BTN_DownloadRufus, $CBOX_StartRufus, $BTN_WindowsPE, $LBL_WindowsPE))



$BTN_DownloadCCleaner.Text = "CCleaner$REQUIRES_ELEVATION"
$BTN_DownloadCCleaner.Location = $BTN_INIT_LOCATION
$BTN_DownloadCCleaner.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartCCleaner.Checked 'download.ccleaner.com/ccsetup.exe' } )

$CBOX_StartCCleaner.Checked = $True
$CBOX_StartCCleaner.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartCCleaner.Location = $BTN_DownloadCCleaner.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartCCleaner.Add_CheckStateChanged( { $BTN_DownloadCCleaner.Text = "CCleaner$(if ($CBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRufus.Text = "Rufus (bootable USB)$REQUIRES_ELEVATION"
$BTN_DownloadRufus.Location = $BTN_DownloadCCleaner.Location + $SHIFT_BTN_LONG
$BTN_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartRufus.Checked 'github.com/pbatard/rufus/releases/download/v3.18/rufus-3.18p.exe' -Params:'-g' } )

$CBOX_StartRufus.Location = $BTN_DownloadRufus.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartRufus.Checked = $True
$CBOX_StartRufus.Add_CheckStateChanged( { $BTN_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_WindowsPE.Text = 'Windows PE (Live CD)'
$BTN_WindowsPE.Location = $BTN_DownloadRufus.Location + $SHIFT_BTN_LONG
$BTN_WindowsPE.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_' } )

$LBL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsPE.Location = $BTN_WindowsPE.Location + $SHIFT_LBL_BROWSER
