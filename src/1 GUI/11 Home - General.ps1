Set-Variable -Option Constant GROUP_General (New-Object System.Windows.Forms.GroupBox)
$GROUP_General.Text = 'General'
$GROUP_General.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 2
$GROUP_General.Width = $WIDTH_GROUP
$GROUP_General.Location = $INITIAL_LOCATION_GROUP
$TAB_HOME.Controls.Add($GROUP_General)
$GROUP = $GROUP_General


$BUTTON_DISABLED = $IS_ELEVATED
$BUTTON_LOCATION = $INITIAL_LOCATION_BUTTON
$BUTTON_NAME = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Run as administrator'})"
$BUTTON_FUNCTION = { Start-Elevated }
$TOOLTIP_TEXT = 'Restart this utility with administrator privileges'
$PREVIOUS_BUTTON = New-Button $GROUP $BUTTON_NAME $BUTTON_LOCATION $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED -UAC


$BUTTON_LOCATION = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_NAME = 'System information'
$BUTTON_FUNCTION = { Out-SystemInfo }
$TOOLTIP_TEXT = 'Print system information to the log'
$PREVIOUS_BUTTON = New-Button $GROUP $BUTTON_NAME $BUTTON_LOCATION $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT
