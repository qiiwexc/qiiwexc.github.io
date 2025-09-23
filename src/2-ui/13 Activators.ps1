New-GroupBox 'Activators (Windows 7+, Office)'


$BUTTON_DISABLED = $OS_VERSION -lt 7
$BUTTON_FUNCTION = { Start-Activator }
New-Button 'MAS Activator' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartActivationProgram.Checked '{URL_ACTIVATION_PROGRAM}' }
New-Button 'Activation Program' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartActivationProgram = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
