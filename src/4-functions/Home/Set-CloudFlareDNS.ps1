function Set-CloudFlareDNS {
    param(
        [Switch]$MalwareProtection,
        [Switch]$FamilyFriendly
    )

    try {
        if ($FamilyFriendly) {
            Set-Variable -Option Constant DnsProfile ([String]'FamilyFriendly')
        } elseif ($MalwareProtection) {
            Set-Variable -Option Constant DnsProfile ([String]'MalwareProtection')
        } else {
            Set-Variable -Option Constant DnsProfile ([String]'Default')
        }

        Set-Variable -Option Constant Addresses ([Hashtable]((Get-CloudFlareDnsAddress)[$DnsProfile]))

        Write-LogInfo "Changing DNS servers to CloudFlare DNS ($($Addresses.IPv4 -join ' / '))..."
        Write-LogWarning 'Internet connection may get interrupted briefly'

        Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
        if (-not $IsConnected) {
            return
        }

        # The adapters that reach the Internet. One without a default gateway, such as a VPN's, a virtual switch's or a
        # host-only one, keeps the DNS servers it was given: changing them would break the names only they resolve
        Set-Variable -Option Constant Adapters ([Object[]]@(Get-NetworkAdapter | Where-Object { $_.DefaultIPGateway }))
        if ($Adapters.Count -eq 0) {
            throw 'No network adapter has a default gateway'
        }

        foreach ($Adapter in $Adapters) {
            [Object[]]$Families = @(Get-AdapterDnsServer $Adapter.InterfaceIndex)

            # Both address families where the adapter has both: a resolver left as it was in either would answer
            # around the filtering
            [String[]]$Servers = @()
            if ($Families | Where-Object { -not $_.IPv6 }) {
                $Servers += $Addresses.IPv4
            }
            if ($Families | Where-Object { $_.IPv6 }) {
                $Servers += $Addresses.IPv6
            }

            # What it had, to go back to by hand where the servers were set rather than given by the network
            [String]$Previous = @($Families | ForEach-Object { $_.Servers }) -join ', '
            if (-not $Previous) {
                $Previous = 'none'
            }
            Write-LogInfo "'$($Adapter.Description)': $Previous -> $($Servers -join ', ')" 1

            Set-DnsClientServerAddress -InterfaceIndex $Adapter.InterfaceIndex -ServerAddresses $Servers -ErrorAction Stop
        }

        Out-Success
    } catch {
        Out-Failure "Failed to change DNS server: $_"
    }
}
