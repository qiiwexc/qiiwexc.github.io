Set-Variable -Option Constant GROUP_Hardware (New-Object System.Windows.Forms.GroupBox)
$GROUP_Hardware.Text = 'Hardware Diagnostics'
$GROUP_Hardware.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 2 + $INTERVAL_BUTTON_NORMAL
$GROUP_Hardware.Width = $WIDTH_GROUP
$GROUP_Hardware.Location = $INITIAL_LOCATION_GROUP
$TAB_MAINTENANCE.Controls.Add($GROUP_Hardware)
$GROUP = $GROUP_Hardware


Set-Variable -Option Constant BUTTON_CheckDisk (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CheckDisk, 'Start (C:) disk health check')
$BUTTON_CheckDisk.Font = $BUTTON_FONT
$BUTTON_CheckDisk.Height = $HEIGHT_BUTTON
$BUTTON_CheckDisk.Width = $WIDTH_BUTTON
$BUTTON_CheckDisk.Text = "Check (C:) disk health$REQUIRES_ELEVATION"
$BUTTON_CheckDisk.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_CheckDisk.Add_Click( { Start-DiskCheck $RADIO_FullDiskCheck.Checked } )
$GROUP_Hardware.Controls.Add($BUTTON_CheckDisk)


Set-Variable -Option Constant RADIO_QuickDiskCheck (New-Object System.Windows.Forms.RadioButton)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RADIO_QuickDiskCheck, 'Perform a quick disk scan')
$RADIO_QuickDiskCheck.Checked = $True
$RADIO_QuickDiskCheck.Text = 'Quick scan'
$RADIO_QuickDiskCheck.Location = $BUTTON_CheckDisk.Location + "10, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
$RADIO_QuickDiskCheck.Size = "80, 20"
$GROUP_Hardware.Controls.Add($RADIO_QuickDiskCheck)


Set-Variable -Option Constant RADIO_FullDiskCheck (New-Object System.Windows.Forms.RadioButton)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RADIO_FullDiskCheck, 'Schedule a full disk scan on next restart')
$RADIO_FullDiskCheck.Text = 'Full scan'
$RADIO_FullDiskCheck.Location = $RADIO_QuickDiskCheck.Location + "80, 0"
$RADIO_FullDiskCheck.Size = "80, 20"
$GROUP_Hardware.Controls.Add($RADIO_FullDiskCheck)


Set-Variable -Option Constant BUTTON_DownloadVictoria (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadVictoria, 'Download Victoria HDD scanner')
$BUTTON_DownloadVictoria.Font = $BUTTON_FONT
$BUTTON_DownloadVictoria.Height = $HEIGHT_BUTTON
$BUTTON_DownloadVictoria.Width = $WIDTH_BUTTON
$BUTTON_DownloadVictoria.Text = "Victoria (HDD scan)$REQUIRES_ELEVATION"
$BUTTON_DownloadVictoria.Location = $BUTTON_CheckDisk.Location + $SHIFT_BUTTON_LONG
$BUTTON_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA } )
$GROUP_Hardware.Controls.Add($BUTTON_DownloadVictoria)


Set-Variable -Option Constant CHECKBOX_StartVictoria (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartVictoria, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartVictoria.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartVictoria.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartVictoria.Size = $CHECKBOX_SIZE
$CHECKBOX_StartVictoria.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartVictoria.Location = $BUTTON_DownloadVictoria.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartVictoria.Add_CheckStateChanged( { $BUTTON_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CHECKBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Hardware.Controls.Add($CHECKBOX_StartVictoria)


Set-Variable -Option Constant BUTTON_CheckRAM (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CheckRAM, 'Start RAM checking utility')
$BUTTON_CheckRAM.Font = $BUTTON_FONT
$BUTTON_CheckRAM.Height = $HEIGHT_BUTTON
$BUTTON_CheckRAM.Width = $WIDTH_BUTTON
$BUTTON_CheckRAM.Text = 'RAM checking utility'
$BUTTON_CheckRAM.Location = $BUTTON_DownloadVictoria.Location + $SHIFT_BUTTON_LONG
$BUTTON_CheckRAM.Add_Click( { Start-MemoryCheckTool } )
$GROUP_Hardware.Controls.Add($BUTTON_CheckRAM)
