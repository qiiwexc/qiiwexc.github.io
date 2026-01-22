BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestRegistryPath ([String]'TEST_REGISTRY_PATH')
}

Describe 'New-RegistryKeyIfMissing' {
    BeforeEach {
        Mock Test-Path { return $False }
        Mock Write-LogDebug {}
        Mock New-Item {}
    }

    It 'Should create missing registry key' {
        New-RegistryKeyIfMissing $TestRegistryPath

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $TestRegistryPath }
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter { $Path -eq $TestRegistryPath }
    }

    It 'Should skip existing registry key' {
        Mock Test-Path { return $True }

        New-RegistryKeyIfMissing $TestRegistryPath

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke New-Item -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        { New-RegistryKeyIfMissing $TestRegistryPath } | Should -Throw $TestException

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke New-Item -Exactly 0
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        { New-RegistryKeyIfMissing $TestRegistryPath } | Should -Throw $TestException

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke New-Item -Exactly 1
    }
}
