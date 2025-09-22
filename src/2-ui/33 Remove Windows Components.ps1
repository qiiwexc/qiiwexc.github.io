New-GroupBox 'Miscellaneous Windows features'


$BUTTON_FUNCTION = { Remove-WindowsFeatures }
New-Button 'Feature cleanup' $BUTTON_FUNCTION | Out-Null
