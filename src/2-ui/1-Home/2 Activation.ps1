New-GroupBox 'Activation'


[ScriptBlock]$BUTTON_FUNCTION = { Start-Activator -ActivateWindows:$CHECKBOX_ActivateWindows.Checked -ActivateOffice:$CHECKBOX_ActivateOffice.Checked }
New-Button 'MAS Activator' $BUTTON_FUNCTION

[Windows.Forms.CheckBox]$CHECKBOX_ActivateWindows = New-CheckBox 'Activate Windows silently'

[Windows.Forms.CheckBox]$CHECKBOX_ActivateOffice = New-CheckBox 'Activate Office silently' -Padded
