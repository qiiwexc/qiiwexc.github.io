New-GroupBox 'Chrome Extensions'


$BUTTON_TOOLTIP_TEXT = 'Block ads and pop-ups on websites'
$BUTTON_DISABLED = !(Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_ADBLOCK }
New-Button 'AdBlock' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Return YouTube Dislike restores the ability to see dislikes on YouTube'
$BUTTON_DISABLED = !(Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_YOUTUBE }
New-Button 'Return YouTube Dislike' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
