New-GroupBox 'Remove Windows components'


[Boolean]$BUTTON_DISABLED = $PS_VERSION -le 5
[ScriptBlock]$BUTTON_FUNCTION = { Remove-WindowsFeatures }
New-Button 'Feature cleanup' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
