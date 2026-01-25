BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestClassName ([String]'Win32_NetworkAdapterConfiguration')
    Set-Variable -Option Constant TestNetworkAdapter ([CimInstance]::new($TestClassName))

}

Describe 'Get-NetworkAdapter' {
    BeforeEach {
        Mock Get-CimInstance { return $TestNetworkAdapter }
    }

    It 'Should return network adapter when connected' {
        Get-NetworkAdapter | Should -Be $TestNetworkAdapter

        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter {
            $ClassName -eq $TestClassName -and
            $Filter -eq 'IPEnabled=True'
        }
    }

    It 'Should handle Get-CimInstance failure' {
        Mock Get-CimInstance { throw $TestException }

        { Get-NetworkAdapter } | Should -Throw $TestException

        Should -Invoke Get-CimInstance -Exactly 1
    }
}

Describe 'Test-NetworkConnection' {
    BeforeEach {
        Mock Get-NetworkAdapter { return $TestNetworkAdapter }
        Mock Out-Failure {}
    }

    It 'Should return true when connected to network' {
        Test-NetworkConnection | Should -BeTrue

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should return false when not connected to network' {
        Mock Get-NetworkAdapter { return $Null }

        Test-NetworkConnection | Should -BeFalse

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Get-NetworkAdapter failure' {
        Mock Get-NetworkAdapter { throw $TestException }

        { Test-NetworkConnection } | Should -Throw $TestException

        Should -Invoke Get-NetworkAdapter -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }
}
