New-GroupBox 'General'


$BUTTON_TEXT = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Run as administrator'})"
$BUTTON_TOOLTIP_TEXT = 'Restart this utility with administrator privileges'
$BUTTON_FUNCTION = { Start-Elevated }
New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT -Disabled:$IS_ELEVATED > $Null


$BUTTON_TOOLTIP_TEXT = 'Print system information to the log'
$BUTTON_FUNCTION = { Out-SystemInfo }
New-Button 'System information' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
