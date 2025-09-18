New-GroupBox 'Hardware Info'


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartCpuZ.Checked '{URL_CPU_Z}' }
$BUTTON_DownloadCpuZ = New-Button -UAC 'CPU-Z' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartCpuZ = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartCpuZ.Add_CheckStateChanged( {
    $BUTTON_DownloadCpuZ.Text = "CPU-Z$(if ($CHECKBOX_StartCpuZ.Checked) { $REQUIRES_ELEVATION })"
} )
