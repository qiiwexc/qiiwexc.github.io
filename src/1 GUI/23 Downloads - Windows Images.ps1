New-GroupBox 'Windows Images'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_11 }
New-ButtonBrowser 'Windows 11' $BUTTON_FUNCTION

$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_10 }
New-ButtonBrowser 'Windows 10' $BUTTON_FUNCTION

$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_7 }
New-ButtonBrowser 'Windows 7' $BUTTON_FUNCTION

$BUTTON_FUNCTION = { Open-InBrowser 'https://rutracker.org/forum/viewtopic.php?t=4366725' }
New-ButtonBrowser 'Windows PE (Live CD)' $BUTTON_FUNCTION
