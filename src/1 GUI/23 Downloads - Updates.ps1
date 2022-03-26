$GROUP_TEXT = 'Updates'
$GROUP_LOCATION = $GROUP_Essentials.Location + $SHIFT_GROUP_HORIZONTAL
$GROUP_Updates = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'Update Store apps'
$TOOLTIP_TEXT = 'Update Microsoft Store apps'
$BUTTON_DISABLED = $OS_VERSION -le 7
$BUTTON_FUNCTION = { Start-StoreAppUpdate }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null


$BUTTON_TEXT = 'Update Microsoft Office'
$TOOLTIP_TEXT = 'Update Microsoft Office (for C2R installations only)'
$BUTTON_DISABLED = -not $OFFICE_INSTALL_TYPE -eq 'C2R'
$BUTTON_FUNCTION = { Start-OfficeUpdate }
New-Button $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null


$BUTTON_TEXT = 'Start Windows Update'
$TOOLTIP_TEXT = 'Check for Windows updates, download and install if available'
$BUTTON_FUNCTION = { Start-WindowsUpdate }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null
