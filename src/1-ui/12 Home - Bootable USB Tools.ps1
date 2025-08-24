New-GroupBox 'Bootable USB Tools'


$BUTTON_DownloadVentoy = New-Button -UAC 'Ventoy'
$BUTTON_DownloadVentoy.Add_Click( {
    Set-Variable -Option Constant FileName $((Split-Path -Leaf $URL_VENTOY) -Replace '-windows', '')
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVentoy.Checked $URL_VENTOY -FileName:$FileName
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVentoy.Add_CheckStateChanged( {
    $BUTTON_DownloadVentoy.Text = "Ventoy$(if ($CHECKBOX_StartVentoy.Checked) { $REQUIRES_ELEVATION })"
} )


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' }
$BUTTON_DownloadRufus = New-Button -UAC 'Rufus' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartRufus.Add_CheckStateChanged( {
    $BUTTON_DownloadRufus.Text = "Rufus$(if ($CHECKBOX_StartRufus.Checked) { $REQUIRES_ELEVATION })"
} )
