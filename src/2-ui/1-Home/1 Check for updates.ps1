New-GroupBox 'Check for updates'


[Switch]$BUTTON_DISABLED = $OS_VERSION -lt 7
[ScriptBlock]$BUTTON_FUNCTION = { Update-Windows }
New-Button 'Windows update' $BUTTON_FUNCTION -Disabled $BUTTON_DISABLED


[Switch]$BUTTON_DISABLED = $OS_VERSION -lt 8
[ScriptBlock]$BUTTON_FUNCTION = { Update-MicrosoftStoreApps }
New-Button 'Microsoft Store updates' $BUTTON_FUNCTION -Disabled $BUTTON_DISABLED


[Switch]$BUTTON_DISABLED = $OFFICE_INSTALL_TYPE -ne 'C2R'
[ScriptBlock]$BUTTON_FUNCTION = { Update-MicrosoftOffice }
New-Button 'Microsoft Office updates' $BUTTON_FUNCTION -Disabled $BUTTON_DISABLED
