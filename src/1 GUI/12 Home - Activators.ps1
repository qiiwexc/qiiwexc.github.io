New-GroupBox 'Activators'


$BUTTON_DownloadKMSAuto = New-Button -UAC 'KMSAuto Lite' -ToolTip "Download KMSAuto Lite`nActivates Windows 7 - 11 and Office 2010 - 2021`n`n$TXT_AV_WARNING"
$BUTTON_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartKMSAuto.Checked $URL_KMS_AUTO_LITE } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartKMSAuto = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartKMSAuto.Add_CheckStateChanged( { $BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CHECKBOX_StartKMSAuto.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadAAct = New-Button -UAC 'AAct (Win 7+, Office)' -ToolTip "Download AAct`nActivates Windows 7 - 11 and Office 2010 - 2021`n`n$TXT_AV_WARNING"
$BUTTON_DownloadAAct.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked $URL_AACT } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartAAct = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartAAct.Add_CheckStateChanged( { $BUTTON_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CHECKBOX_StartAAct.Checked) { $REQUIRES_ELEVATION })" } )
