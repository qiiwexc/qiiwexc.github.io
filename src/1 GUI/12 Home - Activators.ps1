Set-Variable -Option Constant GROUP_Activators (New-Object System.Windows.Forms.GroupBox)
$GROUP_Activators.Text = 'Activators'
$GROUP_Activators.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 2
$GROUP_Activators.Width = $WIDTH_GROUP
$GROUP_Activators.Location = $GROUP_General.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_HOME.Controls.Add($GROUP_Activators)


Set-Variable -Option Constant BUTTON_DownloadKMSAuto (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadKMSAuto, "Download KMSAuto Lite`nActivates Windows 7 - 11 and Office 2010 - 2021`n`n$TXT_AV_WARNING")
$BUTTON_DownloadKMSAuto.Font = $BUTTON_FONT
$BUTTON_DownloadKMSAuto.Height = $HEIGHT_BUTTON
$BUTTON_DownloadKMSAuto.Width = $WIDTH_BUTTON
$BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$REQUIRES_ELEVATION"
$BUTTON_DownloadKMSAuto.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartKMSAuto.Checked $URL_KMS_AUTO_LITE } )
$GROUP_Activators.Controls.Add($BUTTON_DownloadKMSAuto)


Set-Variable -Option Constant CHECKBOX_StartKMSAuto (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartKMSAuto, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartKMSAuto.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartKMSAuto.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartKMSAuto.Size = $CHECKBOX_SIZE
$CHECKBOX_StartKMSAuto.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartKMSAuto.Location = $BUTTON_DownloadKMSAuto.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartKMSAuto.Add_CheckStateChanged( { $BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CHECKBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Activators.Controls.Add($CHECKBOX_StartKMSAuto)


Set-Variable -Option Constant BUTTON_DownloadAAct (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadAAct, "Download AAct`nActivates Windows 7 - 11 and Office 2010 - 2021`n`n$TXT_AV_WARNING")
$BUTTON_DownloadAAct.Font = $BUTTON_FONT
$BUTTON_DownloadAAct.Height = $HEIGHT_BUTTON
$BUTTON_DownloadAAct.Width = $WIDTH_BUTTON
$BUTTON_DownloadAAct.Text = "AAct (Win 7+, Office)$REQUIRES_ELEVATION"
$BUTTON_DownloadAAct.Location = $BUTTON_DownloadKMSAuto.Location + $SHIFT_BUTTON_LONG
$BUTTON_DownloadAAct.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked $URL_AACT } )
$GROUP_Activators.Controls.Add($BUTTON_DownloadAAct)


Set-Variable -Option Constant CHECKBOX_StartAAct (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartAAct, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartAAct.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartAAct.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartAAct.Size = $CHECKBOX_SIZE
$CHECKBOX_StartAAct.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartAAct.Location = $BUTTON_DownloadAAct.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartAAct.Add_CheckStateChanged( { $BUTTON_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CHECKBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Activators.Controls.Add($CHECKBOX_StartAAct)
