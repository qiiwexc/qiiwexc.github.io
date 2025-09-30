function Set-CloudFlareDNS {
    [String]$PreferredDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.1.1.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.1.1.2' } else { '1.1.1.1' } }
    [String]$AlternateDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.0.0.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.0.0.2' } else { '1.0.0.1' } }

    Write-LogInfo "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."
    Write-LogWarning 'Internet connection may get interrupted briefly'

    if (-not (Get-NetworkAdapter)) {
        Write-LogError 'Could not determine network adapter used to connect to the Internet'
        Write-LogError 'This could mean that computer is not connected'
        return
    }

    try {
        Set-Variable -Option Constant Status (Get-NetworkAdapter | Invoke-CimMethod -MethodName 'SetDNSServerSearchOrder' -Arguments @{ DNSServerSearchOrder = @($PreferredDnsServer, $AlternateDnsServer) }).ReturnValue

        if ($Status -ne 0) {
            Write-LogError 'Failed to change DNS server'
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to change DNS server'
        return
    }

    Out-Success
}
