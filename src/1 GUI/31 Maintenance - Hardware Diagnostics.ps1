New-GroupBox 'Hardware Diagnostics'


$BUTTON_TEXT = 'Check (C:) disk health'
$BUTTON_TOOLTIP_TEXT = 'Start (C:) disk health check'
$BUTTON_FUNCTION = { Start-DiskCheck $RADIO_FullDiskCheck.Checked }
New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


Set-Variable -Option Constant RADIO_QuickDiskCheck (New-Object System.Windows.Forms.RadioButton)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RADIO_QuickDiskCheck, 'Perform a quick disk scan')
$RADIO_QuickDiskCheck.Checked = $True
$RADIO_QuickDiskCheck.Text = 'Quick scan'
$RADIO_QuickDiskCheck.Location = $PREVIOUS_BUTTON.Location + "10, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
$RADIO_QuickDiskCheck.Size = "80, 20"
$CURRENT_GROUP.Controls.Add($RADIO_QuickDiskCheck)


Set-Variable -Option Constant RADIO_FullDiskCheck (New-Object System.Windows.Forms.RadioButton)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RADIO_FullDiskCheck, 'Schedule a full disk scan on next restart')
$RADIO_FullDiskCheck.Text = 'Full scan'
$RADIO_FullDiskCheck.Location = $RADIO_QuickDiskCheck.Location + "80, 0"
$RADIO_FullDiskCheck.Size = "80, 20"
$CURRENT_GROUP.Controls.Add($RADIO_FullDiskCheck)


$BUTTON_DownloadVictoria = New-Button -UAC 'Victoria (HDD scan)' -ToolTip 'Download Victoria HDD scanner'
$BUTTON_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVictoria.Add_CheckStateChanged( { $BUTTON_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CHECKBOX_StartVictoria.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_TOOLTIP_TEXT = 'Start RAM checking utility'
$BUTTON_FUNCTION = { Start-MemoryCheckTool }
New-Button 'RAM checking utility' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
