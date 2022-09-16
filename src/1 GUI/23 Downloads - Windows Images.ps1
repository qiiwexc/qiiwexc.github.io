New-GroupBox 'Windows Images'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_11 }
New-ButtonBrowser 'Windows 11 (v21H2)' $BUTTON_FUNCTION

$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_10 }
New-ButtonBrowser 'Windows 10 (v21H2)' $BUTTON_FUNCTION

$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_7 }
New-ButtonBrowser 'Windows 7 SP1' $BUTTON_FUNCTION
