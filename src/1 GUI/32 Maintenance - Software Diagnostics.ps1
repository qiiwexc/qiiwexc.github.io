Set-Variable -Option Constant GROUP_Software (New-Object System.Windows.Forms.GroupBox)
$GROUP_Software.Text = 'Software Diagnostics'
$GROUP_Software.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 4
$GROUP_Software.Width = $WIDTH_GROUP
$GROUP_Software.Location = $GROUP_Hardware.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_MAINTENANCE.Controls.Add($GROUP_Software)
$GROUP = $GROUP_Software


Set-Variable -Option Constant BUTTON_CheckWindowsHealth (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CheckWindowsHealth, 'Check Windows health')
$BUTTON_CheckWindowsHealth.Font = $BUTTON_FONT
$BUTTON_CheckWindowsHealth.Height = $HEIGHT_BUTTON
$BUTTON_CheckWindowsHealth.Width = $WIDTH_BUTTON
$BUTTON_CheckWindowsHealth.Text = "Check Windows health$REQUIRES_ELEVATION"
$BUTTON_CheckWindowsHealth.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_CheckWindowsHealth.Add_Click( { Test-WindowsHealth } )
$GROUP_Software.Controls.Add($BUTTON_CheckWindowsHealth)


Set-Variable -Option Constant BUTTON_CheckSystemFiles (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CheckSystemFiles, 'Check system file integrity')
$BUTTON_CheckSystemFiles.Font = $BUTTON_FONT
$BUTTON_CheckSystemFiles.Height = $HEIGHT_BUTTON
$BUTTON_CheckSystemFiles.Width = $WIDTH_BUTTON
$BUTTON_CheckSystemFiles.Text = "Check system files$REQUIRES_ELEVATION"
$BUTTON_CheckSystemFiles.Location = $BUTTON_CheckWindowsHealth.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_CheckSystemFiles.Add_Click( { Repair-SystemFiles } )
$GROUP_Software.Controls.Add($BUTTON_CheckSystemFiles)


Set-Variable -Option Constant BUTTON_StartSecurityScan (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_StartSecurityScan, 'Start security scan')
$BUTTON_StartSecurityScan.Enabled = Test-Path $PATH_DEFENDER_EXE
$BUTTON_StartSecurityScan.Font = $BUTTON_FONT
$BUTTON_StartSecurityScan.Height = $HEIGHT_BUTTON
$BUTTON_StartSecurityScan.Width = $WIDTH_BUTTON
$BUTTON_StartSecurityScan.Text = 'Perform a security scan'
$BUTTON_StartSecurityScan.Location = $BUTTON_CheckSystemFiles.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_StartSecurityScan.Add_Click( { Start-SecurityScan } )
$GROUP_Software.Controls.Add($BUTTON_StartSecurityScan)


Set-Variable -Option Constant BUTTON_StartMalwareScan (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_StartMalwareScan, 'Start malware scan')
$BUTTON_StartMalwareScan.Enabled = Test-Path $PATH_DEFENDER_EXE
$BUTTON_StartMalwareScan.Font = $BUTTON_FONT
$BUTTON_StartMalwareScan.Height = $HEIGHT_BUTTON
$BUTTON_StartMalwareScan.Width = $WIDTH_BUTTON
$BUTTON_StartMalwareScan.Text = "Perform a malware scan$REQUIRES_ELEVATION"
$BUTTON_StartMalwareScan.Location = $BUTTON_StartSecurityScan.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_StartMalwareScan.Add_Click( { Start-MalwareScan } )
$GROUP_Software.Controls.Add($BUTTON_StartMalwareScan)
