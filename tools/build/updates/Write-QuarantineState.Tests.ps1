BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Read-QuarantineState.ps1"
    . "$PSScriptRoot\..\..\common\logger.ps1"
    . "$PSScriptRoot\..\..\common\Read-JsonFile.ps1"
    . "$PSScriptRoot\..\..\common\Read-TextFile.ps1"
    . "$PSScriptRoot\..\..\common\Write-JsonFile.ps1"
    . "$PSScriptRoot\..\..\common\Write-TextFile.ps1"

    Set-Variable -Option Constant TestPath ([String]'TEST_QUARANTINE_FILE')
    Set-Variable -Option Constant TestNow ([DateTime]::new(2026, 10, 1, 3, 0, 0, [DateTimeKind]::Utc))

    function New-TestState {
        [Collections.Specialized.OrderedDictionary]$State = [Ordered]@{}
        $State['Ventoy'] = [PSCustomObject]@{
            base       = 'v1.1.17'
            candidates = [Collections.Generic.List[PSObject]]@(
                [PSCustomObject]@{ version = 'v1.1.18'; firstSeen = [DateTime]::new(2026, 9, 25, 3, 4, 5, [DateTimeKind]::Utc) }
            )
        }
        $State['Rufus'] = [PSCustomObject]@{ base = 'v4.15'; candidates = [Collections.Generic.List[PSObject]]@() }
        return $State
    }
}

Describe 'Write-QuarantineState' {
    BeforeAll {
        Mock Write-JsonFile {}
    }

    It 'Should write the candidates with their times as UTC strings, and leave out dependencies without any' {
        Write-QuarantineState $TestPath (New-TestState)

        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            ($Content | ConvertTo-Json -Depth 10 -Compress) -eq '{"Ventoy":{"base":"v1.1.17","candidates":[{"version":"v1.1.18","firstSeen":"2026-09-25T03:04:05Z"}]}}'
        }
    }

    It 'Should write an empty object when nothing is waiting' {
        Write-QuarantineState $TestPath ([Ordered]@{})

        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter { @($Content.PSObject.Properties).Count -eq 0 }
    }
}

Describe 'Write-QuarantineState round trip' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
    }

    It 'Should write a state that reads back the same' {
        Set-Variable -Option Constant Path ([String]"$TestDrive\dependency-quarantine.json")

        Write-QuarantineState $Path (New-TestState)
        $Result = Read-QuarantineState $Path $TestNow

        $Result.Keys | Should -BeExactly @('Ventoy')
        $Result['Ventoy'].base | Should -BeExactly 'v1.1.17'
        $Result['Ventoy'].candidates.Count | Should -Be 1
        $Result['Ventoy'].candidates[0].version | Should -BeExactly 'v1.1.18'
        $Result['Ventoy'].candidates[0].firstSeen | Should -Be ([DateTime]::new(2026, 9, 25, 3, 4, 5, [DateTimeKind]::Utc))

        Should -Invoke Write-LogWarning -Exactly 0
    }
}
