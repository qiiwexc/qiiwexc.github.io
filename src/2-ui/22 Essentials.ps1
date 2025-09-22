New-GroupBox 'Essentials'


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked '{URL_SDIO}' }
New-Button 'Snappy Driver Installer' $BUTTON_FUNCTION | Out-Null

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED


$BUTTON_FUNCTION = { Start-OfficeInstaller -Execute:$CHECKBOX_StartOfficeInstaller.Checked }
New-Button 'Office Installer+' $BUTTON_FUNCTION | Out-Null

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartOfficeInstaller = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED



$BUTTON_DownloadUnchecky = New-Button 'Unchecky'
$BUTTON_DownloadUnchecky.Add_Click( {
    Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked '{URL_UNCHECKY}' -Params:$Params -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
    $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
