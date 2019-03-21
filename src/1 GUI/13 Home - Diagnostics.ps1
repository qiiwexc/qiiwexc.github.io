$GRP_Diagnostics = New-Object System.Windows.Forms.GroupBox
$GRP_Diagnostics.Text = 'Diagnostics'
$GRP_Diagnostics.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 4 - $INT_SHORT * 2
$GRP_Diagnostics.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Diagnostics.Location = $GRP_ThisUtility.Location + "$($GRP_ThisUtility.Width + $INT_NORMAL), 0"
$TAB_HOME.Controls.Add($GRP_Diagnostics)


$BTN_CheckDrive = New-Object System.Windows.Forms.Button
$BTN_CheckDrive.Text = 'Check C: drive health'
$BTN_CheckDrive.Height = $BTN_HEIGHT
$BTN_CheckDrive.Width = $BTN_WIDTH_NORMAL
$BTN_CheckDrive.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_CheckDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDrive, 'Perform a C: drive health check')
$BTN_CheckDrive.Add_Click( {CheckDrive} )


$BTN_CheckMemory = New-Object System.Windows.Forms.Button
$BTN_CheckMemory.Text = 'Check RAM'
$BTN_CheckMemory.Height = $BTN_HEIGHT
$BTN_CheckMemory.Width = $BTN_WIDTH_NORMAL
$BTN_CheckMemory.Location = $BTN_CheckDrive.Location + $BTN_SHIFT_VER_NORMAL
$BTN_CheckMemory.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMemory, 'Start RAM checking utility')
$BTN_CheckMemory.Add_Click( {CheckMemory} )


$BTN_QuickSecurityScan = New-Object System.Windows.Forms.Button
$BTN_QuickSecurityScan.Text = 'Quick security scan'
$BTN_QuickSecurityScan.Height = $BTN_HEIGHT
$BTN_QuickSecurityScan.Width = $BTN_WIDTH_NORMAL
$BTN_QuickSecurityScan.Location = $BTN_CheckMemory.Location + $BTN_SHIFT_VER_NORMAL
$BTN_QuickSecurityScan.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_QuickSecurityScan, 'Perform a quick security scan')
$BTN_QuickSecurityScan.Add_Click( {StartSecurityScan 'quick'} )

$BTN_FullSecurityScan = New-Object System.Windows.Forms.Button
$BTN_FullSecurityScan.Text = 'Full security scan'
$BTN_FullSecurityScan.Height = $BTN_HEIGHT
$BTN_FullSecurityScan.Width = $BTN_WIDTH_NORMAL
$BTN_FullSecurityScan.Location = $BTN_QuickSecurityScan.Location + $BTN_SHIFT_VER_SHORT
$BTN_FullSecurityScan.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_FullSecurityScan, 'Perform a full security scan')
$BTN_FullSecurityScan.Add_Click( {StartSecurityScan 'full'} )


$GRP_Diagnostics.Controls.AddRange(@($BTN_CheckDrive, $BTN_CheckMemory, $BTN_QuickSecurityScan, $BTN_FullSecurityScan))
