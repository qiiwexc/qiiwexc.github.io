New-GroupBox 'Software Diagnostics'


$BUTTON_TOOLTIP_TEXT = 'Check Windows health'
$BUTTON_FUNCTION = { Test-WindowsHealth }
New-Button -UAC 'Check Windows health' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Start security scan'
$BUTTON_FUNCTION = { Start-SecurityScan }
New-Button 'Perform security scans' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
