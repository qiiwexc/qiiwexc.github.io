New-Card 'Windows diagnostics'


[ScriptBlock]$BUTTON_FUNCTION = { Start-AsyncOperation -Button $this { Start-WindowsDiagnostics } }
New-Button 'Run DISM and SFC' $BUTTON_FUNCTION
