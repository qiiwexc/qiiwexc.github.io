$GROUP_TEXT = 'Optimization'
$GROUP_LOCATION = $GROUP_Cleanup.Location + "0, $($GROUP_Cleanup.Height + $INTERVAL_NORMAL)"
$GROUP_Optimization = New-GroupBox $GROUP_TEXT $GROUP_LOCATION


$BUTTON_TEXT = 'Setup CloudFlare DNS'
$TOOLTIP_TEXT = 'Set DNS server to CouldFlare DNS'
$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null


Set-Variable -Option Constant CHECKBOX_CloudFlareAntiMalware (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_CloudFlareAntiMalware, 'Use CloudFlare DNS variation with malware protection (1.1.1.2)')
$CHECKBOX_CloudFlareAntiMalware.Size = $CHECKBOX_SIZE
$CHECKBOX_CloudFlareAntiMalware.Text = 'Malware protection'
$CHECKBOX_CloudFlareAntiMalware.Checked = $True
$CHECKBOX_CloudFlareAntiMalware.Location = $PREVIOUS_BUTTON.Location + "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked } )
$GROUP_Optimization.Controls.Add($CHECKBOX_CloudFlareAntiMalware)


Set-Variable -Option Constant CHECKBOX_CloudFlareFamilyFriendly (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_CloudFlareFamilyFriendly, 'Use CloudFlare DNS variation with malware protection and adult content filtering (1.1.1.3)')
$CHECKBOX_CloudFlareFamilyFriendly.Size = $CHECKBOX_SIZE
$CHECKBOX_CloudFlareFamilyFriendly.Text = 'Adult content filtering'
$CHECKBOX_CloudFlareFamilyFriendly.Location = $CHECKBOX_CloudFlareAntiMalware.Location + "0, $CHECKBOX_HEIGHT"
$GROUP_Optimization.Controls.Add($CHECKBOX_CloudFlareFamilyFriendly)


$BUTTON_TEXT = 'Optimize / defrag drives'
$TOOLTIP_TEXT = 'Perform drive optimization (SSD) or defragmentation (HDD)'
$BUTTON_FUNCTION = { Start-DriveOptimization }
New-ButtonUAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $TOOLTIP_TEXT > $Null
