New-GroupBox 'Miscellaneous Windows features' 5


[ScriptBlock]$BUTTON_FUNCTION = { Remove-WindowsFeatures }
New-Button 'Feature cleanup' $BUTTON_FUNCTION
