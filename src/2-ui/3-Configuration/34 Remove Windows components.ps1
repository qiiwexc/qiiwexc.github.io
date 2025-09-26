New-GroupBox 'Remove Windows components'


[ScriptBlock]$BUTTON_FUNCTION = { Remove-WindowsFeatures }
New-Button 'Feature cleanup' $BUTTON_FUNCTION
