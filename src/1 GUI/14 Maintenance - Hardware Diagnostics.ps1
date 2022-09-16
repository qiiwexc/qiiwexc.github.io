New-GroupBox 'Hardware Diagnostics'


$BUTTON_TEXT = 'Check (C:) disk health'
$BUTTON_FUNCTION = { Start-DiskCheck $RADIO_FullDiskCheck.Checked }
New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION > $Null

$RADIO_TEXT = 'Quick scan'
$RADIO_QuickDiskCheck = New-RadioButton $RADIO_TEXT -Checked

$RADIO_TEXT = 'Full scan'
$RADIO_FullDiskCheck = New-RadioButton $RADIO_TEXT


$BUTTON_DownloadVictoria = New-Button -UAC 'Victoria (HDD scan)'
$BUTTON_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVictoria.Add_CheckStateChanged( { $BUTTON_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CHECKBOX_StartVictoria.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_FUNCTION = { Start-MemoryCheckTool }
New-Button 'RAM checking utility' $BUTTON_FUNCTION > $Null
