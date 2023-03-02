New-GroupBox 'Software Diagnostics'


$BUTTON_FUNCTION = { Start-DiskCleanup }
New-Button 'Start disk cleanup' $BUTTON_FUNCTION > $Null
