New-GroupBox 'Check for updates'


$BUTTON_DISABLED = $OS_VERSION -lt 7
$BUTTON_FUNCTION = { Get-WindowsUpdates }
New-Button 'Windows update' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED


$BUTTON_DISABLED = $OS_VERSION -lt 8
$BUTTON_FUNCTION = { Get-MicrosoftStoreUpdates }
New-Button 'Microsoft Store updates' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED


$BUTTON_DISABLED = $OFFICE_INSTALL_TYPE -ne 'C2R'
$BUTTON_FUNCTION = { Get-OfficeUpdates }
New-Button 'Microsoft Office updates' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
