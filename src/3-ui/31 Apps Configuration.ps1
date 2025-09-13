New-GroupBox 'Apps Configuration'

$PAD_CHECKBOXES = $False


$CHECKBOX_Config_7zip = New-CheckBox '7-Zip' -Checked

$CHECKBOX_Config_VLC = New-CheckBox 'VLC' -Checked

$CHECKBOX_Config_TeamViewer = New-CheckBox 'TeamViewer' -Checked

$CHECKBOX_Config_qBittorrent = New-CheckBox 'qBittorrent' -Checked

$CHECKBOX_Config_Chrome = New-CheckBox 'Google Chrome' -Checked


$BUTTON_FUNCTION = { Set-AppsConfiguration }
New-Button -UAC 'Apply configuration' $BUTTON_FUNCTION > $Null
