New-GroupBox 'Optimization'


$BUTTON_TOOLTIP_TEXT = 'Set DNS server to CouldFlare DNS'
$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-Button -UAC 'Setup CloudFlare DNS' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$CHECKBOX_TOOLTIP = 'Use CloudFlare DNS variation with malware protection (1.1.1.2)'
$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked -ToolTip $CHECKBOX_TOOLTIP
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked } )


$CHECKBOX_TOOLTIP = 'Use CloudFlare DNS variation with malware protection and adult content filtering (1.1.1.3)'
$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering' -ToolTip $CHECKBOX_TOOLTIP


$BUTTON_TOOLTIP_TEXT = 'Perform drive optimization (SSD) or defragmentation (HDD)'
$BUTTON_FUNCTION = { Start-DriveOptimization }
New-Button -UAC 'Optimize / defrag drives' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null
