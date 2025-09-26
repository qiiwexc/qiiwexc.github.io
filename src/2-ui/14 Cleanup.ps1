New-GroupBox 'Cleanup'


[ScriptBlock]$BUTTON_FUNCTION = { Start-Cleanup }
New-Button 'Run cleanup' $BUTTON_FUNCTION
