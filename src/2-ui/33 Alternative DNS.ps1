New-GroupBox 'Alternative DNS'


[ScriptBlock]$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-Button 'Setup CloudFlare DNS' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( {
        $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'
