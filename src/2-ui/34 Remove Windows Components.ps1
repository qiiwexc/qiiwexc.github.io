New-GroupBox 'Remove Windows components' 5


[ScriptBlock]$BUTTON_FUNCTION = { Remove-WindowsFeatures }
New-Button 'Feature cleanup' $BUTTON_FUNCTION
