New-GroupBox 'General'


$BUTTON_TEXT = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Restart as administrator'})"
$BUTTON_FUNCTION = { Start-Elevated }
New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION -Disabled:$IS_ELEVATED > $Null
