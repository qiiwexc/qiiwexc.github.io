BeforeAll {
    # Untyped stubs so Pester can mock Windows-only commands on any host
    function Get-DnsClientServerAddress { [CmdletBinding()] param([UInt32[]]$InterfaceIndex) }
    function Set-DnsClientServerAddress { [CmdletBinding()] param([UInt32[]]$InterfaceIndex, [String[]]$ServerAddresses, [Switch]$ResetServerAddresses) }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\Common\Network.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\Get-AdapterDnsServer.ps1"
    . "$PSScriptRoot\Get-CloudFlareDnsAddress.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestAdapter ([PSCustomObject]@{ InterfaceIndex = 12; Description = 'TEST_WIFI' })

    # What Get-DnsClientServerAddress gives for an adapter with these IPv4 and IPv6 servers
    function Set-TestServers {
        param(
            [Parameter(Position = 0)][String[]]$IPv4 = @(),
            [Parameter(Position = 1)][String[]]$IPv6 = @()
        )

        $script:Families = @(
            [PSCustomObject]@{ AddressFamily = 2; ServerAddresses = $IPv4 },
            [PSCustomObject]@{ AddressFamily = 23; ServerAddresses = $IPv6 }
        )
    }
}

Describe 'Reset-CloudFlareDNS' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Get-NetworkAdapter { return @($TestAdapter) }
        Mock Get-DnsClientServerAddress { return $script:Families }
        Mock Set-DnsClientServerAddress {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    # Windows lists these for IPv6 when it has no server for it
    It 'Should return an adapter that uses <Name> to automatic DNS' -ForEach @(
        @{ Name = "CloudFlare's for IPv4 and IPv6"; IPv4 = @('1.1.1.2', '1.0.0.2'); IPv6 = @('2606:4700:4700::1112', '2606:4700:4700::1002') }
        @{ Name = "CloudFlare's for IPv4 alone, as an earlier version set"; IPv4 = @('1.1.1.3', '1.0.0.3'); IPv6 = @('fec0:0:0:ffff::1', 'fec0:0:0:ffff::2', 'fec0:0:0:ffff::3') }
        @{ Name = "CloudFlare's for IPv4, and the router's for IPv6"; IPv4 = @('1.1.1.1', '1.0.0.1'); IPv6 = @('fd00::1') }
    ) {
        Set-TestServers $IPv4 $IPv6

        Reset-CloudFlareDNS

        Should -Invoke Set-DnsClientServerAddress -Exactly 1
        Should -Invoke Set-DnsClientServerAddress -Exactly 1 -ParameterFilter {
            $InterfaceIndex -eq $TestAdapter.InterfaceIndex -and
            $ResetServerAddresses -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should leave an adapter that uses <Name> as it is' -ForEach @(
        @{ Name = 'other servers'; IPv4 = @('192.168.1.1'); IPv6 = @('fec0:0:0:ffff::1', 'fec0:0:0:ffff::2', 'fec0:0:0:ffff::3') }
        @{ Name = 'CloudFlare and other servers together'; IPv4 = @('1.1.1.1', '8.8.8.8'); IPv6 = @() }
        @{ Name = 'no servers'; IPv4 = @(); IPv6 = @('fec0:0:0:ffff::1', 'fec0:0:0:ffff::2', 'fec0:0:0:ffff::3') }
    ) {
        Set-TestServers $IPv4 $IPv6

        Reset-CloudFlareDNS

        Should -Invoke Set-DnsClientServerAddress -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -eq 'No network adapter uses CloudFlare DNS' }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle <Command> failure' -ForEach @(
        @{ Command = 'Get-NetworkAdapter' }
        @{ Command = 'Get-DnsClientServerAddress' }
        @{ Command = 'Set-DnsClientServerAddress' }
    ) {
        Set-TestServers @('1.1.1.1', '1.0.0.1')
        Mock $Command { throw $TestException }

        Reset-CloudFlareDNS

        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match $TestException }
    }
}
