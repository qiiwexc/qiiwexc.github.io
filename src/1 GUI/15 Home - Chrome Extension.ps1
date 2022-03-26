$GROUP_TEXT = 'Chrome Extensions'
$GROUP_LOCATION = $GROUP_Activators.Location + "0, $($GROUP_Activators.Height + $INTERVAL_NORMAL)"
$GROUP_ChromeExtensions = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'HTTPS Everywhere'
$TOOLTIP_TEXT = 'Automatically use HTTPS security on many sites'
$BUTTON_DISABLED = -not (Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_HTTPS }
New-Button $BUTTON_TEXT $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $TOOLTIP_TEXT > $Null


$BUTTON_TEXT = 'AdBlock'
$TOOLTIP_TEXT = 'Block ads and pop-ups on websites'
$BUTTON_DISABLED = -not (Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_ADBLOCK }
New-Button $BUTTON_TEXT $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $TOOLTIP_TEXT > $Null


$BUTTON_TEXT = 'Return YouTube Dislike'
$TOOLTIP_TEXT = 'Return YouTube Dislike restores the ability to see dislikes on YouTube'
$BUTTON_DISABLED = -not (Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_YOUTUBE }
New-Button $BUTTON_TEXT $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $TOOLTIP_TEXT > $Null
