$GROUP_TEXT = 'Activators'
$GROUP_LOCATION = $GROUP_General.Location + $SHIFT_GROUP_HORIZONTAL
$GROUP_Activators = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'KMSAuto Lite'
$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartKMSAuto.Checked $URL_KMS_AUTO_LITE }
$BUTTON_DownloadKMSAuto = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION


$CHECKBOX_TEXT = $TXT_START_AFTER_DOWNLOAD
$TOOLTIP_TEXT = $TXT_TIP_START_AFTER_DOWNLOAD
$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = -not $CHECKBOX_DISABLED
$CHECKBOX_HOOK = { $PREVIOUS_BUTTON.Text = "KMSAuto Lite$(if ($CHECKBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" }
$CHECKBOX_StartKMSAuto = New-CheckBox $CHECKBOX_TEXT $BUTTON_FUNCTION -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED -ToolTip $TOOLTIP_TEXT
$CHECKBOX_StartKMSAuto.Add_CheckStateChanged($CHECKBOX_HOOK)

Set-Variable -Option Constant CHECKBOX_StartKMSAuto (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartKMSAuto, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartKMSAuto.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartKMSAuto.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartKMSAuto.Size = $CHECKBOX_SIZE
$CHECKBOX_StartKMSAuto.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartKMSAuto.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartKMSAuto.Add_CheckStateChanged( { $BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CHECKBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )
$CURRENT_GROUP.Controls.Add($CHECKBOX_StartKMSAuto)


$BUTTON_TEXT = 'AAct (Win 7+, Office)'
$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked $URL_AACT }
$BUTTON_DownloadAAct = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION


Set-Variable -Option Constant CHECKBOX_StartAAct (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartAAct, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartAAct.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartAAct.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartAAct.Size = $CHECKBOX_SIZE
$CHECKBOX_StartAAct.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartAAct.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartAAct.Add_CheckStateChanged( { $BUTTON_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CHECKBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )
$CURRENT_GROUP.Controls.Add($CHECKBOX_StartAAct)
