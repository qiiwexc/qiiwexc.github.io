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

    Set-Variable -Option Constant TestInternetAdapter ([PSCustomObject]@{ InterfaceIndex = 12; Description = 'TEST_WIFI'; DefaultIPGateway = @('192.168.1.1') })
    Set-Variable -Option Constant TestVpnAdapter ([PSCustomObject]@{ InterfaceIndex = 34; Description = 'TEST_VPN'; DefaultIPGateway = $Null })

    Set-Variable -Option Constant TestIPv4 ([PSCustomObject]@{ AddressFamily = 2; ServerAddresses = @('192.168.1.1') })
    Set-Variable -Option Constant TestIPv6 ([PSCustomObject]@{ AddressFamily = 23; ServerAddresses = @('fec0:0:0:ffff::1', 'fec0:0:0:ffff::2', 'fec0:0:0:ffff::3') })
}

Describe 'Set-CloudFlareDNS' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock Get-NetworkAdapter { return @($TestInternetAdapter, $TestVpnAdapter) }
        Mock Get-DnsClientServerAddress { return @($TestIPv4, $TestIPv6) }
        Mock Set-DnsClientServerAddress {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should set <Name> for IPv4 and IPv6' -ForEach @(
        @{ Name = 'CloudFlare DNS'; Switches = @{}; Expected = @('1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001') }
        @{ Name = 'malware protection'; Switches = @{ MalwareProtection = $True }; Expected = @('1.1.1.2', '1.0.0.2', '2606:4700:4700::1112', '2606:4700:4700::1002') }
        @{ Name = 'adult content filtering'; Switches = @{ MalwareProtection = $True; FamilyFriendly = $True }; Expected = @('1.1.1.3', '1.0.0.3', '2606:4700:4700::1113', '2606:4700:4700::1003') }
    ) {
        Set-CloudFlareDNS @Switches

        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Set-DnsClientServerAddress -Exactly 1
        Should -Invoke Set-DnsClientServerAddress -Exactly 1 -ParameterFilter {
            $InterfaceIndex -eq $TestInternetAdapter.InterfaceIndex -and
            ($ServerAddresses -join ',') -eq ($Expected -join ',')
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should leave an adapter without a default gateway, such as a VPN, as it is' {
        Set-CloudFlareDNS

        Should -Invoke Get-DnsClientServerAddress -Exactly 0 -ParameterFilter { $InterfaceIndex -eq $TestVpnAdapter.InterfaceIndex }
        Should -Invoke Set-DnsClientServerAddress -Exactly 0 -ParameterFilter { $InterfaceIndex -eq $TestVpnAdapter.InterfaceIndex }
    }

    It 'Should set IPv4 alone on an adapter without IPv6' {
        Mock Get-DnsClientServerAddress { return @($TestIPv4) }

        Set-CloudFlareDNS

        Should -Invoke Set-DnsClientServerAddress -Exactly 1 -ParameterFilter { ($ServerAddresses -join ',') -eq '1.1.1.1,1.0.0.1' }
    }

    It 'Should log the servers each adapter had, without the placeholders of an IPv6 that has none' {
        Set-CloudFlareDNS

        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -eq "'TEST_WIFI': 192.168.1.1 -> 1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001" }
    }

    It 'Should fail when no adapter has a default gateway' {
        Mock Get-NetworkAdapter { return @($TestVpnAdapter) }

        Set-CloudFlareDNS

        Should -Invoke Set-DnsClientServerAddress -Exactly 0
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match 'default gateway' }
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Set-CloudFlareDNS

        Should -Invoke Get-NetworkAdapter -Exactly 0
        Should -Invoke Set-DnsClientServerAddress -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle <Command> failure' -ForEach @(
        @{ Command = 'Test-NetworkConnection' }
        @{ Command = 'Get-NetworkAdapter' }
        @{ Command = 'Get-DnsClientServerAddress' }
        @{ Command = 'Set-DnsClientServerAddress' }
    ) {
        Mock $Command { throw $TestException }

        Set-CloudFlareDNS

        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match $TestException }
    }
}
