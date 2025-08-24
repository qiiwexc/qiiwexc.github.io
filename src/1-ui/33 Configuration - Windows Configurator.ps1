New-GroupBox 'Windows Configurator'


$BUTTON_FUNCTION = { Start-WindowsConfigurator }
New-Button -UAC 'Windows Configurator' $BUTTON_FUNCTION > $Null
