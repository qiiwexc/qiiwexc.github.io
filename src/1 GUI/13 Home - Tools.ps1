New-GroupBox 'Tools'


$BUTTON_DownloadRufus = New-Button -UAC 'Rufus (bootable USB)'
$BUTTON_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartRufus.Add_CheckStateChanged( { $BUTTON_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CHECKBOX_StartRufus.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_FUNCTION = { Open-InBrowser 'https://rutracker.org/forum/viewtopic.php?t=4366725' }
New-ButtonBrowser 'Windows PE (Live CD)' $BUTTON_FUNCTION
