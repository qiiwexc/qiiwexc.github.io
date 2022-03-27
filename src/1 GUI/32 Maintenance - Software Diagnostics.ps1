New-GroupBox 'Software Diagnostics'


$BUTTON_TOOLTIP_TEXT = 'Check Windows health'
$BUTTON_FUNCTION = { Test-WindowsHealth }
New-Button -UAC 'Check Windows health' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Check system file integrity'
$BUTTON_FUNCTION = { Repair-SystemFiles }
New-Button -UAC 'Check system files' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Start security scan'
$BUTTON_DISABLED = !(Test-Path $PATH_DEFENDER_EXE)
$BUTTON_FUNCTION = { Start-SecurityScan }
New-Button 'Perform a security scan' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null


$BUTTON_TOOLTIP_TEXT = 'Start malware scan'
$BUTTON_DISABLED = !(Test-Path $PATH_DEFENDER_EXE)
$BUTTON_FUNCTION = { Start-MalwareScan }
New-Button -UAC 'Perform a malware scan' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null
