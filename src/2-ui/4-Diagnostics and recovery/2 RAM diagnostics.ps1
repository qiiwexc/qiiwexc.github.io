New-Card 'RAM diagnostics'


[ScriptBlock]$BUTTON_FUNCTION = { Start-MemoryDiagnostics }
New-Button 'Memory Diagnostic' $BUTTON_FUNCTION
