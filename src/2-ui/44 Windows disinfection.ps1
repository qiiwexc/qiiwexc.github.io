New-GroupBox 'Windows disinfection'


[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser '{URL_TRONSCRIPT}' }
New-ButtonBrowser 'Download TronScript' $BUTTON_FUNCTION
