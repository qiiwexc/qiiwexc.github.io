New-GroupBox 'Software Diagnostics'


$BUTTON_TOOLTIP_TEXT = 'Check Windows health'
$BUTTON_FUNCTION = { Test-WindowsHealth }
New-Button -UAC 'Check Windows health' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Remove temporary files, some log files and empty directories, and some other unnecessary files; start Windows built-in disk cleanup utility'
$BUTTON_FUNCTION = { Start-DiskCleanup }
New-Button 'Start disk cleanup' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Start security scans'
$BUTTON_FUNCTION = { Start-SecurityScans }
New-Button -UAC 'Perform security scans' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
