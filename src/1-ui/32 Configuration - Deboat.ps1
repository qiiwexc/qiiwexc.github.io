New-GroupBox 'Debloat Windows'


$BUTTON_FUNCTION = { Start-WindowsDebloat }
New-Button -UAC 'Debloat Windows' $BUTTON_FUNCTION > $Null
