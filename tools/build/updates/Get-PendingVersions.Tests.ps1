BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Get-QuarantineEnd.ps1"

    Set-Variable -Option Constant TestState ([Collections.Specialized.OrderedDictionary]([Ordered]@{
                Ventoy = [PSCustomObject]@{
                    base       = 'v1.1.17'
                    candidates = [Collections.Generic.List[PSObject]]@(
                        [PSCustomObject]@{ version = 'v1.1.18'; firstSeen = [DateTime]::new(2026, 9, 25, 3, 0, 0, [DateTimeKind]::Utc) }
                        [PSCustomObject]@{ version = 'v1.1.19'; firstSeen = [DateTime]::new(2026, 9, 28, 3, 0, 0, [DateTimeKind]::Utc) }
                        [PSCustomObject]@{ version = 'v1.1.20'; firstSeen = [DateTime]::new(2026, 9, 30, 3, 0, 0, [DateTimeKind]::Utc) }
                    )
                }
            }))
}

Describe 'Get-PendingVersions' {
    It 'Should list every candidate, newest first, while nothing has been applied' {
        [PSObject[]]$Result = @(Get-PendingVersions $TestState 'Ventoy' 'v1.1.17')

        $Result.Count | Should -Be 3
        $Result[0].Version | Should -BeExactly 'v1.1.20'
        $Result[0].EligibleOn | Should -Be ([DateTime]::new(2026, 10, 7, 3, 0, 0, [DateTimeKind]::Utc))
        $Result[1].Version | Should -BeExactly 'v1.1.19'
        $Result[2].Version | Should -BeExactly 'v1.1.18'
    }

    It 'Should list the candidates newer than the one applied' {
        [PSObject[]]$Result = @(Get-PendingVersions $TestState 'Ventoy' 'v1.1.18')

        $Result.Count | Should -Be 2
        $Result[0].Version | Should -BeExactly 'v1.1.20'
        $Result[1].Version | Should -BeExactly 'v1.1.19'
    }

    It 'Should list nothing when the newest candidate is applied' {
        @(Get-PendingVersions $TestState 'Ventoy' 'v1.1.20').Count | Should -Be 0
    }

    It 'Should list nothing for a version the state does not describe' {
        @(Get-PendingVersions $TestState 'Ventoy' 'v2.0.0').Count | Should -Be 0
    }

    It 'Should list nothing for a dependency without candidates' {
        @(Get-PendingVersions $TestState 'Rufus' 'v4.15').Count | Should -Be 0
    }
}
