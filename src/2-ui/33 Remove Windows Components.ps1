New-GroupBox 'Miscellaneous Windows features'


[ScriptBlock]$BUTTON_FUNCTION = { Remove-WindowsFeatures }
New-Button 'Feature cleanup' $BUTTON_FUNCTION
