New-GroupBox 'Updates'


$BUTTON_TOOLTIP_TEXT = 'Update Microsoft Store apps'
$BUTTON_DISABLED = $OS_VERSION -le 7
$BUTTON_FUNCTION = { Start-StoreAppUpdate }
New-Button -UAC 'Update Store apps' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null


$BUTTON_TOOLTIP_TEXT = 'Update Microsoft Office (for C2R installations only)'
$BUTTON_DISABLED = !$OFFICE_INSTALL_TYPE -eq 'C2R'
$BUTTON_FUNCTION = { Start-OfficeUpdate }
New-Button 'Update Microsoft Office' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null


$BUTTON_TOOLTIP_TEXT = 'Check for Windows updates, download and install if available'
$BUTTON_FUNCTION = { Start-WindowsUpdate }
New-Button -UAC 'Start Windows Update' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
