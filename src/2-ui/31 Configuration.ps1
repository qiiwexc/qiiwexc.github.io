New-GroupBox 'Configuration'

$PAD_CHECKBOXES = $False


$CHECKBOX_Config_Windows = New-CheckBox 'Windows' -Checked

$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Windows Personalisation'

$CHECKBOX_Config_7zip = New-CheckBox '7-Zip' -Checked

$CHECKBOX_Config_VLC = New-CheckBox 'VLC' -Checked

$CHECKBOX_Config_TeamViewer = New-CheckBox 'TeamViewer' -Checked

$CHECKBOX_Config_qBittorrent = New-CheckBox 'qBittorrent' -Checked

$CHECKBOX_Config_Edge = New-CheckBox 'Microsoft Edge' -Checked

$CHECKBOX_Config_Chrome = New-CheckBox 'Google Chrome' -Checked


$BUTTON_FUNCTION = { Set-Configuration }
New-Button 'Apply configuration' $BUTTON_FUNCTION
