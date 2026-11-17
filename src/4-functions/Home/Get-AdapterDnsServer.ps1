# The DNS servers an adapter has, one entry for each address family it has: IPv6 only where it is enabled. Windows lists
# site-local fec0:0:0:ffff::1 to ::3 for IPv6 when no server is set for it, which are left out as none
function Get-AdapterDnsServer {
    param(
        [Parameter(Position = 0, Mandatory)][UInt32]$InterfaceIndex
    )

    foreach ($Family in @(Get-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ErrorAction Stop)) {
        [PSCustomObject]@{
            IPv6    = [Bool]($Family.AddressFamily -eq 23)
            Servers = [String[]]@($Family.ServerAddresses | Where-Object { $_ -and $_ -notlike 'fec0:0:0:ffff::*' })
        }
    }
}
