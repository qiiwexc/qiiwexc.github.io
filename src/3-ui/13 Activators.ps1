New-GroupBox 'Activators (Windows 7+, Office)'

$BUTTON_FUNCTION = { Start-Activator }
$BUTTON_MASActivator = New-Button -UAC 'MAS Activator' $BUTTON_FUNCTION -Disabled:$($OS_VERSION -lt 7)



$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartActivationProgram.Checked $URL_ACTIVATION_PROGRAM }
$BUTTON_DownloadActivationProgram = New-Button -UAC 'Activation Program' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartActivationProgram = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartActivationProgram.Add_CheckStateChanged( {
    $BUTTON_DownloadActivationProgram.Text = "Activation Program$(if ($CHECKBOX_StartActivationProgram.Checked) { $REQUIRES_ELEVATION })"
} )
