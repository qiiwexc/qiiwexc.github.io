New-GroupBox 'Apps configuration'

[Boolean]$PAD_CHECKBOXES = $False


[System.Windows.Forms.CheckBox]$CHECKBOX_Config_7zip = New-CheckBox '7-Zip' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_VLC = New-CheckBox 'VLC' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_TeamViewer = New-CheckBox 'TeamViewer' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_qBittorrent = New-CheckBox 'qBittorrent' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_Edge = New-CheckBox 'Microsoft Edge' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_Chrome = New-CheckBox 'Google Chrome' -Checked


[ScriptBlock]$BUTTON_FUNCTION = { Set-AppsConfiguration }
New-Button 'Apply configuration' $BUTTON_FUNCTION
