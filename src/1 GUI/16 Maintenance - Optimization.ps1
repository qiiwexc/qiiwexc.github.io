New-GroupBox 'Optimization'


$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-Button -UAC 'Setup CloudFlare DNS' $BUTTON_FUNCTION > $Null

$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked } )

$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'


$BUTTON_FUNCTION = { Start-DriveOptimization }
New-Button -UAC 'Optimize / defrag drives' $BUTTON_FUNCTION > $Null
