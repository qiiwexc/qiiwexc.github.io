BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    # As Get-Item names the hives: with the full path
    Set-Variable -Option Constant TestUserRegistryKeys ([Hashtable[]]@(
            @{Name = 'HKEY_USERS\.DEFAULT' },
            @{Name = 'HKEY_USERS\S-1-5-18' },
            @{Name = 'HKEY_USERS\S-1-5-21-1000' },
            @{Name = 'HKEY_USERS\S-1-5-21-1000_Classes' },
            @{Name = 'HKEY_USERS\S-1-5-21-1100' },
            @{Name = 'HKEY_USERS\S-1-5-21-1100_Classes' },
            @{Name = 'HKEY_USERS\S-1-5-22-1000' },
            @{Name = 'HKEY_USERS\S-1-12-1-2000' },
            @{Name = 'HKEY_USERS\S-1-12-1-2000_Classes' }
        )
    )
}

Describe 'Get-UsersRegistryKeys' {
    BeforeAll {
        Mock Get-Item { return $TestUserRegistryKeys }
        Mock Write-LogWarning {}
    }

    It 'Should get the hives of local, domain and Microsoft Entra ID accounts' {
        Get-UsersRegistryKeys | Should -BeExactly @('S-1-5-21-1000', 'S-1-5-21-1100', 'S-1-12-1-2000')

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
