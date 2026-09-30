BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\common\logger.ps1"
    . "$PSScriptRoot\..\..\common\Read-JsonFile.ps1"
    . "$PSScriptRoot\..\..\common\Read-TextFile.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestPath ([String]'TEST_QUARANTINE_FILE')
    Set-Variable -Option Constant TestNow ([DateTime]::new(2026, 10, 1, 3, 0, 0, [DateTimeKind]::Utc))
    Set-Variable -Option Constant TestFirstSeen ([DateTime]::new(2026, 9, 25, 3, 4, 5, [DateTimeKind]::Utc))

    # Built by hand rather than with ConvertFrom-Json, which turns the times into dates only in PowerShell 7
    function New-TestCandidate {
        param(
            [Parameter(Position = 0, Mandatory)][Object]$Version,
            [Parameter(Position = 1, Mandatory)][Object]$FirstSeen
        )

        return [PSCustomObject]@{ version = $Version; firstSeen = $FirstSeen }
    }
}

Describe 'Read-QuarantineState' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Test-Path { return $True }
        Mock Read-JsonFile {
            return [PSCustomObject]@{
                Ventoy = [PSCustomObject]@{
                    base       = 'v1.1.17'
                    candidates = @(
                        (New-TestCandidate 'v1.1.18' '2026-09-25T03:04:05Z'),
                        (New-TestCandidate 'v1.1.19' '2026-09-29T03:04:05Z')
                    )
                }
            }
        }
    }

    It 'Should read each dependency with its candidates, oldest first' {
        $Result = Read-QuarantineState $TestPath $TestNow

        $Result | Should -BeOfType [Collections.Specialized.OrderedDictionary]
        $Result.Count | Should -Be 1
        $Result['Ventoy'].base | Should -BeExactly 'v1.1.17'
        $Result['Ventoy'].candidates.Count | Should -Be 2
        $Result['Ventoy'].candidates[0].version | Should -BeExactly 'v1.1.18'
        $Result['Ventoy'].candidates[0].firstSeen | Should -Be $TestFirstSeen
        $Result['Ventoy'].candidates[0].firstSeen.Kind | Should -Be ([DateTimeKind]::Utc)
        $Result['Ventoy'].candidates[1].version | Should -BeExactly 'v1.1.19'

        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $TestPath }
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq $TestPath }
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should accept a time PowerShell 7 already read as a date: <Case>' -ForEach @(
        @{ Case = 'UTC'; FirstSeen = [DateTime]::new(2026, 9, 25, 3, 4, 5, [DateTimeKind]::Utc) }
        @{ Case = 'unspecified, taken as UTC'; FirstSeen = [DateTime]::new(2026, 9, 25, 3, 4, 5, [DateTimeKind]::Unspecified) }
        @{ Case = 'local'; FirstSeen = [DateTime]::new(2026, 9, 25, 3, 4, 5, [DateTimeKind]::Utc).ToLocalTime() }
    ) {
        Mock Read-JsonFile { return [PSCustomObject]@{ Ventoy = [PSCustomObject]@{ base = 'v1.1.17'; candidates = @(New-TestCandidate 'v1.1.18' $FirstSeen) } } }

        $Result = Read-QuarantineState $TestPath $TestNow

        $Result['Ventoy'].candidates[0].firstSeen | Should -Be $TestFirstSeen
        $Result['Ventoy'].candidates[0].firstSeen.Kind | Should -Be ([DateTimeKind]::Utc)
    }

    It 'Should not let a time in the future shorten the wait' {
        Mock Read-JsonFile { return [PSCustomObject]@{ Ventoy = [PSCustomObject]@{ base = 'v1.1.17'; candidates = @(New-TestCandidate 'v1.1.18' '2027-01-01T00:00:00Z') } } }

        $Result = Read-QuarantineState $TestPath $TestNow

        $Result['Ventoy'].candidates[0].firstSeen | Should -Be $TestNow
    }

    It 'Should ignore a malformed candidate: <Case>' -ForEach @(
        @{ Case = 'not an object'; Candidate = 'v1.1.18' }
        @{ Case = 'no version'; Candidate = [PSCustomObject]@{ firstSeen = '2026-09-25T03:04:05Z' } }
        @{ Case = 'no time'; Candidate = [PSCustomObject]@{ version = 'v1.1.18' } }
        @{ Case = 'a version that is not a string'; Candidate = [PSCustomObject]@{ version = 118; firstSeen = '2026-09-25T03:04:05Z' } }
        @{ Case = 'an empty version'; Candidate = [PSCustomObject]@{ version = ''; firstSeen = '2026-09-25T03:04:05Z' } }
        @{ Case = 'markup in the version'; Candidate = [PSCustomObject]@{ version = 'v1<script>'; firstSeen = '2026-09-25T03:04:05Z' } }
        @{ Case = 'a placeholder in the version'; Candidate = [PSCustomObject]@{ version = '{URL_OTHER}'; firstSeen = '2026-09-25T03:04:05Z' } }
        @{ Case = 'a line break in the version'; Candidate = [PSCustomObject]@{ version = "v1`nv2"; firstSeen = '2026-09-25T03:04:05Z' } }
        @{ Case = 'an overlong version'; Candidate = [PSCustomObject]@{ version = 'v' * 101; firstSeen = '2026-09-25T03:04:05Z' } }
        @{ Case = 'a time that is not a time'; Candidate = [PSCustomObject]@{ version = 'v1.1.18'; firstSeen = 'yesterday' } }
    ) {
        Mock Read-JsonFile {
            return [PSCustomObject]@{
                Ventoy = [PSCustomObject]@{
                    base       = 'v1.1.17'
                    candidates = @($Candidate, (New-TestCandidate 'v1.1.19' '2026-09-29T03:04:05Z'))
                }
            }
        }

        $Result = Read-QuarantineState $TestPath $TestNow

        $Result['Ventoy'].candidates.Count | Should -Be 1
        $Result['Ventoy'].candidates[0].version | Should -BeExactly 'v1.1.19'

        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should ignore a malformed dependency: <Case>' -ForEach @(
        @{ Case = 'not an object'; Entry = 'v1.1.17' }
        @{ Case = 'no base'; Entry = [PSCustomObject]@{ candidates = @() } }
        @{ Case = 'no candidates'; Entry = [PSCustomObject]@{ base = 'v1.1.17' } }
        @{ Case = 'an unsafe base'; Entry = [PSCustomObject]@{ base = '$(evil)'; candidates = @() } }
    ) {
        Mock Read-JsonFile { return [PSCustomObject]@{ Rufus = $Entry; Ventoy = [PSCustomObject]@{ base = 'v1.1.17'; candidates = @(New-TestCandidate 'v1.1.18' '2026-09-25T03:04:05Z') } } }

        $Result = Read-QuarantineState $TestPath $TestNow

        $Result.Keys | Should -BeExactly @('Ventoy')

        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should leave out a dependency left without candidates' {
        Mock Read-JsonFile { return [PSCustomObject]@{ Ventoy = [PSCustomObject]@{ base = 'v1.1.17'; candidates = @() } } }

        $Result = Read-QuarantineState $TestPath $TestNow

        $Result.Count | Should -Be 0

        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should start empty when there is no state yet' {
        Mock Test-Path { return $False }

        $Result = Read-QuarantineState $TestPath $TestNow

        $Result | Should -BeOfType [Collections.Specialized.OrderedDictionary]
        $Result.Count | Should -Be 0

        Should -Invoke Read-JsonFile -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should start empty when the state cannot be read' {
        Mock Read-JsonFile { throw $TestException }

        $Result = Read-QuarantineState $TestPath $TestNow

        $Result.Count | Should -Be 0

        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should start empty when the state is not an object: <Case>' -ForEach @(
        @{ Case = 'an array'; Content = @(1, 2) }
        @{ Case = 'a string'; Content = 'TEST_STRING' }
        @{ Case = 'nothing'; Content = $Null }
    ) {
        Mock Read-JsonFile { return $Content }

        $Result = Read-QuarantineState $TestPath $TestNow

        $Result.Count | Should -Be 0

        Should -Invoke Write-LogWarning -Exactly 1
    }
}
