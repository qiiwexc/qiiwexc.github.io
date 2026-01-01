New-GroupBox 'Activation'


[Switch]$BUTTON_DISABLED = $OS_VERSION -lt 7
[ScriptBlock]$BUTTON_FUNCTION = { Start-Activator -ActivateWindows:$CHECKBOX_ActivateWindows.Checked -ActivateOffice:$CHECKBOX_ActivateOffice.Checked }
New-Button 'MAS Activator' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED

[Windows.Forms.CheckBox]$CHECKBOX_ActivateWindows = New-CheckBox 'Activate Windows'

[Windows.Forms.CheckBox]$CHECKBOX_ActivateOffice = New-CheckBox 'Activate Office'
