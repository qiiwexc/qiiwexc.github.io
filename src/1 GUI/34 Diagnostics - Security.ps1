$GRP_Malware = New-Object System.Windows.Forms.GroupBox
$GRP_Malware.Text = 'Security'
$GRP_Malware.Height = $INT_GROUP_TOP + $INT_BTN_SHORT + $INT_BTN_NORMAL + $INT_BTN_LONG
$GRP_Malware.Width = $GRP_WIDTH
$GRP_Malware.Location = $GRP_Windows.Location + "0, $($GRP_Windows.Height + $INT_NORMAL)"
$TAB_DIAGNOSTICS.Controls.Add($GRP_Malware)


$BTN_QuickSecurityScan = New-Object System.Windows.Forms.Button
$BTN_QuickSecurityScan.Text = 'Quick security scan'
$BTN_QuickSecurityScan.Height = $BTN_HEIGHT
$BTN_QuickSecurityScan.Width = $BTN_WIDTH
$BTN_QuickSecurityScan.Location = $BTN_INIT_LOCATION
$BTN_QuickSecurityScan.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_QuickSecurityScan, 'Perform a quick security scan')
$BTN_QuickSecurityScan.Add_Click( { Start-SecurityScan 'quick' } )

$BTN_FullSecurityScan = New-Object System.Windows.Forms.Button
$BTN_FullSecurityScan.Text = 'Full security scan'
$BTN_FullSecurityScan.Height = $BTN_HEIGHT
$BTN_FullSecurityScan.Width = $BTN_WIDTH
$BTN_FullSecurityScan.Location = $BTN_QuickSecurityScan.Location + $SHIFT_BTN_SHORT
$BTN_FullSecurityScan.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_FullSecurityScan, 'Perform a full security scan')
$BTN_FullSecurityScan.Add_Click( { Start-SecurityScan 'full' } )


$BTN_DownloadMalwarebytes = New-Object System.Windows.Forms.Button
$BTN_DownloadMalwarebytes.Text = 'Malwarebytes'
$BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_DownloadMalwarebytes.Width = $BTN_WIDTH
$BTN_DownloadMalwarebytes.Location = $BTN_FullSecurityScan.Location + $SHIFT_BTN_NORMAL
$BTN_DownloadMalwarebytes.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`nMalwarebytes helps remove malware and adware")
$BTN_DownloadMalwarebytes.Add_Click( {
        $DownloadedFile = Start-Download 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe'
        if ($CBOX_StartMalwarebytes.Checked -and $DownloadedFile) { Start-File $DownloadedFile }
    } )

$CBOX_StartMalwarebytes = New-Object System.Windows.Forms.CheckBox
$CBOX_StartMalwarebytes.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartMalwarebytes.Size = $CBOX_SIZE
$CBOX_StartMalwarebytes.Location = $BTN_DownloadMalwarebytes.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartMalwarebytes, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartMalwarebytes.Add_CheckStateChanged( { $BTN_DownloadMalwarebytes.Text = "Malwarebytes$(if ($CBOX_StartMalwarebytes.Checked) {$REQUIRES_ELEVATION})" } )


$GRP_Malware.Controls.AddRange(@($BTN_QuickSecurityScan, $BTN_FullSecurityScan, $BTN_DownloadMalwarebytes, $CBOX_StartMalwarebytes))
