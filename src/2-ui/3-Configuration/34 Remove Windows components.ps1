New-GroupBox 'Remove Windows components'


[Boolean]$BUTTON_DISABLED = $PS_VERSION -lt 5
[ScriptBlock]$BUTTON_FUNCTION = { Remove-WindowsFeatures }
New-Button 'Feature cleanup' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
