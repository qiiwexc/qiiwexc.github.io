New-GroupBox 'Essentials'


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked '{URL_SDIO}' }
$BUTTON_DownloadSDI = New-Button -UAC 'Snappy Driver Installer' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartSDI.Add_CheckStateChanged( {
    $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })"
} )


$BUTTON_FUNCTION = { Start-OfficeInstaller -Execute:$CHECKBOX_StartOfficeInstaller.Checked }
$BUTTON_DownloadOfficeInstaller = New-Button -UAC 'Office Installer+' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartOfficeInstaller = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartOfficeInstaller.Add_CheckStateChanged( {
    $BUTTON_DownloadOfficeInstaller.Text = "Office Installer+$(if ($CHECKBOX_StartOfficeInstaller.Checked) { $REQUIRES_ELEVATION })"
} )



$BUTTON_DownloadUnchecky = New-Button -UAC 'Unchecky'
$BUTTON_DownloadUnchecky.Add_Click( {
    Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked '{URL_UNCHECKY}' -Params:$Params -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked
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
