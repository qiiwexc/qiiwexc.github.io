$GROUP_TEXT = 'Cleanup'
$GROUP_LOCATION = $GROUP_Software.Location + $SHIFT_GROUP_HORIZONTAL
$GROUP_Cleanup = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'File cleanup'
$TOOLTIP_TEXT = 'Remove temporary files, some log files and empty directories, and some other unnecessary files'
$BUTTON_FUNCTION = { Start-FileCleanup }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null


$BUTTON_TEXT = 'Start disk cleanup'
$TOOLTIP_TEXT = 'Start Windows built-in disk cleanup utility'
$BUTTON_FUNCTION = { Start-DiskCleanup }
New-Button $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null
