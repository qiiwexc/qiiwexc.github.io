Set-Variable -Option Constant GRP_Software (New-Object System.Windows.Forms.GroupBox)
$GRP_Software.Text = 'Software'
$GRP_Software.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Software.Width = $GRP_WIDTH
$GRP_Software.Location = $GRP_Hardware.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Software)

Set-Variable -Option Constant BTN_CheckWindowsHealth (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_RepairWindows      (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_CheckSystemFiles   (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_StartSecurityScan  (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWindowsHealth, 'Check Windows health')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RepairWindows, 'Attempt to restore Windows health')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckSystemFiles, 'Check system file integrity')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StartSecurityScan, 'Start security scan')

$BTN_CheckWindowsHealth.Font = $BTN_RepairWindows.Font = $BTN_CheckSystemFiles.Font = $BTN_StartSecurityScan.Font = $BTN_FONT
$BTN_CheckWindowsHealth.Height = $BTN_RepairWindows.Height = $BTN_CheckSystemFiles.Height = $BTN_StartSecurityScan.Height = $BTN_HEIGHT
$BTN_CheckWindowsHealth.Width = $BTN_RepairWindows.Width = $BTN_CheckSystemFiles.Width = $BTN_StartSecurityScan.Width = $BTN_WIDTH

$GRP_Software.Controls.AddRange(@($BTN_CheckWindowsHealth, $BTN_RepairWindows, $BTN_CheckSystemFiles, $BTN_StartSecurityScan))



$BTN_CheckWindowsHealth.Text = "Check Windows health$REQUIRES_ELEVATION"
$BTN_CheckWindowsHealth.Location = $BTN_INIT_LOCATION
$BTN_CheckWindowsHealth.Add_Click( { Test-WindowsHealth } )


$BTN_RepairWindows.Text = "Repair Windows$REQUIRES_ELEVATION"
$BTN_RepairWindows.Location = $BTN_CheckWindowsHealth.Location + $SHIFT_BTN_NORMAL
$BTN_RepairWindows.Add_Click( { Repair-Windows } )


$BTN_CheckSystemFiles.Text = "Check system files$REQUIRES_ELEVATION"
$BTN_CheckSystemFiles.Location = $BTN_RepairWindows.Location + $SHIFT_BTN_NORMAL
$BTN_CheckSystemFiles.Add_Click( { Repair-SystemFiles } )


$BTN_StartSecurityScan.Text = 'Perform a security scan'
$BTN_StartSecurityScan.Location = $BTN_CheckSystemFiles.Location + $SHIFT_BTN_NORMAL
$BTN_StartSecurityScan.Add_Click( { Start-SecurityScan } )
