BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestRepository ([String]'owner/project')
}

Describe 'Format-ReleaseNotes' {
    It 'Should drop HTML comments, including ones spanning several lines' {
        Format-ReleaseNotes "<!--`r`n  Drafting notes`r`n-->`r`nFixed a bug<!-- inline -->." $TestRepository | Should -BeExactly 'Fixed a bug.'
    }

    It 'Should move headings <Offset> levels down, never past level 6' -ForEach @(
        @{ Offset = 3; Notes = "# One`n## Two`n#### Four"; Expected = "#### One`n##### Two`n###### Four" }
        @{ Offset = 1; Notes = "# One`n###"; Expected = "## One`n####" }
    ) {
        Format-ReleaseNotes $Notes $TestRepository $Offset | Should -BeExactly $Expected
    }

    It 'Should turn a mention into a link, which notifies nobody' {
        Format-ReleaseNotes 'Thanks to @some-user (and @other).' $TestRepository |
            Should -BeExactly 'Thanks to [@some-user](https://github.com/some-user) (and [@other](https://github.com/other)).'
    }

    It 'Should leave text that only looks like a mention: <Notes>' -ForEach @(
        @{ Notes = 'Mail user@example.com' }
        @{ Notes = 'Install @scope/package' }
        @{ Notes = 'Splat @{ Key = 1 }' }
    ) {
        Format-ReleaseNotes $Notes $TestRepository | Should -BeExactly $Notes
    }

    It 'Should link a bare issue reference to the upstream repository, through the redirect' {
        Format-ReleaseNotes 'Fixes #123.' $TestRepository |
            Should -BeExactly 'Fixes [#123](https://redirect.github.com/owner/project/issues/123).'
    }

    It 'Should link a qualified issue reference to its own repository' {
        Format-ReleaseNotes 'See other/repo#45' $TestRepository |
            Should -BeExactly 'See [other/repo#45](https://redirect.github.com/other/repo/issues/45)'
    }

    It 'Should leave text that only looks like a reference: <Notes>' -ForEach @(
        @{ Notes = 'An entity &#8239; stays' }
        @{ Notes = 'A fragment https://example.com/page#12 stays' }
        @{ Notes = 'A fragment https://example.com/#34 stays' }
        @{ Notes = 'Word#56 stays' }
    ) {
        Format-ReleaseNotes $Notes $TestRepository | Should -BeExactly $Notes
    }

    It 'Should send links to upstream issues and pull requests through the redirect' {
        Format-ReleaseNotes 'In https://github.com/owner/project/pull/7 and [#8](https://github.com/owner/project/issues/8)' $TestRepository |
            Should -BeExactly 'In https://redirect.github.com/owner/project/pull/7 and [#8](https://redirect.github.com/owner/project/issues/8)'
    }

    It 'Should leave other GitHub links alone' {
        Set-Variable -Option Constant Notes ([String]'Compare https://github.com/owner/project/compare/v1...v2')

        Format-ReleaseNotes $Notes $TestRepository | Should -BeExactly $Notes
    }

    It 'Should leave inline code alone' {
        Set-Variable -Option Constant Notes ([String]'Run `Invoke-Thing @Params #1` or ``code with ` @tick``')

        Format-ReleaseNotes $Notes $TestRepository | Should -BeExactly $Notes
    }

    It 'Should leave the text of an HTML link alone' {
        Format-ReleaseNotes '<a href="https://github.com/owner/project/pull/9">@user #9</a>' $TestRepository |
            Should -BeExactly '<a href="https://redirect.github.com/owner/project/pull/9">@user #9</a>'
    }

    It 'Should leave fenced code blocks alone' {
        Set-Variable -Option Constant Fenced ([String[]]@('```powershell', '# comment @user #1', '```', '~~~', '## Not a heading', '~~~'))

        Format-ReleaseNotes ((@('# Title') + $Fenced + 'By @user') -join "`n") $TestRepository |
            Should -BeExactly ((@('#### Title') + $Fenced + 'By [@user](https://github.com/user)') -join "`n")
    }

    It 'Should trim the blank lines around the notes' {
        Format-ReleaseNotes "`r`n`r`n  Notes`n`n" $TestRepository | Should -BeExactly 'Notes'
    }

    It 'Should return an empty string for empty notes' {
        Format-ReleaseNotes '' $TestRepository | Should -BeExactly ''
    }
}
