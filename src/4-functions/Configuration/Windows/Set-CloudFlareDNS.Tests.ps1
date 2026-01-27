BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestNetworkAdapter ([CimInstance]::new('Win32_NetworkAdapterConfiguration'))

    Set-Variable -Option Constant TestPreferredDnsBase ([String]'1.1.1.1')
    Set-Variable -Option Constant TestPreferredDnsMalwareProtection ([String]'1.1.1.2')
    Set-Variable -Option Constant TestPreferredDnsFamilyFriendly ([String]'1.1.1.3')

    Set-Variable -Option Constant TestAlternateDnsBase ([String]'1.0.0.1')
    Set-Variable -Option Constant TestAlternateDnsMalwareProtection ([String]'1.0.0.2')
    Set-Variable -Option Constant TestAlternateDnsFamilyFriendly ([String]'1.0.0.3')
}

Describe 'Set-CloudFlareDNS' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock Get-NetworkAdapter { return $TestNetworkAdapter }
        Mock Invoke-CimMethod { return @{ ReturnValue = 0 } }
        Mock Out-Success {}
        Mock Out-Failure {}

        [Switch]$TestMalwareProtection = $True
        [Switch]$TestFamilyFriendly = $False
    }

    It 'Should set base CloudFlare DNS' {
        [Switch]$TestMalwareProtection = $False

        Set-CloudFlareDNS $TestMalwareProtection $TestFamilyFriendly

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1 -ParameterFilter {
            $InputObject -eq $TestNetworkAdapter -and
            $MethodName -eq 'SetDNSServerSearchOrder' -and
            $Arguments.DNSServerSearchOrder[0] -eq $TestPreferredDnsBase -and
            $Arguments.DNSServerSearchOrder[1] -eq $TestAlternateDnsBase
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should set Malware Protection CloudFlare DNS' {
        Set-CloudFlareDNS $TestMalwareProtection $TestFamilyFriendly

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1 -ParameterFilter {
            $InputObject -eq $TestNetworkAdapter -and
            $MethodName -eq 'SetDNSServerSearchOrder' -and
            $Arguments.DNSServerSearchOrder[0] -eq $TestPreferredDnsMalwareProtection -and
            $Arguments.DNSServerSearchOrder[1] -eq $TestAlternateDnsMalwareProtection
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should set family friendly CloudFlare DNS' {
        [Switch]$TestFamilyFriendly = $True

        Set-CloudFlareDNS $TestMalwareProtection $TestFamilyFriendly

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1 -ParameterFilter {
            $InputObject -eq $TestNetworkAdapter -and
            $MethodName -eq 'SetDNSServerSearchOrder' -and
            $Arguments.DNSServerSearchOrder[0] -eq $TestPreferredDnsFamilyFriendly -and
            $Arguments.DNSServerSearchOrder[1] -eq $TestAlternateDnsFamilyFriendly
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Set-CloudFlareDNS $TestMalwareProtection $TestFamilyFriendly

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Get-NetworkAdapter -Exactly 0
        Should -Invoke Invoke-CimMethod -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Invoke-CimMethod failure with non-zero return value' {
        Mock Invoke-CimMethod { return @{ ReturnValue = 1 } }

        Set-CloudFlareDNS $TestMalwareProtection $TestFamilyFriendly

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        Set-CloudFlareDNS $TestMalwareProtection $TestFamilyFriendly

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Get-NetworkAdapter -Exactly 0
        Should -Invoke Invoke-CimMethod -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Get-NetworkAdapter failure' {
        Mock Get-NetworkAdapter { throw $TestException }

        Set-CloudFlareDNS $TestMalwareProtection $TestFamilyFriendly

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Invoke-CimMethod failure' {
        Mock Invoke-CimMethod { throw $TestException }

        Set-CloudFlareDNS $TestMalwareProtection $TestFamilyFriendly

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
