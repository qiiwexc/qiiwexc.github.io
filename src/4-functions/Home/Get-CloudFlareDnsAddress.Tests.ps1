BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Get-CloudFlareDnsAddress' {
    It 'Should give the <Name> resolvers for IPv4 and IPv6' -ForEach @(
        @{ Name = 'Default'; Suffix = '1' }
        @{ Name = 'MalwareProtection'; Suffix = '2' }
        @{ Name = 'FamilyFriendly'; Suffix = '3' }
    ) {
        [Hashtable]$Addresses = (Get-CloudFlareDnsAddress)[$Name]

        $Addresses.IPv4 | Should -BeExactly @("1.1.1.$Suffix", "1.0.0.$Suffix")
        $Addresses.IPv6 | Should -BeExactly @("2606:4700:4700::111$Suffix", "2606:4700:4700::100$Suffix")
    }
}
