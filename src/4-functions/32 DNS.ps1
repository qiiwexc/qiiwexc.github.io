Function Set-CloudFlareDNS {
    [String]$PreferredDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.1.1.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.1.1.2' } else { '1.1.1.1' } };
    [String]$AlternateDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.0.0.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.0.0.2' } else { '1.0.0.1' } };

    Add-Log $WRN 'Internet connection may get interrupted briefly'
    Add-Log $INF "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."

    if (!(Get-NetworkAdapter)) {
        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Add-Log $ERR 'This could mean that computer is not connected'
        Return
    }

    try {
        Start-Script -Elevated -HideWindow "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('$PreferredDnsServer', '$AlternateDnsServer'))"
    } catch [Exception] {
        Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"
        Return
    }

    Out-Success
}
