New-GroupBox 'Bootable USB Tools'


$BUTTON_DownloadVentoy = New-Button -UAC 'Ventoy'
$BUTTON_DownloadVentoy.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVentoy.Checked $URL_VENTOY $((Split-Path -Leaf $URL_VENTOY) -Replace '-windows', '') } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVentoy.Add_CheckStateChanged( { $BUTTON_DownloadVentoy.Text = "Ventoy$(if ($CHECKBOX_StartVentoy.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadRufus = New-Button -UAC 'Rufus'
$BUTTON_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartRufus.Add_CheckStateChanged( { $BUTTON_DownloadRufus.Text = "Rufus$(if ($CHECKBOX_StartRufus.Checked) { $REQUIRES_ELEVATION })" } )
