New-GroupBox 'Software Diagnostics'


$BUTTON_FUNCTION = { Start-DiskCleanup }
New-Button 'Start disk cleanup' $BUTTON_FUNCTION > $Null


$BUTTON_FUNCTION = { Test-WindowsHealth }
New-Button -UAC 'Check Windows health' $BUTTON_FUNCTION > $Null
