BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
}

Describe 'Test-AntivirusEnabled' {
    It 'Should return true when an antivirus product is enabled' {
        Mock Get-CimInstance { return @( [PSCustomObject]@{ productState = 397568 } ) }

        Test-AntivirusEnabled | Should -BeTrue

        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter {
            $Namespace -eq 'root/SecurityCenter2' -and
            $ClassName -eq 'AntiVirusProduct'
        }
    }

    It 'Should return false when no antivirus product is enabled' {
        Mock Get-CimInstance { return @( [PSCustomObject]@{ productState = 393472 } ) }

        Test-AntivirusEnabled | Should -BeFalse

        Should -Invoke Get-CimInstance -Exactly 1
    }

    It 'Should return true when at least one of multiple products is enabled' {
        Mock Get-CimInstance { return @(
                [PSCustomObject]@{ productState = 393472 },
                [PSCustomObject]@{ productState = 397568 }
            ) }

        Test-AntivirusEnabled | Should -BeTrue

        Should -Invoke Get-CimInstance -Exactly 1
    }

    It 'Should return false when all products are disabled' {
        Mock Get-CimInstance { return @(
                [PSCustomObject]@{ productState = 393472 },
                [PSCustomObject]@{ productState = 262144 }
            ) }

        Test-AntivirusEnabled | Should -BeFalse

        Should -Invoke Get-CimInstance -Exactly 1
    }

    It 'Should return false when no antivirus products are found' {
        Mock Get-CimInstance { return @() }

        Test-AntivirusEnabled | Should -BeFalse

        Should -Invoke Get-CimInstance -Exactly 1
    }

    It 'Should return false when Get-CimInstance fails' {
        Mock Get-CimInstance { throw $TestException }

        Test-AntivirusEnabled | Should -BeFalse

        Should -Invoke Get-CimInstance -Exactly 1
    }
}
