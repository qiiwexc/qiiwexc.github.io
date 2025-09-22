New-GroupBox 'Check for updates'


$BUTTON_FUNCTION = { Get-WindowsUpdates }
New-Button 'Windows update' $BUTTON_FUNCTION -Disabled:($OS_VERSION -lt 7) | Out-Null


$BUTTON_FUNCTION = { Get-MicrosoftStoreUpdates }
New-Button 'Microsoft Store updates' $BUTTON_FUNCTION -Disabled:($OS_VERSION -lt 8) | Out-Null


$BUTTON_FUNCTION = { Get-OfficeUpdates }
New-Button 'Microsoft Office updates' $BUTTON_FUNCTION -Disabled:($OFFICE_INSTALL_TYPE -ne 'C2R') | Out-Null
