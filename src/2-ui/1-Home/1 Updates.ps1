New-Card 'Updates'


[ScriptBlock]$BUTTON_FUNCTION = { Start-AsyncOperation -Button $this { Update-Windows } }
New-Button 'Update Windows' $BUTTON_FUNCTION


[ScriptBlock]$BUTTON_FUNCTION = { Start-AsyncOperation -Button $this { Update-MicrosoftStoreApps } }
New-Button 'Update Store apps' $BUTTON_FUNCTION


[ScriptBlock]$BUTTON_FUNCTION = { Start-AsyncOperation -Button $this { Update-MicrosoftOffice } }
New-Button 'Update Microsoft Office' $BUTTON_FUNCTION
