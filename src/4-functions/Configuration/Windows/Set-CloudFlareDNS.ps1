function Set-CloudFlareDNS {
    param(
        [Switch]$MalwareProtection,
        [Switch]$FamilyFriendly
    )

    try {
        if ($FamilyFriendly) {
            Set-Variable -Option Constant PreferredDnsServer ([String]'1.1.1.3')
        } elseif ($MalwareProtection) {
            Set-Variable -Option Constant PreferredDnsServer ([String]'1.1.1.2')
        } else {
            Set-Variable -Option Constant PreferredDnsServer ([String]'1.1.1.1')
        }

        if ($FamilyFriendly) {
            Set-Variable -Option Constant AlternateDnsServer ([String]'1.0.0.3')
        } elseif ($MalwareProtection) {
            Set-Variable -Option Constant AlternateDnsServer ([String]'1.0.0.2')
        } else {
            Set-Variable -Option Constant AlternateDnsServer ([String]'1.0.0.1')
        }

        Write-LogInfo "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."
        Write-LogWarning 'Internet connection may get interrupted briefly'

        Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
        if (-not $IsConnected) {
            return
        }

        Set-Variable -Option Constant Status ([Int[]](Get-NetworkAdapter | Invoke-CimMethod -MethodName 'SetDNSServerSearchOrder' -Arguments @{ DNSServerSearchOrder = @($PreferredDnsServer, $AlternateDnsServer) } -ErrorAction Stop).ReturnValue)

        if ($Status | Where-Object { $_ -ne 0 }) {
            throw "Error code(s) returned: $($Status -join ', ')"
        }

        Out-Success
    } catch {
        Out-Failure "Failed to change DNS server: $_"
    }
}
