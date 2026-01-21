New-GroupBox 'Windows configuration'

[Switch]$PAD_CHECKBOXES = $False


[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsBase = New-CheckBox 'Base config and privacy' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'


[ScriptBlock]$BUTTON_FUNCTION = { Set-WindowsConfiguration $CHECKBOX_Config_WindowsBase $CHECKBOX_Config_WindowsPersonalisation }
New-Button 'Apply configuration' $BUTTON_FUNCTION
