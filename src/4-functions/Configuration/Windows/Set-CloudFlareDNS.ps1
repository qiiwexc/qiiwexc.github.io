function Set-CloudFlareDNS {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$MalwareProtection,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$FamilyFriendly
    )

    Set-Variable -Option Constant PreferredDnsServer $(if ($FamilyFriendly) { '1.1.1.3' } else { if ($MalwareProtection) { '1.1.1.2' } else { '1.1.1.1' } })
    Set-Variable -Option Constant AlternateDnsServer $(if ($FamilyFriendly) { '1.0.0.3' } else { if ($MalwareProtection) { '1.0.0.2' } else { '1.0.0.1' } })

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
        Write-LogException $_ 'Failed to change DNS server'
        return
    }

    Out-Success
}
