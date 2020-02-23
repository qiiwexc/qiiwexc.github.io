Set-Variable -Option Constant GRP_Windows        (New-Object System.Windows.Forms.GroupBox)
$GRP_Windows.Text = 'Windows'
$GRP_Windows.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Windows.Width = $GRP_WIDTH
$GRP_Windows.Location = $GRP_HDD.Location + "0, $($GRP_HDD.Height + $INT_NORMAL)"
$TAB_DIAGNOSTICS.Controls.Add($GRP_Windows)

Set-Variable -Option Constant BTN_CheckWindowsHealth (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_RepairWindows      (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_CheckSystemFiles   (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWindowsHealth, 'Check Windows health')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RepairWindows, 'Attempt to restore Windows health')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckSystemFiles, 'Check system file integrity')

$BTN_CheckWindowsHealth.Font = $BTN_RepairWindows.Font = $BTN_CheckSystemFiles.Font = $BTN_FONT
$BTN_CheckWindowsHealth.Height = $BTN_RepairWindows.Height = $BTN_CheckSystemFiles.Height = $BTN_HEIGHT
$BTN_CheckWindowsHealth.Width = $BTN_RepairWindows.Width = $BTN_CheckSystemFiles.Width = $BTN_WIDTH

$GRP_Windows.Controls.AddRange(@($BTN_CheckWindowsHealth, $BTN_RepairWindows, $BTN_CheckSystemFiles))



$BTN_CheckWindowsHealth.Text = "Check Windows health$REQUIRES_ELEVATION"
$BTN_CheckWindowsHealth.Location = $BTN_INIT_LOCATION
$BTN_CheckWindowsHealth.Add_Click( { Test-WindowsHealth } )


$BTN_RepairWindows.Text = "Repair Windows$REQUIRES_ELEVATION"
$BTN_RepairWindows.Location = $BTN_CheckWindowsHealth.Location + $SHIFT_BTN_NORMAL
$BTN_RepairWindows.Add_Click( { Repair-Windows } )


$BTN_CheckSystemFiles.Text = "Check system files$REQUIRES_ELEVATION"
$BTN_CheckSystemFiles.Location = $BTN_RepairWindows.Location + $SHIFT_BTN_NORMAL
$BTN_CheckSystemFiles.Add_Click( { Repair-SystemFiles } )
