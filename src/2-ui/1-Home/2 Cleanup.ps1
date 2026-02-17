New-Card 'Cleanup'


[ScriptBlock]$BUTTON_FUNCTION = { Start-AsyncOperation -Button $this { Start-Cleanup } }
New-Button 'Run cleanup' $BUTTON_FUNCTION
