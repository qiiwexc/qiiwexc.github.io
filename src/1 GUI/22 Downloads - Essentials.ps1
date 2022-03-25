Set-Variable -Option Constant GROUP_Essentials (New-Object System.Windows.Forms.GroupBox)
$GROUP_Essentials.Text = 'Essentials'
$GROUP_Essentials.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 3 + $INTERVAL_CHECKBOX_SHORT - $INTERVAL_SHORT
$GROUP_Essentials.Width = $WIDTH_GROUP
$GROUP_Essentials.Location = $GROUP_Ninite.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_DOWNLOADS.Controls.Add($GROUP_Essentials)


Set-Variable -Option Constant BUTTON_DownloadSDI (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadSDI, 'Download Snappy Driver Installer')
$BUTTON_DownloadSDI.Font = $BUTTON_FONT
$BUTTON_DownloadSDI.Height = $HEIGHT_BUTTON
$BUTTON_DownloadSDI.Width = $WIDTH_BUTTON
$BUTTON_DownloadSDI.Text = "Snappy Driver Installer$REQUIRES_ELEVATION"
$BUTTON_DownloadSDI.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_DownloadSDI.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked $URL_SDI } )
$GROUP_Essentials.Controls.Add($BUTTON_DownloadSDI)
$PREVIOUS_BUTTON = $BUTTON_DownloadSDI


Set-Variable -Option Constant CHECKBOX_StartSDI (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartSDI, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartSDI.Checked = $True
$CHECKBOX_StartSDI.Size = $CHECKBOX_SIZE
$CHECKBOX_StartSDI.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartSDI.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartSDI.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Essentials.Controls.Add($CHECKBOX_StartSDI)


Set-Variable -Option Constant BUTTON_DownloadUnchecky (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadUnchecky, "Download Unchecky installer`n$TXT_UNCHECKY_INFO")
$BUTTON_DownloadUnchecky.Font = $BUTTON_FONT
$BUTTON_DownloadUnchecky.Height = $HEIGHT_BUTTON
$BUTTON_DownloadUnchecky.Width = $WIDTH_BUTTON
$BUTTON_DownloadUnchecky.Text = "Unchecky$REQUIRES_ELEVATION"
$BUTTON_DownloadUnchecky.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_DownloadUnchecky.Add_Click( {
        Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
        Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked $URL_UNCHECKY -Params:$Params -SilentInstall:$CHECKBOX_SilentlyInstallUnchecky.Checked
    } )
$GROUP_Essentials.Controls.Add($BUTTON_DownloadUnchecky)
$PREVIOUS_BUTTON = $BUTTON_DownloadUnchecky


Set-Variable -Option Constant CHECKBOX_StartUnchecky (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartUnchecky, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartUnchecky.Checked = $True
$CHECKBOX_StartUnchecky.Size = $CHECKBOX_SIZE
$CHECKBOX_StartUnchecky.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartUnchecky.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( { $BUTTON_DownloadUnchecky.Text = "Unchecky$(if ($CHECKBOX_StartUnchecky.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Essentials.Controls.Add($CHECKBOX_StartUnchecky)
$PREVIOUS_BUTTON = $CHECKBOX_StartUnchecky


Set-Variable -Option Constant CHECKBOX_SilentlyInstallUnchecky (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_SilentlyInstallUnchecky, 'Perform silent installation with no prompts')
$CHECKBOX_SilentlyInstallUnchecky.Checked = $True
$CHECKBOX_SilentlyInstallUnchecky.Size = $CHECKBOX_SIZE
$CHECKBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CHECKBOX_SilentlyInstallUnchecky.Location = $PREVIOUS_BUTTON.Location + "0, $HEIGHT_CHECKBOX"
$GROUP_Essentials.Controls.Add($CHECKBOX_SilentlyInstallUnchecky)


Set-Variable -Option Constant BUTTON_DownloadOffice (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadOffice, "Download Microsoft Office 2013 - 2021 C2R installer and activator`n`n$TXT_AV_WARNING")
$BUTTON_DownloadOffice.Font = $BUTTON_FONT
$BUTTON_DownloadOffice.Height = $HEIGHT_BUTTON
$BUTTON_DownloadOffice.Width = $WIDTH_BUTTON
$BUTTON_DownloadOffice.Text = "Office 2013 - 2021$REQUIRES_ELEVATION"
$BUTTON_DownloadOffice.Location = $BUTTON_DownloadUnchecky.Location + $SHIFT_BUTTON_SHORT + $SHIFT_BUTTON_NORMAL
$BUTTON_DownloadOffice.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked $URL_OFFICE } )
$GROUP_Essentials.Controls.Add($BUTTON_DownloadOffice)
$PREVIOUS_BUTTON = $BUTTON_DownloadOffice


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
