New-GroupBox 'HDD Diagnostics' 5


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA }
$BUTTON_DownloadVictoria = New-Button -UAC 'Victoria' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVictoria.Add_CheckStateChanged( {
    $BUTTON_DownloadVictoria.Text = "Victoria$(if ($CHECKBOX_StartVictoria.Checked) { $REQUIRES_ELEVATION })"
} )
