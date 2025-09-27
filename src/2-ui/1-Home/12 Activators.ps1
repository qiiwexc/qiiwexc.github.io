New-GroupBox 'Activators (Windows 7+, Office)'


[Boolean]$BUTTON_DISABLED = $OS_VERSION -lt 7
[ScriptBlock]$BUTTON_FUNCTION = { Start-Activator }
New-Button 'MAS Activator' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -AVWarning -Execute:$CHECKBOX_StartActivationProgram.Checked '{URL_ACTIVATION_PROGRAM}' }
New-Button 'Activation Program' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartActivationProgram = New-CheckBoxRunAfterDownload -Checked
