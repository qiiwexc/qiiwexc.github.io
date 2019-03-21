$GRP_HomeDiagnostics = New-Object System.Windows.Forms.GroupBox
$GRP_HomeDiagnostics.Text = 'Diagnostics'
$GRP_HomeDiagnostics.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 4 - $INT_SHORT * 2
$GRP_HomeDiagnostics.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_HomeDiagnostics.Location = $GRP_HomeThisUtility.Location + "$($GRP_HomeThisUtility.Width + $INT_NORMAL), 0"
$TAB_HOME.Controls.Add($GRP_HomeDiagnostics)


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


$BTN_SecurityScanQuick = New-Object System.Windows.Forms.Button
$BTN_SecurityScanQuick.Text = 'Quick security scan'
$BTN_SecurityScanQuick.Height = $BTN_HEIGHT
$BTN_SecurityScanQuick.Width = $BTN_WIDTH_NORMAL
$BTN_SecurityScanQuick.Location = $BTN_CheckMemory.Location + $BTN_SHIFT_VER_NORMAL
$BTN_SecurityScanQuick.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SecurityScanQuick, 'Perform a quick security scan')
$BTN_SecurityScanQuick.Add_Click( {StartSecurityScan 'quick'} )

$BTN_SecurityScanFull = New-Object System.Windows.Forms.Button
$BTN_SecurityScanFull.Text = 'Full security scan'
$BTN_SecurityScanFull.Height = $BTN_HEIGHT
$BTN_SecurityScanFull.Width = $BTN_WIDTH_NORMAL
$BTN_SecurityScanFull.Location = $BTN_SecurityScanQuick.Location + $BTN_SHIFT_VER_SHORT
$BTN_SecurityScanFull.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SecurityScanFull, 'Perform a full security scan')
$BTN_SecurityScanFull.Add_Click( {StartSecurityScan 'full'} )


$GRP_HomeDiagnostics.Controls.AddRange(@($BTN_CheckDrive, $BTN_CheckMemory, $BTN_SecurityScanQuick, $BTN_SecurityScanFull))
