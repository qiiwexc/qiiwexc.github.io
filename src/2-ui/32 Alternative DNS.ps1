New-GroupBox 'Alternative DNS'


$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-Button 'Setup CloudFlare DNS' $BUTTON_FUNCTION | Out-Null

$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( {
    $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked
} )

$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'
