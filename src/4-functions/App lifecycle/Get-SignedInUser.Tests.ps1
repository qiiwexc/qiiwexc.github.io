BeforeAll {
    # Untyped stubs so Pester can mock Windows-only commands on any host —
    # mocks and ParameterFilters bind against these simple parameters on every platform
    function Get-CimInstance { [CmdletBinding()] param([String]$ClassName, [String]$Filter) }
    function Invoke-CimMethod { [CmdletBinding()] param([Object]$InputObject, [String]$MethodName) }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestSessionId ([Int][Diagnostics.Process]::GetCurrentProcess().SessionId)
    Set-Variable -Option Constant TestShell ([PSCustomObject]@{ ProcessId = 1234 })
}

Describe 'Get-SignedInUser' {
    BeforeAll {
        Mock Get-CimInstance { return @($TestShell, [PSCustomObject]@{ ProcessId = 5678 }) }
        Mock Invoke-CimMethod { return [PSCustomObject]@{ ReturnValue = 0; Domain = 'TEST_DOMAIN'; User = 'TEST_USER' } }
        Mock Write-LogDebug {}
    }

    It 'Should return the owner of the shell in this session' {
        Get-SignedInUser | Should -BeExactly 'TEST_DOMAIN\TEST_USER'

        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter {
            $ClassName -eq 'Win32_Process' -and
            $Filter -eq "Name='explorer.exe' AND SessionId=$TestSessionId"
        }
        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Invoke-CimMethod -Exactly 1 -ParameterFilter {
            $InputObject -eq $TestShell -and
            $MethodName -eq 'GetOwner'
        }
        Should -Invoke Write-LogDebug -Exactly 0
    }

    It 'Should return nothing when no shell runs in this session' {
        Mock Get-CimInstance {}

        Get-SignedInUser | Should -BeExactly ''

        Should -Invoke Invoke-CimMethod -Exactly 0
        Should -Invoke Write-LogDebug -Exactly 0
    }

    It 'Should return nothing when the owner cannot be read' {
        Mock Invoke-CimMethod { return [PSCustomObject]@{ ReturnValue = 2; Domain = $Null; User = $Null } }

        Get-SignedInUser | Should -BeExactly ''

        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 0
    }

    It 'Should handle Get-CimInstance failure' {
        Mock Get-CimInstance { throw $TestException }

        Get-SignedInUser | Should -BeExactly ''

        Should -Invoke Invoke-CimMethod -Exactly 0
        Should -Invoke Write-LogDebug -Exactly 1
    }

    It 'Should handle Invoke-CimMethod failure' {
        Mock Invoke-CimMethod { throw $TestException }

        Get-SignedInUser | Should -BeExactly ''

        Should -Invoke Invoke-CimMethod -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1
    }
}
