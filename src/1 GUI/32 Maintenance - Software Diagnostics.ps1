$GROUP_TEXT = 'Software Diagnostics'
$GROUP_LOCATION = $GROUP_Hardware.Location + $SHIFT_GROUP_HORIZONTAL
$GROUP_Software = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'Check Windows health'
$TOOLTIP_TEXT = 'Check Windows health'
$BUTTON_FUNCTION = { Test-WindowsHealth }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null


$BUTTON_TEXT = 'Check system files'
$TOOLTIP_TEXT = 'Check system file integrity'
$BUTTON_FUNCTION = { Repair-SystemFiles }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null


$BUTTON_TEXT = 'Perform a security scan'
$TOOLTIP_TEXT = 'Start security scan'
$BUTTON_DISABLED = -not (Test-Path $PATH_DEFENDER_EXE)
$BUTTON_FUNCTION = { Start-SecurityScan }
New-Button $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null


$BUTTON_TEXT = 'Perform a malware scan'
$TOOLTIP_TEXT = 'Start malware scan'
$BUTTON_DISABLED = -not (Test-Path $PATH_DEFENDER_EXE)
$BUTTON_FUNCTION = { Start-MalwareScan }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null
