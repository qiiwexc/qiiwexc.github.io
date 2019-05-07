Set-Variable GRP_Malware (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Malware.Text = 'Security'
$GRP_Malware.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_Malware.Width = $GRP_WIDTH
$GRP_Malware.Location = $GRP_Windows.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Malware)

Set-Variable BTN_StartSecurityScan (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable RBTN_QuickSecurityScan (New-Object System.Windows.Forms.RadioButton) -Option Constant
Set-Variable RBTN_FullSecurityScan (New-Object System.Windows.Forms.RadioButton) -Option Constant

Set-Variable BTN_DownloadMalwarebytes (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartMalwarebytes (New-Object System.Windows.Forms.CheckBox) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StartSecurityScan, 'Start security scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_QuickSecurityScan, 'Perform a quick security scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_FullSecurityScan, 'Perform a full security scan')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`nMalwarebytes helps remove malware and adware")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartMalwarebytes, $TIP_START_AFTER_DOWNLOAD)

$BTN_StartSecurityScan.Font = $BTN_DownloadMalwarebytes.Font = $BTN_FONT
$BTN_StartSecurityScan.Height = $BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_StartSecurityScan.Width = $BTN_DownloadMalwarebytes.Width = $BTN_WIDTH

$RBTN_QuickSecurityScan.Size = $RBTN_FullSecurityScan.Size = $RBTN_SIZE
$RBTN_QuickSecurityScan.Checked = $CBOX_StartMalwarebytes.Checked = $True

$GRP_Malware.Controls.AddRange(@($BTN_StartSecurityScan, $RBTN_QuickSecurityScan, $RBTN_FullSecurityScan, $BTN_DownloadMalwarebytes, $CBOX_StartMalwarebytes))



$BTN_StartSecurityScan.Text = 'Perform security scan'
$BTN_StartSecurityScan.Location = $BTN_INIT_LOCATION
$BTN_StartSecurityScan.Add_Click( { Start-SecurityScan $RBTN_FullSecurityScan.Checked } )

$RBTN_QuickSecurityScan.Text = $TXT_QUICK_SCAN
$RBTN_QuickSecurityScan.Location = $BTN_StartSecurityScan.Location + $SHIFT_RBTN_QUICK_SCAN

$RBTN_FullSecurityScan.Text = $TXT_FULL_SCAN
$RBTN_FullSecurityScan.Location = $RBTN_QuickSecurityScan.Location + $SHIFT_RBTN_FULL_SCAN


$BTN_DownloadMalwarebytes.Text = "Malwarebytes$REQUIRES_ELEVATION"
$BTN_DownloadMalwarebytes.Location = $BTN_StartSecurityScan.Location + $SHIFT_BTN_LONG
$BTN_DownloadMalwarebytes.Add_Click( { Start-DownloadExtractExecute 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe' -Execute:$CBOX_StartMalwarebytes.Checked } )

$CBOX_StartMalwarebytes.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartMalwarebytes.Size = $CBOX_SIZE
$CBOX_StartMalwarebytes.Location = $BTN_DownloadMalwarebytes.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartMalwarebytes.Add_CheckStateChanged( { $BTN_DownloadMalwarebytes.Text = "Malwarebytes$(if ($CBOX_StartMalwarebytes.Checked) {$REQUIRES_ELEVATION})" } )
