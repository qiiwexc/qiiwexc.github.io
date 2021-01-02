Set-Variable -Option Constant GRP_General (New-Object System.Windows.Forms.GroupBox)
$GRP_General.Text = 'General'
$GRP_General.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 2
$GRP_General.Width = $GRP_WIDTH
$GRP_General.Location = $GRP_INIT_LOCATION
$TAB_HOME.Controls.Add($GRP_General)

Set-Variable -Option Constant BTN_Elevate    (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_SystemInfo (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInfo, 'Print system information to the log')

$BTN_Elevate.Font = $BTN_SystemInfo.Font = $BTN_FONT
$BTN_Elevate.Height = $BTN_SystemInfo.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_SystemInfo.Width = $BTN_WIDTH

$GRP_General.Controls.AddRange(@($BTN_Elevate, $BTN_SystemInfo))



$BTN_Elevate.Text = "Run as administrator$REQUIRES_ELEVATION"
$BTN_Elevate.Location = $BTN_INIT_LOCATION
$BTN_Elevate.Add_Click( { Start-Elevated } )


$BTN_SystemInfo.Text = 'System information'
$BTN_SystemInfo.Location = $BTN_Elevate.Location + $SHIFT_BTN_NORMAL
$BTN_SystemInfo.Add_Click( { Out-SystemInfo } )
