Set-Variable -Option Constant GRP_Malware        (New-Object System.Windows.Forms.GroupBox)
$GRP_Malware.Text = 'Security'
$GRP_Malware.Height = $INT_GROUP_TOP + $INT_BTN_LONG + $INT_BTN_NORMAL
$GRP_Malware.Width = $GRP_WIDTH
$GRP_Malware.Location = $GRP_Windows.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Malware)

Set-Variable -Option Constant BTN_StartSecurityScan    (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_DownloadMalwarebytes (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartMalwarebytes   (New-Object System.Windows.Forms.CheckBox)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StartSecurityScan, 'Start security scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`nMalwarebytes helps remove malware and adware")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartMalwarebytes, $TIP_START_AFTER_DOWNLOAD)

$BTN_StartSecurityScan.Font = $BTN_DownloadMalwarebytes.Font = $BTN_FONT
$BTN_StartSecurityScan.Height = $BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_StartSecurityScan.Width = $BTN_DownloadMalwarebytes.Width = $BTN_WIDTH

$GRP_Malware.Controls.AddRange(@($BTN_StartSecurityScan, $BTN_DownloadMalwarebytes, $CBOX_StartMalwarebytes))


$BTN_StartSecurityScan.Text = 'Perform a security scan'
$BTN_StartSecurityScan.Location = $BTN_INIT_LOCATION
$BTN_StartSecurityScan.Add_Click( { Start-SecurityScan } )


$BTN_DownloadMalwarebytes.Text = "Malwarebytes$REQUIRES_ELEVATION"
$BTN_DownloadMalwarebytes.Location = $BTN_StartSecurityScan.Location + $SHIFT_BTN_NORMAL
$BTN_DownloadMalwarebytes.Add_Click( { Start-DownloadExtractExecute 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe' -Execute:$CBOX_StartMalwarebytes.Checked } )

$CBOX_StartMalwarebytes.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartMalwarebytes.Checked = $True
$CBOX_StartMalwarebytes.Size = $CBOX_SIZE
$CBOX_StartMalwarebytes.Location = $BTN_DownloadMalwarebytes.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartMalwarebytes.Add_CheckStateChanged( { $BTN_DownloadMalwarebytes.Text = "Malwarebytes$(if ($CBOX_StartMalwarebytes.Checked) {$REQUIRES_ELEVATION})" } )
