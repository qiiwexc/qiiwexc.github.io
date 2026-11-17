# Returns every adapter that uses CloudFlare's DNS servers alone, for IPv4 or for IPv6, to the servers the network gives
# it, whichever of CloudFlare's services they are and whoever set them, and leaves every other adapter as it is
function Reset-CloudFlareDNS {
    try {
        Write-LogInfo 'Returning to automatic DNS servers...'
        Write-LogWarning 'Internet connection may get interrupted briefly'

        Set-Variable -Option Constant CloudFlareAddresses ([String[]]@((Get-CloudFlareDnsAddress).Values | ForEach-Object { $_.IPv4 + $_.IPv6 }))

        [Int]$Reset = 0
        foreach ($Adapter in @(Get-NetworkAdapter)) {
            [Object[]]$Families = @(Get-AdapterDnsServer $Adapter.InterfaceIndex)

            [Object[]]$CloudFlareOnly = @($Families | Where-Object {
                    $_.Servers.Count -gt 0 -and -not ($_.Servers | Where-Object { $_ -notin $CloudFlareAddresses })
                })
            if ($CloudFlareOnly.Count -eq 0) {
                continue
            }

            Write-LogInfo "'$($Adapter.Description)': $(@($Families | ForEach-Object { $_.Servers }) -join ', ') -> automatic" 1
            Set-DnsClientServerAddress -InterfaceIndex $Adapter.InterfaceIndex -ResetServerAddresses -ErrorAction Stop
            $Reset++
        }

        if ($Reset -eq 0) {
            Write-LogInfo 'No network adapter uses CloudFlare DNS' 1
        }

        Out-Success
    } catch {
        Out-Failure "Failed to reset DNS servers: $_"
    }
}
