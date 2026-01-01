New-GroupBox 'Activators'


[Switch]$BUTTON_DISABLED = $OS_VERSION -lt 7
[ScriptBlock]$BUTTON_FUNCTION = { Start-Activator }
New-Button 'MAS Activator' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
