New-GroupBox 'Optimization'


$BUTTON_FUNCTION = { Start-DiskCleanup }
New-Button 'Start disk cleanup' $BUTTON_FUNCTION > $Null


$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-Button -UAC 'Setup CloudFlare DNS' $BUTTON_FUNCTION > $Null

$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked } )

$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'
