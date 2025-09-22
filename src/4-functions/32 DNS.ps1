Function Set-CloudFlareDNS {
    [String]$PreferredDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.1.1.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.1.1.2' } else { '1.1.1.1' } };
    [String]$AlternateDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.0.0.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.0.0.2' } else { '1.0.0.1' } };

    Write-Log $WRN 'Internet connection may get interrupted briefly'
    Write-Log $INF "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."

    if (!(Get-NetworkAdapter)) {
        Write-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Write-Log $ERR 'This could mean that computer is not connected'
        Return
    }

    try {
        Start-Script -Elevated -HideWindow "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('$PreferredDnsServer', '$AlternateDnsServer'))"
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to change DNS server'
        Return
    }

    Out-Success
}
