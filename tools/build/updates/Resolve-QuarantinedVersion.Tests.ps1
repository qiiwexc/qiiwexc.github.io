BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Get-QuarantineEnd.ps1"
    . "$PSScriptRoot\..\..\common\logger.ps1"

    Set-Variable -Option Constant TestName ([String]'Ventoy')
    Set-Variable -Option Constant TestNow ([DateTime]::new(2026, 10, 10, 3, 0, 0, [DateTimeKind]::Utc))

    function New-TestCandidate {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Version,
            [Parameter(Position = 1, Mandatory)][Int]$DaysAgo
        )

        return [PSCustomObject]@{ version = $Version; firstSeen = $TestNow.AddDays(-$DaysAgo) }
    }

    function New-TestState {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Base,
            [Parameter(Position = 1)][PSObject[]]$Candidates = @()
        )

        [Collections.Specialized.OrderedDictionary]$State = [Ordered]@{}
        $State[$TestName] = [PSCustomObject]@{ base = $Base; candidates = [Collections.Generic.List[PSObject]]$Candidates }
        return $State
    }

    function Get-TestCandidates {
        param(
            [Parameter(Position = 0, Mandatory)][Collections.Specialized.OrderedDictionary]$State
        )

        return @($State[$TestName].candidates | ForEach-Object { $_.version })
    }
}

Describe 'Resolve-QuarantinedVersion' {
    BeforeAll {
        Mock Write-LogInfo {}
    }

    It 'Should hold a version back the night it is first seen' {
        [Collections.Specialized.OrderedDictionary]$State = [Ordered]@{}

        Resolve-QuarantinedVersion $State $TestName 'v1.1.17' 'v1.1.18' $TestNow | Should -BeExactly 'v1.1.17'

        $State[$TestName].base | Should -BeExactly 'v1.1.17'
        Get-TestCandidates $State | Should -BeExactly @('v1.1.18')
        $State[$TestName].candidates[0].firstSeen | Should -Be $TestNow

        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -eq 'Version v1.1.18 is in quarantine until 2026-10-17 03:00 UTC' }
    }

    It 'Should keep holding it back for less than 7 days' {
        [Collections.Specialized.OrderedDictionary]$State = New-TestState 'v1.1.17' @(New-TestCandidate 'v1.1.18' 6)

        Resolve-QuarantinedVersion $State $TestName 'v1.1.17' 'v1.1.18' $TestNow | Should -BeExactly 'v1.1.17'

        $State[$TestName].candidates[0].firstSeen | Should -Be $TestNow.AddDays(-6)
    }

    It 'Should apply a version 7 days after it was first seen' {
        [Collections.Specialized.OrderedDictionary]$State = New-TestState 'v1.1.17' @(New-TestCandidate 'v1.1.18' 7)

        Resolve-QuarantinedVersion $State $TestName 'v1.1.17' 'v1.1.18' $TestNow | Should -BeExactly 'v1.1.18'

        Get-TestCandidates $State | Should -BeExactly @('v1.1.18')

        Should -Invoke Write-LogInfo -Exactly 0
    }

    It 'Should apply the newest version out of quarantine while a newer one waits' {
        [Collections.Specialized.OrderedDictionary]$State = New-TestState 'v1.1.17' @((New-TestCandidate 'v1.1.18' 9), (New-TestCandidate 'v1.1.19' 8), (New-TestCandidate 'v1.1.20' 2))

        Resolve-QuarantinedVersion $State $TestName 'v1.1.17' 'v1.1.21' $TestNow | Should -BeExactly 'v1.1.19'

        Get-TestCandidates $State | Should -BeExactly @('v1.1.18', 'v1.1.19', 'v1.1.20', 'v1.1.21')

        Should -Invoke Write-LogInfo -Exactly 2
    }

    It 'Should apply nothing and keep the candidates when the check found nothing newer' {
        [Collections.Specialized.OrderedDictionary]$State = New-TestState 'v1.1.17' @(New-TestCandidate 'v1.1.18' 8)

        Resolve-QuarantinedVersion $State $TestName 'v1.1.17' 'v1.1.17' $TestNow | Should -BeExactly 'v1.1.17'

        Get-TestCandidates $State | Should -BeExactly @('v1.1.18')
    }

    It 'Should keep only the newer candidates once one is merged' {
        [Collections.Specialized.OrderedDictionary]$State = New-TestState 'v1.1.17' @((New-TestCandidate 'v1.1.18' 9), (New-TestCandidate 'v1.1.19' 2))

        Resolve-QuarantinedVersion $State $TestName 'v1.1.18' 'v1.1.19' $TestNow | Should -BeExactly 'v1.1.18'

        $State[$TestName].base | Should -BeExactly 'v1.1.18'
        Get-TestCandidates $State | Should -BeExactly @('v1.1.19')
        $State[$TestName].candidates[0].firstSeen | Should -Be $TestNow.AddDays(-2)
    }

    It 'Should start over after a version set by hand' {
        [Collections.Specialized.OrderedDictionary]$State = New-TestState 'v1.1.17' @((New-TestCandidate 'v1.1.18' 9), (New-TestCandidate 'v1.1.20' 8))

        Resolve-QuarantinedVersion $State $TestName 'v1.1.19' 'v1.1.20' $TestNow | Should -BeExactly 'v1.1.19'

        $State[$TestName].base | Should -BeExactly 'v1.1.19'
        Get-TestCandidates $State | Should -BeExactly @('v1.1.20')
        $State[$TestName].candidates[0].firstSeen | Should -Be $TestNow
    }

    It 'Should drop the candidates after a latest version seen before, as withdrawn' {
        [Collections.Specialized.OrderedDictionary]$State = New-TestState 'v1.1.17' @((New-TestCandidate 'v1.1.18' 9), (New-TestCandidate 'v1.1.19' 8))

        Resolve-QuarantinedVersion $State $TestName 'v1.1.17' 'v1.1.18' $TestNow | Should -BeExactly 'v1.1.18'

        Get-TestCandidates $State | Should -BeExactly @('v1.1.18')
    }

    It 'Should keep its changes in the state when the entry holds an array' {
        [Collections.Specialized.OrderedDictionary]$State = [Ordered]@{}
        $State[$TestName] = [PSCustomObject]@{ base = 'v1.1.17'; candidates = @(New-TestCandidate 'v1.1.18' 2) }

        Resolve-QuarantinedVersion $State $TestName 'v1.1.17' 'v1.1.19' $TestNow | Should -BeExactly 'v1.1.17'

        Get-TestCandidates $State | Should -BeExactly @('v1.1.18', 'v1.1.19')
    }
}
