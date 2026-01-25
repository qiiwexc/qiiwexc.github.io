BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestUserRegistryKeys ([Hashtable[]]@(
            @{Name = 'S-1-5-21-1000' },
            @{Name = 'S-1-5-21-1000_Classes' },
            @{Name = 'S-1-5-21-1100' },
            @{Name = 'S-1-5-21-1100_Classes' },
            @{Name = 'S-1-5-22-1000' }
        )
    )
}

Describe 'Get-UsersRegistryKeys' {
    BeforeEach {
        Mock Get-Item { return $TestUserRegistryKeys }
        Mock Write-LogWarning {}
    }

    It 'Should get users registry keys' {
        Get-UsersRegistryKeys | Should -BeExactly @('S-1-5-21-1000', 'S-1-5-21-1100')

        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $Path -eq 'Registry::HKEY_USERS\*' }
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle Get-Item failure' {
        Mock Get-Item { throw $TestException }

        Get-UsersRegistryKeys | Should -BeExactly @()

        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
    }
}
