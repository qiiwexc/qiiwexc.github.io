$GRP_Windows = New-Object System.Windows.Forms.GroupBox
$GRP_Windows.Text = 'Windows'
$GRP_Windows.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Windows.Width = $GRP_WIDTH
$GRP_Windows.Location = $GRP_Hardware.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Windows)


$BTN_CheckWindowsHealth = New-Object System.Windows.Forms.Button
$BTN_CheckWindowsHealth.Text = "Check Windows health$REQUIRES_ELEVATION"
$BTN_CheckWindowsHealth.Height = $BTN_HEIGHT
$BTN_CheckWindowsHealth.Width = $BTN_WIDTH
$BTN_CheckWindowsHealth.Location = $BTN_INIT_LOCATION
$BTN_CheckWindowsHealth.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWindowsHealth, 'Check Windows health')
$BTN_CheckWindowsHealth.Add_Click( { Test-WindowsHealth } )


$BTN_RepairWindows = New-Object System.Windows.Forms.Button
$BTN_RepairWindows.Text = "Repair Windows$REQUIRES_ELEVATION"
$BTN_RepairWindows.Height = $BTN_HEIGHT
$BTN_RepairWindows.Width = $BTN_WIDTH
$BTN_RepairWindows.Location = $BTN_CheckWindowsHealth.Location + $SHIFT_BTN_NORMAL
$BTN_RepairWindows.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RepairWindows, 'Attempt to restore Windows health')
$BTN_RepairWindows.Add_Click( { Repair-Windows } )


$BTN_CheckSystemFiles = New-Object System.Windows.Forms.Button
$BTN_CheckSystemFiles.Text = "Check system files$REQUIRES_ELEVATION"
$BTN_CheckSystemFiles.Height = $BTN_HEIGHT
$BTN_CheckSystemFiles.Width = $BTN_WIDTH
$BTN_CheckSystemFiles.Location = $BTN_RepairWindows.Location + $SHIFT_BTN_NORMAL
$BTN_CheckSystemFiles.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckSystemFiles, 'Check system file integrity')
$BTN_CheckSystemFiles.Add_Click( { Repair-SystemFiles } )


$GRP_Windows.Controls.AddRange(@($BTN_CheckWindowsHealth, $BTN_RepairWindows, $BTN_CheckSystemFiles))
