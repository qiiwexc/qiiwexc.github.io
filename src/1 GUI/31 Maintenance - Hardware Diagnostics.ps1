$GROUP_TEXT = 'Hardware Diagnostics'
$GROUP_LOCATION = $INITIAL_LOCATION_GROUP
$GROUP_Hardware = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'Check (C:) disk health'
$TOOLTIP_TEXT = 'Start (C:) disk health check'
$BUTTON_FUNCTION = { Start-DiskCheck $RADIO_FullDiskCheck.Checked }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null


Set-Variable -Option Constant RADIO_QuickDiskCheck (New-Object System.Windows.Forms.RadioButton)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RADIO_QuickDiskCheck, 'Perform a quick disk scan')
$RADIO_QuickDiskCheck.Checked = $True
$RADIO_QuickDiskCheck.Text = 'Quick scan'
$RADIO_QuickDiskCheck.Location = $PREVIOUS_BUTTON.Location + "10, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
$RADIO_QuickDiskCheck.Size = "80, 20"
$GROUP_Hardware.Controls.Add($RADIO_QuickDiskCheck)


Set-Variable -Option Constant RADIO_FullDiskCheck (New-Object System.Windows.Forms.RadioButton)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RADIO_FullDiskCheck, 'Schedule a full disk scan on next restart')
$RADIO_FullDiskCheck.Text = 'Full scan'
$RADIO_FullDiskCheck.Location = $RADIO_QuickDiskCheck.Location + "80, 0"
$RADIO_FullDiskCheck.Size = "80, 20"
$GROUP_Hardware.Controls.Add($RADIO_FullDiskCheck)


$BUTTON_TEXT = 'Victoria (HDD scan)'
$TOOLTIP_TEXT = 'Download Victoria HDD scanner'
$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA }
$BUTTON_DownloadVictoria = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT


Set-Variable -Option Constant CHECKBOX_StartVictoria (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartVictoria, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartVictoria.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartVictoria.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartVictoria.Size = $CHECKBOX_SIZE
$CHECKBOX_StartVictoria.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartVictoria.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartVictoria.Add_CheckStateChanged( { $BUTTON_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CHECKBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Hardware.Controls.Add($CHECKBOX_StartVictoria)


$BUTTON_TEXT = 'RAM checking utility'
$TOOLTIP_TEXT = 'Start RAM checking utility'
$BUTTON_FUNCTION = { Start-MemoryCheckTool }
New-Button $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null
