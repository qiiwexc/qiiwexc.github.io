Set-Variable -Option Constant GROUP_Tools (New-Object System.Windows.Forms.GroupBox)
$GROUP_Tools.Text = 'Tools'
$GROUP_Tools.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 3
$GROUP_Tools.Width = $WIDTH_GROUP
$GROUP_Tools.Location = $GROUP_General.Location + "0, $($GROUP_General.Height + $INTERVAL_NORMAL)"
$TAB_HOME.Controls.Add($GROUP_Tools)


Set-Variable -Option Constant BUTTON_DownloadCCleaner (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadCCleaner, 'Download CCleaner installer')
$BUTTON_DownloadCCleaner.Font = $BUTTON_FONT
$BUTTON_DownloadCCleaner.Height = $HEIGHT_BUTTON
$BUTTON_DownloadCCleaner.Width = $WIDTH_BUTTON
$BUTTON_DownloadCCleaner.Text = "CCleaner$REQUIRES_ELEVATION"
$BUTTON_DownloadCCleaner.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_DownloadCCleaner.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartCCleaner.Checked $URL_CCLEANER } )
$GROUP_Tools.Controls.Add($BUTTON_DownloadCCleaner)


Set-Variable -Option Constant CHECKBOX_StartCCleaner (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartCCleaner, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartCCleaner.Size = $CHECKBOX_SIZE
$CHECKBOX_StartCCleaner.Checked = $True
$CHECKBOX_StartCCleaner.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartCCleaner.Location = $BUTTON_DownloadCCleaner.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartCCleaner.Add_CheckStateChanged( { $BUTTON_DownloadCCleaner.Text = "CCleaner$(if ($CHECKBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Tools.Controls.Add($CHECKBOX_StartCCleaner)


Set-Variable -Option Constant BUTTON_DownloadRufus (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadRufus, 'Download Rufus - a bootable USB creator')
$BUTTON_DownloadRufus.Font = $BUTTON_FONT
$BUTTON_DownloadRufus.Height = $HEIGHT_BUTTON
$BUTTON_DownloadRufus.Width = $WIDTH_BUTTON
$BUTTON_DownloadRufus.Text = "Rufus (bootable USB)$REQUIRES_ELEVATION"
$BUTTON_DownloadRufus.Location = $BUTTON_DownloadCCleaner.Location + $SHIFT_BUTTON_LONG
$BUTTON_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' } )
$GROUP_Tools.Controls.Add($BUTTON_DownloadRufus)


Set-Variable -Option Constant CHECKBOX_StartRufus (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartRufus, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartRufus.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartRufus.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartRufus.Size = $CHECKBOX_SIZE
$CHECKBOX_StartRufus.Location = $BUTTON_DownloadRufus.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartRufus.Add_CheckStateChanged( { $BUTTON_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CHECKBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Tools.Controls.Add($CHECKBOX_StartRufus)


Set-Variable -Option Constant BUTTON_WindowsPE (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 10')
$BUTTON_WindowsPE.Font = $BUTTON_FONT
$BUTTON_WindowsPE.Height = $HEIGHT_BUTTON
$BUTTON_WindowsPE.Width = $WIDTH_BUTTON
$BUTTON_WindowsPE.Text = 'Windows PE (Live CD)'
$BUTTON_WindowsPE.Location = $BUTTON_DownloadRufus.Location + $SHIFT_BUTTON_LONG
$BUTTON_WindowsPE.Add_Click( { Open-InBrowser $URL_WINDOWS_PE } )
$GROUP_Tools.Controls.Add($BUTTON_WindowsPE)


Set-Variable -Option Constant LABEL_WindowsPE (New-Object System.Windows.Forms.Label)
$LABEL_WindowsPE.Size = $CHECKBOX_SIZE
$LABEL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LABEL_WindowsPE.Location = $BUTTON_WindowsPE.Location + $SHIFT_LABEL_BROWSER
$GROUP_Tools.Controls.Add($LABEL_WindowsPE)
