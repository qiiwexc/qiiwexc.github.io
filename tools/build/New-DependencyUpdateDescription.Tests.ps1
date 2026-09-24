BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\updates\Format-ReleaseNotes.ps1"
    . "$PSScriptRoot\updates\Get-ReleaseNotes.ps1"

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')
    Set-Variable -Option Constant Arrow ([String][Char]0x2192)

    function New-TestUpdate {
        param(
            [Parameter(Position = 0, Mandatory)][Hashtable]$Dependency,
            [Parameter(Position = 1, Mandatory)][String]$From,
            [Switch]$UrlChange,
            [Switch]$ToolChange
        )

        return [PSCustomObject]@{
            Name       = $Dependency.name
            From       = $From
            To         = $Dependency.version
            Dependency = [PSCustomObject]$Dependency
            UrlChange  = $UrlChange.IsPresent
            ToolChange = $ToolChange.IsPresent
        }
    }

    Set-Variable -Option Constant TestRufus (New-TestUpdate @{ name = 'Rufus'; version = 'v4.16'; source = 'GitHub'; repository = 'pbatard/rufus' } 'v4.15' -UrlChange)
    Set-Variable -Option Constant TestPester (New-TestUpdate @{ name = 'Pester'; version = '6.2.0'; source = 'GitHub'; repository = 'pester/Pester' } '6.1.0' -ToolChange)
    Set-Variable -Option Constant TestGenerator (New-TestUpdate @{ name = 'Unattend Generator'; version = '538f930aeea9c3d51fdd0b4822e2d076fef999e8'; source = 'GitHub'; repository = 'cschneegans/unattend-generator' } '781fde52797f736de9b0426bb4a5c6048a1ae075')
    Set-Variable -Option Constant TestRescue (New-TestUpdate @{ name = 'SystemRescue'; version = '13.03'; source = 'GitLab'; repository = 'systemrescue/systemrescue-sources' } '13.02')
    Set-Variable -Option Constant TestShutUp (New-TestUpdate @{ name = 'OOShutUp10'; version = '3.5'; source = 'URL'; url = 'https://www.oo-software.com/en/shutup10/changelog' } '3.4')
    Set-Variable -Option Constant TestOffice (New-TestUpdate @{ name = 'Office Installer'; version = '1.2.9.0'; source = 'File' } '1.2.8.0')

    Set-Variable -Option Constant TestChangelogUrls ([String[]]@(
            'https://github.com/cschneegans/unattend-generator/compare/781fde52797f736de9b0426bb4a5c6048a1ae075...538f930aeea9c3d51fdd0b4822e2d076fef999e8',
            'https://github.com/pbatard/rufus/releases/tag/v4.15.1',
            'https://github.com/pbatard/rufus/releases/tag/v4.16',
            'https://gitlab.com/systemrescue/systemrescue-sources/-/compare/13.02...13.03',
            'https://www.oo-software.com/en/shutup10/changelog'
        ))
}

Describe 'New-DependencyUpdateDescription' {
    BeforeAll {
        Mock Get-ReleaseNotes { return "## Changes for $Tag by @someone" }
    }

    It 'Should open with a table of every version that moved' {
        [String]$Description = New-DependencyUpdateDescription @($TestRufus, $TestPester, $TestGenerator, $TestShutUp, $TestOffice) @()

        [String[]]$Lines = $Description -split "`n"
        $Lines[0] | Should -BeExactly 'Bumps 5 dependencies.'
        $Lines[2..8] | Should -BeExactly @(
            '| Dependency | From | To | Changes |'
            '| --- | --- | --- | --- |'
            '| [Rufus](https://github.com/pbatard/rufus) | `v4.15` | `v4.16` | Download URL |'
            '| [Pester](https://github.com/pester/Pester) | `6.1.0` | `6.2.0` | CI tool |'
            '| [Unattend Generator](https://github.com/cschneegans/unattend-generator) | `781fde5` | `538f930` | Version record only |'
            '| [OOShutUp10](https://www.oo-software.com/en/shutup10/changelog) | `3.4` | `3.5` | Version record only |'
            '| Office Installer | `1.2.8.0` | `1.2.9.0` | Version record only |'
        )
        $Lines.Count | Should -Be 9

        Should -Invoke Get-ReleaseNotes -Exactly 0
    }

    It 'Should say dependency for a single one, and escape a pipe in a version' {
        [PSObject]$Update = New-TestUpdate @{ name = 'Windows'; version = 'a|b'; source = 'URL'; url = 'https://example.com' } 'a'

        [String]$Description = New-DependencyUpdateDescription @($Update)

        $Description | Should -MatchExactly ('^' + [Regex]::Escape('Bumps 1 dependency.'))
        $Description | Should -MatchExactly ([Regex]::Escape('| [Windows](https://example.com) | `a` | `a\|b` | Version record only |') + '$')
    }

    It 'Should group the links by where they point, each dependency on one line in table order' {
        [String]$Description = New-DependencyUpdateDescription @($TestRufus, $TestGenerator, $TestRescue, $TestShutUp) $TestChangelogUrls $TestGitHubToken

        [String]$Links = ($Description -split '## Release notes')[0]
        [String]$Expected = @(
            '## Links'
            ''
            '### Other sites'
            ''
            '- SystemRescue: [`13.02...13.03`](https://gitlab.com/systemrescue/systemrescue-sources/-/compare/13.02...13.03)'
            '- OOShutUp10: <https://www.oo-software.com/en/shutup10/changelog>'
            ''
            '### GitHub commits'
            ''
            '- Unattend Generator: [`781fde5...538f930`](https://github.com/cschneegans/unattend-generator/compare/781fde52797f736de9b0426bb4a5c6048a1ae075...538f930aeea9c3d51fdd0b4822e2d076fef999e8)'
            ''
            '### GitHub releases and tags'
            ''
            '- Rufus: [v4.16](https://github.com/pbatard/rufus/releases/tag/v4.16), [v4.15.1](https://github.com/pbatard/rufus/releases/tag/v4.15.1)'
        ) -join "`n"

        $Links | Should -MatchExactly ([Regex]::Escape($Expected))
    }

    It 'Should list a link no dependency claims without a name' {
        [String]$Description = New-DependencyUpdateDescription @($TestShutUp) @('https://example.com/news')

        $Description | Should -MatchExactly ([Regex]::Escape("### Other sites`n`n- <https://example.com/news>") + '$')
    }

    It 'Should quote the notes of every release, newest first, collapsed per dependency' {
        [String]$Description = New-DependencyUpdateDescription @($TestRufus, $TestGenerator) $TestChangelogUrls $TestGitHubToken

        [String]$Notes = ($Description -split "## Release notes`n")[1]
        $Notes | Should -BeExactly ("`n<details>`n<summary>Rufus v4.15 $Arrow v4.16</summary>`n`n" +
            "### [v4.16](https://github.com/pbatard/rufus/releases/tag/v4.16)`n`n" +
            "##### Changes for v4.16 by [@someone](https://github.com/someone)`n`n" +
            "### [v4.15.1](https://github.com/pbatard/rufus/releases/tag/v4.15.1)`n`n" +
            "##### Changes for v4.15.1 by [@someone](https://github.com/someone)`n`n" +
            '</details>')

        Should -Invoke Get-ReleaseNotes -Exactly 2
        Should -Invoke Get-ReleaseNotes -Exactly 1 -ParameterFilter { $Repository -eq 'pbatard/rufus' -and $Tag -eq 'v4.16' -and $GitHubToken -eq $TestGitHubToken }
    }

    It 'Should say when a version has no notes: <Case>' -ForEach @(
        @{ Case = 'no release'; ReleaseNotes = $Null; Expected = '_No release notes are published for this version._' }
        @{ Case = 'empty release'; ReleaseNotes = " `n"; Expected = '_This version was released without notes._' }
    ) {
        Mock Get-ReleaseNotes { return $ReleaseNotes }

        New-DependencyUpdateDescription @($TestRufus) @('https://github.com/pbatard/rufus/releases/tag/v4.16') |
            Should -MatchExactly ([Regex]::Escape("### [v4.16](https://github.com/pbatard/rufus/releases/tag/v4.16)`n`n$Expected`n`n</details>") + '$')
    }

    It 'Should leave out the notes section when nothing was released' {
        New-DependencyUpdateDescription @($TestGenerator) @($TestChangelogUrls[0]) | Should -Not -MatchExactly 'Release notes'

        Should -Invoke Get-ReleaseNotes -Exactly 0
    }

    It 'Should list the versions whose notes do not fit, and stop fetching them' {
        Mock Get-ReleaseNotes { return 'x' * 35000 }

        [String]$Description = New-DependencyUpdateDescription @($TestRufus, $TestPester) @(
            'https://github.com/pbatard/rufus/releases/tag/v4.16',
            'https://github.com/pbatard/rufus/releases/tag/v4.15.1',
            'https://github.com/pester/Pester/releases/tag/6.2.0'
        )

        $Description.Length | Should -BeLessThan 65536
        [String]$Expected = @(
            '</details>'
            ''
            'The notes for these versions did not fit in the description:'
            ''
            '- Rufus [v4.15.1](https://github.com/pbatard/rufus/releases/tag/v4.15.1)'
            '- Pester [6.2.0](https://github.com/pester/Pester/releases/tag/6.2.0)'
        ) -join "`n"

        $Description | Should -MatchExactly ([Regex]::Escape($Expected) + '$')

        Should -Invoke Get-ReleaseNotes -Exactly 2
    }
}
