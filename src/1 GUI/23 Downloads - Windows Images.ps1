New-GroupBox 'Windows Images'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_11 }
New-ButtonBrowser 'Windows 11 (v21H2)' $BUTTON_FUNCTION -ToolTip 'Download Windows 11 (v21H2) RUS-ENG -26in1- HWID-act v2 (AIO) ISO image'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_10 }
New-ButtonBrowser 'Windows 10 (v21H2)' $BUTTON_FUNCTION -ToolTip 'Download Windows 10 (v21H1) RUS-ENG x86-x64 -28in1- HWID-act (AIO) ISO image'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_7 }
New-ButtonBrowser 'Windows 7 SP1' $BUTTON_FUNCTION -ToolTip 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v10 (AIO) ISO image'
