$GroupHomeDiagnostics = New-Object System.Windows.Forms.GroupBox
$GroupHomeDiagnostics.Text = 'Diagnostics'
$GroupHomeDiagnostics.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 4 - $_INTERVAL_SHORT * 2
$GroupHomeDiagnostics.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupHomeDiagnostics.Location = $GroupHomeThisUtility.Location + "$($GroupHomeThisUtility.Width + $_INTERVAL_NORMAL), 0"
$_TAB_HOME.Controls.Add($GroupHomeDiagnostics)


$ButtonCheckDrive = New-Object System.Windows.Forms.Button
$ButtonCheckDrive.Text = 'Check C: drive health'
$ButtonCheckDrive.Height = $_BUTTON_HEIGHT
$ButtonCheckDrive.Width = $_BUTTON_WIDTH_NORMAL
$ButtonCheckDrive.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonCheckDrive.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonCheckDrive, 'Perform a C: drive health check')
$ButtonCheckDrive.Add_Click( {CheckDrive} )


$ButtonCheckMemory = New-Object System.Windows.Forms.Button
$ButtonCheckMemory.Text = 'Check RAM'
$ButtonCheckMemory.Height = $_BUTTON_HEIGHT
$ButtonCheckMemory.Width = $_BUTTON_WIDTH_NORMAL
$ButtonCheckMemory.Location = $ButtonCheckDrive.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonCheckMemory.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonCheckMemory, 'Start RAM checking utility')
$ButtonCheckMemory.Add_Click( {CheckMemory} )


$ButtonSecurityScanQuick = New-Object System.Windows.Forms.Button
$ButtonSecurityScanQuick.Text = 'Quick security scan'
$ButtonSecurityScanQuick.Height = $_BUTTON_HEIGHT
$ButtonSecurityScanQuick.Width = $_BUTTON_WIDTH_NORMAL
$ButtonSecurityScanQuick.Location = $ButtonCheckMemory.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonSecurityScanQuick.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonSecurityScanQuick, 'Perform a quick security scan')
$ButtonSecurityScanQuick.Add_Click( {StartSecurityScan 'quick'} )

$ButtonSecurityScanFull = New-Object System.Windows.Forms.Button
$ButtonSecurityScanFull.Text = 'Full security scan'
$ButtonSecurityScanFull.Height = $_BUTTON_HEIGHT
$ButtonSecurityScanFull.Width = $_BUTTON_WIDTH_NORMAL
$ButtonSecurityScanFull.Location = $ButtonSecurityScanQuick.Location + $_BUTTON_SHIFT_VERTICAL_SHORT
$ButtonSecurityScanFull.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonSecurityScanFull, 'Perform a full security scan')
$ButtonSecurityScanFull.Add_Click( {StartSecurityScan 'full'} )


$GroupHomeDiagnostics.Controls.AddRange(@($ButtonCheckDrive, $ButtonCheckMemory, $ButtonSecurityScanQuick, $ButtonSecurityScanFull))
