Set-Variable GRP_Activators (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Activators.Text = 'Activators'
$GRP_Activators.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Activators.Width = $GRP_WIDTH
$GRP_Activators.Location = $GRP_ThisUtility.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_Activators)

Set-Variable BTN_DownloadKMSAuto (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_DownloadAAct (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_DownloadChewWGA (New-Object System.Windows.Forms.Button) -Option Constant

Set-Variable CBOX_StartKMSAuto (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_StartAAct (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_StartChewWGA (New-Object System.Windows.Forms.CheckBox) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMSAuto, "Download KMSAuto Lite`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadAAct, "Download AAct`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChewWGA, "Download ChewWGA`nLast resort for activating hopeless Windows 7 cases`n`n$TXT_AV_WARNING")

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartKMSAuto, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartAAct, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartChewWGA, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadKMSAuto.Font = $BTN_DownloadAAct.Font = $BTN_DownloadChewWGA.Font = $BTN_FONT
$BTN_DownloadKMSAuto.Height = $BTN_DownloadAAct.Height = $BTN_DownloadChewWGA.Height = $BTN_HEIGHT
$BTN_DownloadKMSAuto.Width = $BTN_DownloadAAct.Width = $BTN_DownloadChewWGA.Width = $BTN_WIDTH

$CBOX_StartKMSAuto.Size = $CBOX_StartAAct.Size = $CBOX_StartChewWGA.Size = $CBOX_SIZE
$CBOX_StartKMSAuto.Text = $CBOX_StartAAct.Text = $CBOX_StartChewWGA.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_Activators.Controls.AddRange(@($BTN_DownloadKMSAuto, $CBOX_StartKMSAuto, $BTN_DownloadAAct, $CBOX_StartAAct, $BTN_DownloadChewWGA, $CBOX_StartChewWGA))



$BTN_DownloadKMSAuto.Text = 'KMSAuto Lite'
$BTN_DownloadKMSAuto.Location = $BTN_INIT_LOCATION
$BTN_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/KMSAuto_Lite.zip' -AVWarning -MultiFile -Execute:$CBOX_StartKMSAuto.Checked } )

$CBOX_StartKMSAuto.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartKMSAuto.Add_CheckStateChanged( { $BTN_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadAAct.Text = 'AAct (Win 7+, Office)'
$BTN_DownloadAAct.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_BTN_LONG
$BTN_DownloadAAct.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/AAct.zip' -AVWarning -MultiFile -Execute:$CBOX_StartAAct.Checked } )

$CBOX_StartAAct.Location = $BTN_DownloadAAct.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartAAct.Add_CheckStateChanged( { $BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadChewWGA.Text = 'ChewWGA (Win 7)'
$BTN_DownloadChewWGA.Location = $BTN_DownloadAAct.Location + $SHIFT_BTN_LONG
$BTN_DownloadChewWGA.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/ChewWGA.zip' -AVWarning -Execute:$CBOX_StartChewWGA.Checked } )

$CBOX_StartChewWGA.Location = $BTN_DownloadChewWGA.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartChewWGA.Add_CheckStateChanged( { $BTN_DownloadChewWGA.Text = "ChewWGA (Win 7)$(if ($CBOX_StartChewWGA.Checked) {$REQUIRES_ELEVATION})" } )
