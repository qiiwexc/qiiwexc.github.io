BeforeAll {
    # Untyped stub so Pester can mock a Windows-only command on any host
    function Get-DnsClientServerAddress { [CmdletBinding()] param([UInt32[]]$InterfaceIndex) }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
    Set-Variable -Option Constant TestInterfaceIndex ([UInt32]12)
}

Describe 'Get-AdapterDnsServer' {
    BeforeAll {
        Mock Get-DnsClientServerAddress {
            return @(
                [PSCustomObject]@{ AddressFamily = 2; ServerAddresses = @('1.1.1.1', '1.0.0.1') },
                [PSCustomObject]@{ AddressFamily = 23; ServerAddresses = @('fec0:0:0:ffff::1', 'fec0:0:0:ffff::2', 'fec0:0:0:ffff::3') }
            )
        }
    }

    It "Should list each address family's servers, without the placeholders of one that has none" {
        [Object[]]$Families = @(Get-AdapterDnsServer $TestInterfaceIndex)

        $Families.Count | Should -BeExactly 2
        $Families[0].IPv6 | Should -BeFalse
        $Families[0].Servers | Should -BeExactly @('1.1.1.1', '1.0.0.1')
        $Families[1].IPv6 | Should -BeTrue
        $Families[1].Servers.Count | Should -BeExactly 0
        Should -Invoke Get-DnsClientServerAddress -Exactly 1 -ParameterFilter { $InterfaceIndex -eq $TestInterfaceIndex }
    }

    It 'Should keep the IPv6 servers that are set' {
        Mock Get-DnsClientServerAddress { return @([PSCustomObject]@{ AddressFamily = 23; ServerAddresses = @('2606:4700:4700::1111') }) }

        [Object[]]$Families = @(Get-AdapterDnsServer $TestInterfaceIndex)

        $Families.Count | Should -BeExactly 1
        $Families[0].Servers | Should -BeExactly @('2606:4700:4700::1111')
    }

    It 'Should handle Get-DnsClientServerAddress failure' {
        Mock Get-DnsClientServerAddress { throw $TestException }

        { Get-AdapterDnsServer $TestInterfaceIndex } | Should -Throw $TestException
    }
}
