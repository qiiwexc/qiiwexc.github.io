New-GroupBox 'Bootable USB tools'


$BUTTON_FUNCTION = {
    Set-Variable -Option Constant FileName $((Split-Path -Leaf '{URL_VENTOY}') -Replace '-windows', '')
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVentoy.Checked '{URL_VENTOY}' -FileName:$FileName
}
New-Button 'Windows Ventoy' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked '{URL_RUFUS}' -Params:'-g' }
New-Button 'Rufus' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
