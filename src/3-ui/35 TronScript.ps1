New-GroupBox 'Windows Disinfection' 5


$BUTTON_FUNCTION = { Open-InBrowser $URL_TRONSCRIPT }
New-ButtonBrowser 'Download TronScript' $BUTTON_FUNCTION
