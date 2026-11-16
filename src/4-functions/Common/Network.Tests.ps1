BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
    Set-Variable -Option Constant TestTimeoutException ([Microsoft.Management.Infrastructure.CimException]::new('The operation timed out'))
    Set-Variable -Option Constant TestGenericException ([Microsoft.Management.Infrastructure.CimException]::new('Generic exception'))

    Set-Variable -Option Constant TestClassName ([String]'Win32_NetworkAdapterConfiguration')
    Set-Variable -Option Constant TestNetworkAdapter ([CimInstance]::new($TestClassName))
}

Describe 'Get-NetworkAdapter' {
    BeforeAll {
        Mock Get-CimInstance { return $TestNetworkAdapter }
    }

    It 'Should return network adapter when connected' {
        Get-NetworkAdapter | Should -BeExactly $TestNetworkAdapter

        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter {
            $ClassName -eq $TestClassName -and
            $Filter -eq 'IPEnabled=True' -and
            $OperationTimeoutSec -eq 15
        }
    }

    It 'Should handle Get-CimInstance failure' {
        Mock Get-CimInstance { throw $TestException }

        { Get-NetworkAdapter } | Should -Throw $TestException

        Should -Invoke Get-CimInstance -Exactly 1
    }
}

Describe 'Test-NetworkConnection' {
    BeforeAll {
        Set-Variable -Option Constant MicrosoftProbe ([String]'http://www.msftconnecttest.com/connecttest.txt')
        Set-Variable -Option Constant CloudflareProbe ([String]'http://cp.cloudflare.com/generate_204')

        # What each probe answers when the Internet is reachable: Microsoft's with its text, Cloudflare's with no
        # content at all, which Invoke-WebRequest gives as an empty byte array
        Set-Variable -Option Constant MicrosoftAnswer ([PSCustomObject]@{ StatusCode = 200; Content = 'Microsoft Connect Test' })
        Set-Variable -Option Constant CloudflareAnswer ([PSCustomObject]@{ StatusCode = 204; Content = [Byte[]]@() })
        Set-Variable -Option Constant SignInPage ([PSCustomObject]@{ StatusCode = 200; Content = '<html>Sign in to continue</html>' })

        Mock Get-NetworkAdapter { return $TestNetworkAdapter }
        Mock Invoke-WebRequest { return $MicrosoftAnswer } -ParameterFilter { $Uri -eq $MicrosoftProbe }
        Mock Invoke-WebRequest { return $CloudflareAnswer } -ParameterFilter { $Uri -eq $CloudflareProbe }
        Mock Write-LogDebug {}
        Mock Out-Failure {}
    }

    It 'Should return true when connected to the Internet' {
        Test-NetworkConnection | Should -BeTrue

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq $MicrosoftProbe -and
            $UseBasicParsing -eq $True -and
            $TimeoutSec -eq 10
        }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should return false when not connected to network' {
        Mock Get-NetworkAdapter { return $Null }

        Test-NetworkConnection | Should -BeFalse

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should return true when only the second probe answers, as behind a blocklist with the first on it' {
        Mock Invoke-WebRequest { throw 'Blocked' } -ParameterFilter { $Uri -eq $MicrosoftProbe }

        Test-NetworkConnection | Should -BeTrue

        Should -Invoke Invoke-WebRequest -Exactly 2
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq $CloudflareProbe -and
            $UseBasicParsing -eq $True -and
            $TimeoutSec -eq 10
        }
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should return true when a blocklist answers the first probe with a page of its own' {
        Mock Invoke-WebRequest { return $SignInPage } -ParameterFilter { $Uri -eq $MicrosoftProbe }

        Test-NetworkConnection | Should -BeTrue

        Should -Invoke Invoke-WebRequest -Exactly 2
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should return false when no Internet connectivity' {
        Mock Invoke-WebRequest { throw 'No response' } -ParameterFilter { $Uri -eq $MicrosoftProbe }
        Mock Invoke-WebRequest { throw 'No response' } -ParameterFilter { $Uri -eq $CloudflareProbe }

        Test-NetworkConnection | Should -BeFalse

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 2
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -eq 'No Internet connectivity' }
    }

    It 'Should return false when the connectivity probes are intercepted' {
        Mock Invoke-WebRequest { return $SignInPage } -ParameterFilter { $Uri -eq $MicrosoftProbe }
        Mock Invoke-WebRequest { return $SignInPage } -ParameterFilter { $Uri -eq $CloudflareProbe }

        Test-NetworkConnection | Should -BeFalse

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 2
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match 'sign-in page' }
    }

    It 'Should report an interception when one probe is intercepted and the other gets no answer' {
        Mock Invoke-WebRequest { return $SignInPage } -ParameterFilter { $Uri -eq $MicrosoftProbe }
        Mock Invoke-WebRequest { throw 'No response' } -ParameterFilter { $Uri -eq $CloudflareProbe }

        Test-NetworkConnection | Should -BeFalse

        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match 'sign-in page' }
    }

    It 'Should return false and report error on timeout exception' {
        Mock Get-NetworkAdapter { throw $TestTimeoutException }

        Test-NetworkConnection | Should -BeFalse

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should return false and report error on generic exception' {
        Mock Get-NetworkAdapter { throw $TestGenericException }

        Test-NetworkConnection | Should -BeFalse

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Get-NetworkAdapter failure' {
        Mock Get-NetworkAdapter { throw $TestException }

        Test-NetworkConnection | Should -BeFalse

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
