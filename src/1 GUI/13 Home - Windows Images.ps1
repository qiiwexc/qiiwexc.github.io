$GROUP_TEXT = 'Windows Images'
$GROUP_LOCATION = $GROUP_Activators.Location + $SHIFT_GROUP_HORIZONTAL
$GROUP_DownloadWindows = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'Windows 11 (v21H2)'
$TOOLTIP_TEXT = 'Download Windows 11 (v21H2) RUS-ENG -26in1- HWID-act v2 (AIO) ISO image'
$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_11 }
New-ButtonBrowser $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null


$BUTTON_TEXT = 'Windows 10 (v21H2)'
$TOOLTIP_TEXT = 'Download Windows 10 (v21H1) RUS-ENG x86-x64 -28in1- HWID-act (AIO) ISO image'
$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_10 }
New-ButtonBrowser $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null


$BUTTON_TEXT = 'Windows 7 SP1'
$TOOLTIP_TEXT = 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v10 (AIO) ISO image'
$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_7 }
New-ButtonBrowser $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null


$BUTTON_TEXT = 'Windows XP SP3 (ENG)'
$TOOLTIP_TEXT = 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image'
$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_XP }
New-ButtonBrowser $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null
