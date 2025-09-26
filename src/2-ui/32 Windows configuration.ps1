New-GroupBox 'Windows configuration'

[Boolean]$PAD_CHECKBOXES = $False


[System.Windows.Forms.CheckBox]$CHECKBOX_Config_Windows = New-CheckBox 'Windows' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Windows Personalisation'


[ScriptBlock]$BUTTON_FUNCTION = { Set-WindowsConfiguration }
New-Button 'Apply configuration' $BUTTON_FUNCTION
