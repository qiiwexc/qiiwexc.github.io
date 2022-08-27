New-GroupBox 'Essentials'


$BUTTON_DownloadSDI = New-Button -UAC 'Snappy Driver Installer' -ToolTip 'Download Snappy Driver Installer'
$BUTTON_DownloadSDI.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked $URL_SDI } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartSDI.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadUnchecky = New-Button -UAC 'Unchecky' -ToolTip "Download Unchecky installer`n$TXT_UNCHECKY_INFO"
$BUTTON_DownloadUnchecky.Add_Click( {
        Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
        Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked $URL_UNCHECKY -Params:$Params -SilentInstall:$CHECKBOX_SilentlyInstallUnchecky.Checked
    } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
        $BUTTON_DownloadUnchecky.Text = "Unchecky$(if ($CHECKBOX_StartUnchecky.Checked) { $REQUIRES_ELEVATION })"
        $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked
    } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED -ToolTip 'Perform silent installation with no prompts'
$CHECKBOX_SilentlyInstallUnchecky.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadOffice = New-Button -UAC 'Office 2013 - 2021' -ToolTip "Download Microsoft Office 2013 - 2021 C2R installer and activator`n`n$TXT_AV_WARNING"
$BUTTON_DownloadOffice.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked $URL_OFFICE } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartOffice = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartOffice.Add_CheckStateChanged( { $BUTTON_DownloadOffice.Text = "Office 2013 - 2021$(if ($CHECKBOX_StartOffice.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_TOOLTIP_TEXT = 'Check for Microsoft Windows, Microsoft Office and Microsoft Store apps updates, download and install if available'
$BUTTON_FUNCTION = { Start-Updates }
New-Button -UAC 'Check for Updates' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Block ads and pop-ups on websites'
$BUTTON_DISABLED = !(Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_ADBLOCK }
New-Button 'AdBlock' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
