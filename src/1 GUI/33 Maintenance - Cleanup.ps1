New-GroupBox 'Cleanup'


$BUTTON_TOOLTIP_TEXT = 'Remove temporary files, some log files and empty directories, and some other unnecessary files'
$BUTTON_FUNCTION = { Start-FileCleanup }
New-Button -UAC 'File cleanup' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Start Windows built-in disk cleanup utility'
$BUTTON_FUNCTION = { Start-DiskCleanup }
New-Button 'Start disk cleanup' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
