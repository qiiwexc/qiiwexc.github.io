New-GroupBox 'Cleanup' 4


[ScriptBlock]$BUTTON_FUNCTION = { Start-Cleanup }
New-Button 'Run cleanup' $BUTTON_FUNCTION
