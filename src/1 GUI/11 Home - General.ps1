Set-Variable -Option Constant GROUP_General (New-Object System.Windows.Forms.GroupBox)
$GROUP_General.Text = 'General'
$GROUP_General.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 2
$GROUP_General.Width = $WIDTH_GROUP
$GROUP_General.Location = $INITIAL_LOCATION_GROUP
$TAB_HOME.Controls.Add($GROUP_General)


Set-Variable -Option Constant BUTTON_Elevate (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Elevate, 'Restart this utility with administrator privileges')
$BUTTON_Elevate.Font = $BUTTON_FONT
$BUTTON_Elevate.Height = $HEIGHT_BUTTON
$BUTTON_Elevate.Width = $WIDTH_BUTTON
$BUTTON_Elevate.Text = "$(if ($IS_ELEVATED) {'Running as administrator'} else {"Run as administrator$REQUIRES_ELEVATION"})"
$BUTTON_Elevate.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_Elevate.Enabled = -not $IS_ELEVATED
$BUTTON_Elevate.Add_Click( { Start-Elevated } )
$GROUP_General.Controls.Add($BUTTON_Elevate)


Set-Variable -Option Constant BUTTON_SystemInfo (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_SystemInfo, 'Print system information to the log')
$BUTTON_SystemInfo.Font = $BUTTON_FONT
$BUTTON_SystemInfo.Height = $HEIGHT_BUTTON
$BUTTON_SystemInfo.Width = $WIDTH_BUTTON
$BUTTON_SystemInfo.Text = 'System information'
$BUTTON_SystemInfo.Location = $BUTTON_Elevate.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_SystemInfo.Add_Click( { Out-SystemInfo } )
$GROUP_General.Controls.Add($BUTTON_SystemInfo)
