Set-Variable -Option Constant GRP_DownloadTools (New-Object System.Windows.Forms.GroupBox)
$GRP_DownloadTools.Text = 'Tools (General)'
$GRP_DownloadTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_DownloadTools.Width = $GRP_WIDTH
$GRP_DownloadTools.Location = $GRP_Activators.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_DownloadTools)

Set-Variable -Option Constant BTN_DownloadRufus (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartRufus   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_WindowsPE     (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_WindowsPE     (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 10')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRufus, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadRufus.Font = $BTN_WindowsPE.Font = $BTN_FONT
$BTN_DownloadRufus.Height = $BTN_WindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadRufus.Width = $BTN_WindowsPE.Width = $BTN_WIDTH
$CBOX_StartRufus.Size = $LBL_WindowsPE.Size = $CBOX_SIZE

$GRP_DownloadTools.Controls.AddRange(@($BTN_DownloadRufus, $CBOX_StartRufus, $BTN_WindowsPE, $LBL_WindowsPE))


$BTN_DownloadRufus.Text = "Rufus (bootable USB)$REQUIRES_ELEVATION"
$BTN_DownloadRufus.Location = $BTN_INIT_LOCATION
$BTN_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartRufus.Checked 'github.com/pbatard/rufus/releases/download/v3.12/rufus-3.12p.exe' -Params:'-g' } )

$CBOX_StartRufus.Location = $BTN_DownloadRufus.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartRufus.Checked = $True
$CBOX_StartRufus.Add_CheckStateChanged( { $BTN_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_WindowsPE.Text = 'Windows PE (Live CD)'
$BTN_WindowsPE.Location = $BTN_DownloadRufus.Location + $SHIFT_BTN_LONG
$BTN_WindowsPE.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1HfjCrylPOOmwQf31yTl94VCSi4quoliF' } )

$LBL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsPE.Location = $BTN_WindowsPE.Location + $SHIFT_LBL_BROWSER
