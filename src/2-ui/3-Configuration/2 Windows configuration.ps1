New-GroupBox 'Windows configuration'

[Boolean]$PAD_CHECKBOXES = $False


[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsBase = New-CheckBox 'Base config and privacy' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_PowerScheme = New-CheckBox 'Set power scheme' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsSearch = New-CheckBox 'Configure search index' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_FileAssociations = New-CheckBox 'Set file associations'

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'


[ScriptBlock]$BUTTON_FUNCTION = { Set-WindowsConfiguration }
New-Button 'Apply configuration' $BUTTON_FUNCTION
