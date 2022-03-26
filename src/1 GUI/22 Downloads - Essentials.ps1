$GROUP_TEXT = 'Essentials'
$GROUP_LOCATION = $GROUP_Ninite.Location + $SHIFT_GROUP_HORIZONTAL
$GROUP_Essentials = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'Snappy Driver Installer'
$TOOLTIP_TEXT = 'Download Snappy Driver Installer'
$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked $URL_SDI }
$BUTTON_DownloadSDI = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT


Set-Variable -Option Constant CHECKBOX_StartSDI (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartSDI, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartSDI.Checked = $True
$CHECKBOX_StartSDI.Size = $CHECKBOX_SIZE
$CHECKBOX_StartSDI.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartSDI.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartSDI.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Essentials.Controls.Add($CHECKBOX_StartSDI)


$BUTTON_TEXT = 'Unchecky'
$TOOLTIP_TEXT = "Download Unchecky installer`n$TXT_UNCHECKY_INFO"
$BUTTON_FUNCTION = {
    Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked $URL_UNCHECKY -Params:$Params -SilentInstall:$CHECKBOX_SilentlyInstallUnchecky.Checked
}
$BUTTON_DownloadUnchecky = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT


Set-Variable -Option Constant CHECKBOX_StartUnchecky (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartUnchecky, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartUnchecky.Checked = $True
$CHECKBOX_StartUnchecky.Size = $CHECKBOX_SIZE
$CHECKBOX_StartUnchecky.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartUnchecky.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( { $BUTTON_DownloadUnchecky.Text = "Unchecky$(if ($CHECKBOX_StartUnchecky.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Essentials.Controls.Add($CHECKBOX_StartUnchecky)


Set-Variable -Option Constant CHECKBOX_SilentlyInstallUnchecky (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_SilentlyInstallUnchecky, 'Perform silent installation with no prompts')
$CHECKBOX_SilentlyInstallUnchecky.Checked = $True
$CHECKBOX_SilentlyInstallUnchecky.Size = $CHECKBOX_SIZE
$CHECKBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CHECKBOX_SilentlyInstallUnchecky.Location = $CHECKBOX_StartUnchecky.Location + "0, $CHECKBOX_HEIGHT"
$GROUP_Essentials.Controls.Add($CHECKBOX_SilentlyInstallUnchecky)


$BUTTON_TEXT = 'Office 2013 - 2021'
$TOOLTIP_TEXT = "Download Microsoft Office 2013 - 2021 C2R installer and activator`n`n$TXT_AV_WARNING"
$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked $URL_OFFICE }
$BUTTON_DownloadOffice = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT


Set-Variable -Option Constant CHECKBOX_StartOffice (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartOffice, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartOffice.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartOffice.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartOffice.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartOffice.Size = $CHECKBOX_SIZE
$CHECKBOX_StartOffice.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartOffice.Add_CheckStateChanged( { $BUTTON_DownloadOffice.Text = "Office 2013 - 2021$(if ($CHECKBOX_StartOffice.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Essentials.Controls.Add($CHECKBOX_StartOffice)

$CHECKBOX_StartUnchecky.Add_CheckStateChanged( { $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked } )
