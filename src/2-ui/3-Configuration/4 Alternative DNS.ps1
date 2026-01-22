New-GroupBox 'Alternative DNS' 4


[ScriptBlock]$BUTTON_FUNCTION = { Set-CloudFlareDNS -MalwareProtection:$CHECKBOX_CloudFlareAntiMalware.Checked -FamilyFriendly:$CHECKBOX_CloudFlareFamilyFriendly.Checked }
New-Button 'Setup CloudFlare DNS' $BUTTON_FUNCTION

[Windows.Forms.CheckBox]$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( {
        Set-CheckboxState -Control $CHECKBOX_CloudFlareAntiMalware -Dependant $CHECKBOX_CloudFlareFamilyFriendly
    } )

[Windows.Forms.CheckBox]$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'
