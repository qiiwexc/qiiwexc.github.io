$GROUP_TEXT = 'Tools'
$GROUP_LOCATION = $GROUP_General.Location + "0, $($GROUP_General.Height + $INTERVAL_NORMAL)"
$GROUP_Tools = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'CCleaner'
$TOOLTIP_TEXT = 'Download CCleaner installer'
$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartCCleaner.Checked $URL_CCLEANER }
$BUTTON_DownloadCCleaner = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT


Set-Variable -Option Constant CHECKBOX_StartCCleaner (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartCCleaner, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartCCleaner.Size = $CHECKBOX_SIZE
$CHECKBOX_StartCCleaner.Checked = $True
$CHECKBOX_StartCCleaner.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartCCleaner.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartCCleaner.Add_CheckStateChanged( { $BUTTON_DownloadCCleaner.Text = "CCleaner$(if ($CHECKBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Tools.Controls.Add($CHECKBOX_StartCCleaner)


$BUTTON_TEXT = 'Rufus (bootable USB)'
$TOOLTIP_TEXT = 'Download Rufus - a bootable USB creator'
$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' }
$BUTTON_DownloadRufus = New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT


Set-Variable -Option Constant CHECKBOX_StartRufus (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartRufus, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartRufus.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartRufus.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartRufus.Size = $CHECKBOX_SIZE
$CHECKBOX_StartRufus.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartRufus.Add_CheckStateChanged( { $BUTTON_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CHECKBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Tools.Controls.Add($CHECKBOX_StartRufus)


$BUTTON_TEXT = 'Windows PE (Live CD)'
$TOOLTIP_TEXT = 'Download Windows PE (Live CD) ISO image based on Windows 10'
$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_PE }
New-ButtonBrowser $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null
