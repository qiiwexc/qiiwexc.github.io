New-GroupBox 'Check for updates'


[Boolean]$BUTTON_DISABLED = $OS_VERSION -lt 7
[ScriptBlock]$BUTTON_FUNCTION = { Get-WindowsUpdates }
New-Button 'Windows update' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED


[Boolean]$BUTTON_DISABLED = $OS_VERSION -lt 8
[ScriptBlock]$BUTTON_FUNCTION = { Get-MicrosoftStoreUpdates }
New-Button 'Microsoft Store updates' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED


[Boolean]$BUTTON_DISABLED = $OFFICE_INSTALL_TYPE -ne 'C2R'
[ScriptBlock]$BUTTON_FUNCTION = { Get-OfficeUpdates }
New-Button 'Microsoft Office updates' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
