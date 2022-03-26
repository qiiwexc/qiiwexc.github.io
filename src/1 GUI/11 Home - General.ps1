$GROUP_TEXT = 'General'
$GROUP_LOCATION = $INITIAL_LOCATION_GROUP
$GROUP_General = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Run as administrator'})"
$TOOLTIP_TEXT = 'Restart this utility with administrator privileges'
$BUTTON_FUNCTION = { Start-Elevated }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT -Disabled:$IS_ELEVATED > $Null


$BUTTON_TEXT = 'System information'
$TOOLTIP_TEXT = 'Print system information to the log'
$BUTTON_FUNCTION = { Out-SystemInfo }
New-Button $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null
