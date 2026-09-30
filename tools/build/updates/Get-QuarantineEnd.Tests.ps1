BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestFirstSeen ([DateTime]::new(2026, 9, 30, 3, 4, 5, [DateTimeKind]::Utc))
}

Describe 'Get-QuarantineEnd' {
    It 'Should end the quarantine 7 days after a version is first seen' {
        Set-Variable -Option Constant Result ([DateTime](Get-QuarantineEnd $TestFirstSeen))

        $Result | Should -Be ([DateTime]::new(2026, 10, 7, 3, 4, 5, [DateTimeKind]::Utc))
        $Result.Kind | Should -Be ([DateTimeKind]::Utc)
    }
}
