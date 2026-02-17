New-Card 'Alternative DNS'


[ScriptBlock]$BUTTON_FUNCTION = {
    $MalwareProtection = $CHECKBOX_CloudFlareAntiMalware.IsChecked
    $FamilyFriendly = $CHECKBOX_CloudFlareFamilyFriendly.IsChecked
    Set-CloudFlareDNS -MalwareProtection:$MalwareProtection -FamilyFriendly:$FamilyFriendly
}
New-Button 'Setup CloudFlare DNS' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
$CHECKBOX_CloudFlareAntiMalware.Add_Click( {
        Set-CheckboxState -Control $CHECKBOX_CloudFlareAntiMalware -Dependant $CHECKBOX_CloudFlareFamilyFriendly
    } )

[Windows.Controls.CheckBox]$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'
