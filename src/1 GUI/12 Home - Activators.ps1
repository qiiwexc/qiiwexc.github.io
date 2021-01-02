Set-Variable -Option Constant GRP_Activators (New-Object System.Windows.Forms.GroupBox)
$GRP_Activators.Text = 'Activators'
$GRP_Activators.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_Activators.Width = $GRP_WIDTH
$GRP_Activators.Location = $GRP_General.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_Activators)

Set-Variable -Option Constant BTN_DownloadKMSAuto (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartKMSAuto   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadAAct    (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartAAct      (New-Object System.Windows.Forms.CheckBox)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMSAuto, "Download KMSAuto Lite`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadAAct, "Download AAct`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartKMSAuto, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartAAct, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadKMSAuto.Font = $BTN_DownloadAAct.Font = $BTN_FONT
$BTN_DownloadKMSAuto.Height = $BTN_DownloadAAct.Height = $BTN_HEIGHT
$BTN_DownloadKMSAuto.Width = $BTN_DownloadAAct.Width = $BTN_WIDTH

$CBOX_StartKMSAuto.Checked = $CBOX_StartAAct.Checked = $True
$CBOX_StartKMSAuto.Size = $CBOX_StartAAct.Size = $CBOX_SIZE
$CBOX_StartKMSAuto.Text = $CBOX_StartAAct.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_Activators.Controls.AddRange(@($BTN_DownloadKMSAuto, $CBOX_StartKMSAuto, $BTN_DownloadAAct, $CBOX_StartAAct))



$BTN_DownloadKMSAuto.Text = "KMSAuto Lite$REQUIRES_ELEVATION"
$BTN_DownloadKMSAuto.Location = $BTN_INIT_LOCATION
$BTN_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CBOX_StartKMSAuto.Checked 'qiiwexc.github.io/d/KMSAuto_Lite.zip' } )

$CBOX_StartKMSAuto.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartKMSAuto.Add_CheckStateChanged( { $BTN_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$REQUIRES_ELEVATION"
$BTN_DownloadAAct.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_BTN_LONG
$BTN_DownloadAAct.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CBOX_StartAAct.Checked 'qiiwexc.github.io/d/AAct.zip' } )

$CBOX_StartAAct.Location = $BTN_DownloadAAct.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartAAct.Add_CheckStateChanged( { $BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )
