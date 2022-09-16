New-GroupBox 'Activators'


$BUTTON_DownloadKMSAuto = New-Button -UAC 'KMSAuto Lite'
$BUTTON_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartKMSAuto.Checked 'https://qiiwexc.github.io/d/KMSAuto_Lite.zip' -Silent:$CHECKBOX_SilentlyRunKMSAuto.Checked } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartKMSAuto = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartKMSAuto.Add_CheckStateChanged( {
        $BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CHECKBOX_StartKMSAuto.Checked) { $REQUIRES_ELEVATION })"
        $CHECKBOX_SilentlyRunKMSAuto.Enabled = $CHECKBOX_StartKMSAuto.Checked
    } )

# $CHECKBOX_DISABLED = $PS_VERSION -le 2
# $CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
# $CHECKBOX_SilentlyRunKMSAuto = New-CheckBox 'Activate silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED


$BUTTON_DownloadAAct = New-Button -UAC 'AAct (Win 7+, Office)'
$BUTTON_DownloadAAct.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked 'https://qiiwexc.github.io/d/AAct.zip' } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartAAct = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartAAct.Add_CheckStateChanged( { $BUTTON_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CHECKBOX_StartAAct.Checked) { $REQUIRES_ELEVATION })" } )
