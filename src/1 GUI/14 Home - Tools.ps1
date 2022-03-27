New-GroupBox 'Tools'


$BUTTON_DownloadCCleaner = New-Button -UAC 'CCleaner' -ToolTip 'Download CCleaner installer'
$BUTTON_DownloadCCleaner.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartCCleaner.Checked $URL_CCLEANER } )


$CHECKBOX_StartCCleaner = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartCCleaner.Add_CheckStateChanged( { $BUTTON_DownloadCCleaner.Text = "CCleaner$(if ($CHECKBOX_StartCCleaner.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadRufus = New-Button -UAC 'Rufus (bootable USB)' -ToolTip 'Download Rufus - a bootable USB creator'
$BUTTON_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartRufus.Add_CheckStateChanged( { $BUTTON_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CHECKBOX_StartRufus.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_PE }
New-ButtonBrowser 'Windows PE (Live CD)' $BUTTON_FUNCTION -ToolTip 'Download Windows PE (Live CD) ISO image based on Windows 10'
