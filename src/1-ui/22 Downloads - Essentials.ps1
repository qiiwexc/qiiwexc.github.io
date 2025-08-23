New-GroupBox 'Essentials'


$BUTTON_DownloadSDI = New-Button -UAC 'Snappy Driver Installer'
$BUTTON_DownloadSDI.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked $URL_SDIO } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartSDI.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadOffice = New-Button -UAC 'Office 2013 - 2024'
$BUTTON_DownloadOffice.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked $URL_OFFICE } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartOffice = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartOffice.Add_CheckStateChanged( { $BUTTON_DownloadOffice.Text = "Office 2013 - 2024$(if ($CHECKBOX_StartOffice.Checked) { $REQUIRES_ELEVATION })" } )



$BUTTON_DownloadUnchecky = New-Button -UAC 'Unchecky'
$BUTTON_DownloadUnchecky.Add_Click( {
        Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
        Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked $URL_UNCHECKY -Params:$Params -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked
    } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
        $BUTTON_DownloadUnchecky.Text = "Unchecky$(if ($CHECKBOX_StartUnchecky.Checked) { $REQUIRES_ELEVATION })"
        $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked
    } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
