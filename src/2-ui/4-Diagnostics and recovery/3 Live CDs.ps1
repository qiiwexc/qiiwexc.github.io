New-Card 'Live CDs'


[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser '{URL_WINDOWS_PE}' }
New-ButtonBrowser 'Download Windows PE' $BUTTON_FUNCTION


[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser '{URL_SYSTEM_RESCUE}' }
New-ButtonBrowser 'Download SystemRescue' $BUTTON_FUNCTION
