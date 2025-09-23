New-GroupBox 'Activators (Windows 7+, Office)'


[Boolean]$BUTTON_DISABLED = $OS_VERSION -lt 7
[ScriptBlock]$BUTTON_FUNCTION = { Start-Activator }
New-Button 'MAS Activator' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartActivationProgram.Checked '{URL_ACTIVATION_PROGRAM}' }
New-Button 'Activation Program' $BUTTON_FUNCTION

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[Boolean]$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
[System.Windows.Forms.CheckBox]$CHECKBOX_StartActivationProgram = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
