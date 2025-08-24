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



$BUTTON_DownloadAAct = New-Button -UAC 'AAct'
$BUTTON_DownloadAAct.Add_Click( {
    Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyRunAAct.Checked) {if ($RADIO_AActWindows.Checked) { '/win=act /taskwin' } elseif ($RADIO_AActOffice.Checked) { '/ofs=act /taskofs' }})
    Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked $URL_AACT -Params:$Params -Silent:$CHECKBOX_SilentlyRunAAct.Checked
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartAAct = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartAAct.Add_CheckStateChanged( {
    $BUTTON_DownloadAAct.Text = "AAct$(if ($CHECKBOX_StartAAct.Checked) { $REQUIRES_ELEVATION })"
    $CHECKBOX_SilentlyRunAAct.Enabled = $CHECKBOX_StartAAct.Checked
    $RADIO_AActWindows.Enabled = $CHECKBOX_StartAAct.Checked
    $RADIO_AActOffice.Enabled = $CHECKBOX_StartAAct.Checked
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyRunAAct = New-CheckBox 'Activate silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_SilentlyRunAAct.Add_CheckStateChanged( {
    $RADIO_AActWindows.Enabled = $CHECKBOX_SilentlyRunAAct.Checked
    $RADIO_AActOffice.Enabled = $OFFICE_VERSION -and $CHECKBOX_SilentlyRunAAct.Checked
} )

$RADIO_AActWindows = New-RadioButton 'Windows' -Checked

$RADIO_DISABLED = !$OFFICE_VERSION
$RADIO_AActOffice = New-RadioButton 'Office' -Disabled:$RADIO_DISABLED
