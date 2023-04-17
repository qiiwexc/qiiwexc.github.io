New-GroupBox 'Activators (Windows 7+, Office)'


$BUTTON_DownloadAAct = New-Button -UAC 'AAct'
$BUTTON_DownloadAAct.Add_Click( {
        Set-Variable -Option Constant Params $(if ($RADIO_AActWindows.Checked) { '/win=act /taskwin' } elseif ($RADIO_AActOffice.Checked) { '/ofs=act /taskofs' })
        Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked 'https://qiiwexc.github.io/d/AAct.zip' -Params:$Params -Silent:$CHECKBOX_SilentlyRunAAct.Checked
    } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartAAct = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartAAct.Add_CheckStateChanged( { $BUTTON_DownloadAAct.Text = "AAct$(if ($CHECKBOX_StartAAct.Checked) { $REQUIRES_ELEVATION })" } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyRunAAct = New-CheckBox 'Activate silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_SilentlyRunAAct.Add_CheckStateChanged( {
        $RADIO_AActWindows.Enabled = $CHECKBOX_SilentlyRunAAct.Checked
        $RADIO_AActOffice.Enabled = $OFFICE_VERSION -and $CHECKBOX_SilentlyRunAAct.Checked
    } )

$RADIO_AActWindows = New-RadioButton 'Windows' -Checked

$RADIO_DISABLED = !$OFFICE_VERSION
$RADIO_AActOffice = New-RadioButton 'Office' -Disabled:$RADIO_DISABLED



$BUTTON_DownloadKMSAuto = New-Button -UAC 'KMSAuto Lite'
$BUTTON_DownloadKMSAuto.Add_Click( {
        Set-Variable -Option Constant Params $(if ($RADIO_KMSAutoWindows.Checked) { '/win=act /sched=win' } elseif ($RADIO_KMSAutoOffice.Checked) { '/ofs=act /sched=ofs' })
        Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartKMSAuto.Checked 'https://qiiwexc.github.io/d/KMSAuto_Lite.zip' -Params:$Params -Silent:$CHECKBOX_SilentlyRunKMSAuto.Checked
    } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartKMSAuto = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartKMSAuto.Add_CheckStateChanged( {
        $BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CHECKBOX_StartKMSAuto.Checked) { $REQUIRES_ELEVATION })"
        $CHECKBOX_SilentlyRunKMSAuto.Enabled = $CHECKBOX_StartKMSAuto.Checked
    } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyRunKMSAuto = New-CheckBox 'Activate silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_SilentlyRunKMSAuto.Add_CheckStateChanged( {
        $RADIO_KMSAutoWindows.Enabled = $CHECKBOX_SilentlyRunKMSAuto.Checked
        $RADIO_KMSAutoOffice.Enabled = $OFFICE_VERSION -and $CHECKBOX_SilentlyRunKMSAuto.Checked
    } )

$RADIO_KMSAutoWindows = New-RadioButton 'Windows' -Checked

$RADIO_DISABLED = !$OFFICE_VERSION
$RADIO_KMSAutoOffice = New-RadioButton 'Office' -Disabled:$RADIO_DISABLED
