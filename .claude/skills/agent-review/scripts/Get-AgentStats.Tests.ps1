BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    # A file with exactly this text: no byte order mark, no line break added
    function New-TestFile {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Path,
            [Parameter(Position = 1)][String]$Text = ''
        )

        $Null = New-Item -ItemType Directory -Force (Split-Path -Parent $Path)
        [IO.File]::WriteAllText($Path, $Text)
    }

    # A transcript: one JSON line per entry, a string written as it is
    function New-TestTranscript {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Path,
            [Parameter(Position = 1, Mandatory)][Object[]]$Entries
        )

        [String[]]$Lines = @($Entries | ForEach-Object { if ($_ -is [String]) { $_ } else { ConvertTo-Json $_ -Compress -Depth 10 } })
        New-TestFile $Path (($Lines -join "`n") + "`n")
    }

    # What a command printed, with runs of spaces collapsed, so that a test does not depend on the column widths
    function Get-TestLines {
        param(
            [Parameter(Position = 0)][Object[]]$Output
        )

        return @($Output | ForEach-Object { ("$_" -replace '\s+', ' ').Trim() })
    }

    Set-Variable -Option Constant TestProject ([String](Join-Path $TestDrive 'project'))
    Set-Variable -Option Constant TestSession ([String](Join-Path $TestProject 'aaaa1111-0000.jsonl'))

    Set-Variable -Option Constant CommandNotFound ([String](@(
                'Exit code 1',
                'Get-Thing : The term ''Get-Thing'' is not recognized as the name of a cmdlet, function, script file, or operable',
                'program.',
                'At line:1 char:1',
                '    + CategoryInfo          : ObjectNotFound: (Get-Thing:String) [], CommandNotFoundException',
                '    + FullyQualifiedErrorId : CommandNotFoundException'
            ) -join "`n"))

    New-TestTranscript $TestSession @(
        @{ type = 'ai-title'; aiTitle = 'A title' },
        @{ type = 'user'; timestamp = '2026-01-03T10:00:00.000Z'; origin = @{ kind = 'human' }; message = @{ content = @(@{ type = 'text'; text = 'Please do the thing' }) } },
        @{ type = 'assistant'; message = @{ id = 'm1'; usage = @{ input_tokens = 10; cache_creation_input_tokens = 20; cache_read_input_tokens = 100; output_tokens = 5 }; content = @(@{ type = 'text'; text = 'On it' }) } },
        @{ type = 'assistant'; message = @{ id = 'm1'; usage = @{ input_tokens = 10; cache_creation_input_tokens = 20; cache_read_input_tokens = 100; output_tokens = 5 }; content = @(@{ type = 'tool_use'; id = 't1'; name = 'PowerShell'; input = @{ command = 'Get-Thing' } }) } },
        @{ type = 'user'; message = @{ content = @(@{ type = 'tool_result'; tool_use_id = 't1'; is_error = $True; content = $CommandNotFound }) } },
        @{ type = 'assistant'; message = @{ id = 'm2'; usage = @{ input_tokens = 1; cache_creation_input_tokens = 0; cache_read_input_tokens = 300; output_tokens = 7 }; content = @(@{ type = 'tool_use'; id = 't2'; name = 'PowerShell'; input = @{ command = 'git add x; Get-Date' } }, @{ type = 'tool_use'; id = 't3'; name = 'Read'; input = @{ file_path = 'C:\x.txt' } }) } },
        @{ type = 'user'; message = @{ content = @(@{ type = 'tool_result'; tool_use_id = 't2'; content = @(@{ type = 'text'; text = "error: pathspec 'x' did not match any files`n03 January 2026" }) }, @{ type = 'tool_result'; tool_use_id = 't3'; content = ('a' * 2000) }) } },
        @{ type = 'user'; origin = @{ kind = 'human' }; message = @{ content = 'No, revert that' } },
        @{ type = 'user'; isMeta = $True; message = @{ content = @(@{ type = 'text'; text = 'Base directory for this skill: C:\skills\one' }) } },
        @{ type = 'user'; origin = @{ kind = 'task-notification' }; message = @{ content = '<task-notification>done</task-notification>' } },
        'not json {',
        @{ type = 'assistant'; message = @{ id = 'm3'; usage = @{ input_tokens = 2; cache_creation_input_tokens = 0; cache_read_input_tokens = 0; output_tokens = 1 }; content = @(@{ type = 'tool_use'; id = 't4'; name = 'WebFetch'; input = @{ url = 'https://example.com' } }, @{ type = 'tool_use'; id = 't5'; name = 'PowerShell'; input = @{ command = "'--- search'; git grep -n Missing" } }, @{ type = 'tool_use'; id = 't6'; name = 'PowerShell'; input = @{ command = 'git status --short; exit 255' } }) } },
        @{ type = 'user'; message = @{ content = @(@{ type = 'tool_result'; tool_use_id = 't4'; is_error = $True; content = 'Request failed with status code 404' }, @{ type = 'tool_result'; tool_use_id = 't5'; is_error = $True; content = "Exit code 1`n--- search" }, @{ type = 'tool_result'; tool_use_id = 't6'; is_error = $True; content = "Exit code 255`n M AGENTS.md" }) } }
    )

    New-TestTranscript (Join-Path (Join-Path (Join-Path $TestProject 'aaaa1111-0000') 'subagents') 'agent-1.jsonl') @(
        @{ type = 'assistant'; message = @{ id = 's1'; usage = @{ input_tokens = 0; cache_creation_input_tokens = 0; cache_read_input_tokens = 0; output_tokens = 100 }; content = @() } }
    )
}

Describe 'Get-TokenEstimate' {
    It 'Should count four characters to a token' {
        Get-TokenEstimate 400 | Should -BeExactly 100
    }
}

Describe 'Get-Excerpt' {
    It 'Should put a text on one line' {
        Get-Excerpt "one`n  two`tthree " | Should -BeExactly 'one two three'
    }

    It 'Should cut a long text to the length asked for' {
        Set-Variable -Option Constant Excerpt ([String](Get-Excerpt ('x' * 200) 20))

        $Excerpt | Should -BeExactly (('x' * 17) + '...')
    }

    It 'Should return nothing for no text' {
        Get-Excerpt $Null | Should -BeExactly ''
    }
}

Describe 'Get-EntryProperty' {
    It 'Should return the value of a property' {
        Get-EntryProperty ([PSCustomObject]@{ type = 'user' }) 'type' | Should -BeExactly 'user'
    }

    It 'Should return nothing for a property the entry does not have' {
        Get-EntryProperty ([PSCustomObject]@{ type = 'user' }) 'message' | Should -BeNullOrEmpty
    }

    It 'Should return nothing for no entry, or one that is a text' {
        Get-EntryProperty $Null 'type' | Should -BeNullOrEmpty
        Get-EntryProperty 'a text' 'type' | Should -BeNullOrEmpty
    }
}

Describe 'Get-ErrorLabel' {
    It 'Should give one label to every shell result that opens with its exit code' -ForEach @(
        @{ Text = "Exit code 1`n`n--- success`n  done" }
        @{ Text = "Exit code 255`n M AGENTS.md" }
        @{ Text = 'Exit code 66' }
    ) {
        Get-ErrorLabel $Text | Should -BeExactly 'flagged for its exit code alone'
    }

    It 'Should return the first line of any other result' {
        Get-ErrorLabel "`nRequest failed with status code 404`nmore" | Should -BeExactly 'Request failed with status code 404'
    }

    It 'Should say so when there is nothing' {
        Get-ErrorLabel " `n" | Should -BeExactly '(empty)'
    }
}

Describe 'Get-FailureSignature' {
    It 'Should label <Expected>' -ForEach @(
        @{ Expected = 'the Bash tool could not fork'; Text = "Exit code 254`n/etc/profile: fork: retry: Resource temporarily unavailable" }
        @{ Expected = 'a command PowerShell does not know (gh)'; Text = "gh : The term 'gh' is not recognized as the name of a cmdlet, function, script file, or operable program.`n    + FullyQualifiedErrorId : CommandNotFoundException" }
        @{ Expected = 'a PowerShell parse error'; Text = "An empty pipe element is not allowed.`n    + CategoryInfo          : ParserError: (:) [Invoke-Expression], ParseException`n    + FullyQualifiedErrorId : EmptyPipeElement,Microsoft.PowerShell.Commands.InvokeExpressionCommand" }
        @{ Expected = 'a PowerShell error (FileOpenFailure)'; Text = "Out-File : Could not find a part of the path 'C:\x'.`n    + CategoryInfo          : OpenError: (:) [Out-File], DirectoryNotFoundException`n    + FullyQualifiedErrorId : FileOpenFailure,Microsoft.PowerShell.Commands.OutFileCommand" }
        @{ Expected = 'git refused'; Text = "On branch master`nerror: pathspec 'x' did not match any file(s) known to git" }
        @{ Expected = 'git refused'; Text = 'git : fatal: not a git repository (or any of the parent directories): .git' }
        @{ Expected = 'a command not found (jq)'; Text = 'bash: line 1: jq: command not found' }
        @{ Expected = 'a missing file (cat)'; Text = 'cat: missing.txt: No such file or directory' }
        @{ Expected = 'a permission refused (rm)'; Text = "rm: cannot remove 'x': Permission denied" }
    ) {
        Get-FailureSignature $Text | Should -BeExactly $Expected
    }

    It 'Should find nothing in <Name>' -ForEach @(
        @{ Name = 'a result without a failure'; Text = "On branch master`nnothing to commit, working tree clean" }
        @{ Name = 'what a native command wrote to its error stream'; Text = "git : Cloning into 'x'...`n    + CategoryInfo          : NotSpecified: (Cloning into 'x'...:String) [], RemoteException`n    + FullyQualifiedErrorId : NativeCommandError" }
        @{ Name = 'a failing test'; Text = "[-] Should do the thing 12ms (10ms|2ms)`n Expected 1, but got 2.`nTests Passed: 3, Failed: 1" }
        @{ Name = 'a text that only mentions a failure'; Text = "    # reports The term 'gh' is not recognized as the name of a cmdlet`n    'fork: Resource busy'" }
        @{ Name = 'an empty result'; Text = '' }
    ) {
        Get-FailureSignature $Text | Should -BeNullOrEmpty
    }

    It 'Should prefer the more telling kind wherever it stands' {
        Set-Variable -Option Constant Text ([String]"    + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.GetContentCommand`njq : The term 'jq' is not recognized as the name of a cmdlet")

        Get-FailureSignature $Text | Should -BeExactly 'a command PowerShell does not know (jq)'
    }
}

Describe 'Test-Prompt' {
    It 'Should take a message of human origin, whatever it starts with' {
        Test-Prompt ([PSCustomObject]@{ origin = [PSCustomObject]@{ kind = 'human' } }) '<pasted_content id="1"> Please do this' | Should -BeTrue
    }

    It 'Should not take a message of another origin' {
        Test-Prompt ([PSCustomObject]@{ origin = [PSCustomObject]@{ kind = 'task-notification' } }) 'Finished' | Should -BeFalse
    }

    It 'Should not take what the harness added' {
        Test-Prompt ([PSCustomObject]@{ isMeta = $True; origin = [PSCustomObject]@{ kind = 'human' } }) 'A skill''s body' | Should -BeFalse
    }

    It 'Should judge a message without an origin by how it begins' {
        Test-Prompt ([PSCustomObject]@{ type = 'user' }) 'Please do this' | Should -BeTrue
        Test-Prompt ([PSCustomObject]@{ type = 'user' }) '<system-reminder>Note</system-reminder>' | Should -BeFalse
        Test-Prompt ([PSCustomObject]@{ type = 'user' }) 'Base directory for this skill: C:\skills\one' | Should -BeFalse
    }

    It 'Should not take an empty message' {
        Test-Prompt ([PSCustomObject]@{ origin = [PSCustomObject]@{ kind = 'human' } }) ' ' | Should -BeFalse
    }
}

Describe 'Test-Correction' {
    It 'Should take <Text>' -ForEach @(
        @{ Text = 'No, revert that' }
        @{ Text = 'Why did you delete the test?' }
        @{ Text = 'Use the helper instead' }
        @{ Text = 'Please don''t touch the build folder' }
    ) {
        Test-Correction $Text | Should -BeTrue
    }

    It 'Should not take <Text>' -ForEach @(
        @{ Text = 'Thank you! Please remove the settings no longer supported' }
        @{ Text = 'Add both settings, no matter the preset' }
        @{ Text = 'Thank you! I restarted the editor, let''s try again' }
        @{ Text = 'Please triage the pull request' }
    ) {
        Test-Correction $Text | Should -BeFalse
    }

    It 'Should not take a long message that happens to say "not"' {
        Test-Correction ('This is not a correction. ' * 20) | Should -BeFalse
    }
}

Describe 'Get-SkillDescription' {
    It 'Should read a description on its line' {
        Set-Variable -Option Constant Path ([String](Join-Path $TestDrive 'skill-line.md'))
        New-TestFile $Path "---`nname: one`ndescription: Does one thing - use it for that.`n---`n`n# One`n"

        Get-SkillDescription $Path | Should -BeExactly 'Does one thing - use it for that.'
    }

    It 'Should read a description folded over the lines below' {
        Set-Variable -Option Constant Path ([String](Join-Path $TestDrive 'skill-folded.md'))
        New-TestFile $Path "---`nname: two`ndescription: >`n  Does two things,`n  both of them well.`nlicense: none`n---`n"

        Get-SkillDescription $Path | Should -BeExactly 'Does two things, both of them well.'
    }

    It 'Should return nothing for a file without one' {
        Set-Variable -Option Constant Path ([String](Join-Path $TestDrive 'skill-none.md'))
        New-TestFile $Path "# No front matter`n"

        Get-SkillDescription $Path | Should -BeExactly ''
    }
}

Describe 'Get-ProjectSlug' {
    It 'Should turn <Path> into <Expected>' -ForEach @(
        @{ Path = 'c:\Users\qiiwexc\qiiwexc.github.io'; Expected = 'c--Users-qiiwexc-qiiwexc-github-io' }
        @{ Path = '/home/user/qiiwexc.github.io/'; Expected = '-home-user-qiiwexc-github-io' }
    ) {
        Get-ProjectSlug $Path | Should -BeExactly $Expected
    }
}

Describe 'Get-InstructionFiles' {
    It 'Should list the entry file and what it imports, each once' {
        Set-Variable -Option Constant Root ([String](Join-Path $TestDrive 'imports'))
        New-TestFile (Join-Path $Root 'CLAUDE.md') "# Entry`n`n@AGENTS.md`n@missing.md`nMail @someone about it`n"
        New-TestFile (Join-Path $Root 'AGENTS.md') "@docs/more.md`n@CLAUDE.md`n"
        New-TestFile (Join-Path (Join-Path $Root 'docs') 'more.md') 'More'
        New-TestFile (Join-Path $Root 'unrelated.md') 'Unrelated'

        Set-Variable -Option Constant Files ([String[]]@(Get-InstructionFiles $Root | ForEach-Object { Get-RelativePath $Root $_ }))

        $Files | Should -BeExactly @('CLAUDE.md', 'AGENTS.md', 'docs/more.md')
    }

    It 'Should list nothing where there is no entry file' {
        Set-Variable -Option Constant Root ([String](Join-Path $TestDrive 'no-entry'))
        New-TestFile (Join-Path $Root 'AGENTS.md') 'Rules'

        @(Get-InstructionFiles $Root).Count | Should -BeExactly 0
    }
}

Describe 'Show-Context' {
    BeforeAll {
        Mock Test-IgnoredPath { return $False }

        Set-Variable -Option Constant Root ([String](Join-Path $TestDrive 'context'))
        Set-Variable -Option Constant Project ([String](Join-Path $TestDrive 'context-project'))
        Set-Variable -Option Constant User ([String](Join-Path $TestDrive 'context-user'))

        New-TestFile (Join-Path $Root 'CLAUDE.md') ("@AGENTS.md`n" + ('c' * 29))
        New-TestFile (Join-Path $Root 'AGENTS.md') ('a' * 400)
        New-TestFile (Join-Path (Join-Path $Root '.github') 'copilot-instructions.md') ('g' * 20)
        New-TestFile (Join-Path (Join-Path $Root 'sub') 'CLAUDE.md') ('n' * 8)
        New-TestFile (Join-Path (Join-Path (Join-Path (Join-Path $Root '.claude') 'skills') 'one') 'SKILL.md') ("---`nname: one`ndescription: " + ('d' * 80) + "`n---`n")
        New-TestFile (Join-Path (Join-Path $Project 'memory') 'MEMORY.md') ("- [One](one.md) - hook`n- [Two](two.md) - " + ('h' * 202) + "`n")
        New-TestFile (Join-Path (Join-Path $Project 'memory') 'one.md') ('m' * 12)
        New-TestFile (Join-Path $User 'CLAUDE.md') ('u' * 40)
        New-TestFile (Join-Path (Join-Path (Join-Path (Join-Path $User 'skills') 'synced') 'two') 'SKILL.md') ("---`ndescription: " + ('e' * 40) + "`n---`n")
    }

    It 'Should size what every session loads' {
        Set-Variable -Option Constant Lines ([String[]](Get-TestLines (Show-Context -RepositoryRoot $Root -ProjectDirectory $Project -UserDirectory $User)))

        $Lines | Should -Contain '10 tok 40 ch CLAUDE.md'
        $Lines | Should -Contain '100 tok 400 ch AGENTS.md'
        $Lines | Should -Contain '61 tok 244 ch memory/MEMORY.md (the index)'
        $Lines | Should -Contain '1 of its lines over 200 characters, the longest 220'
        $Lines | Should -Contain 'Skill descriptions (listed in every session): 20 tok over 1 skills'
        $Lines | Should -Contain '20 tok one'
        $Lines | Should -Contain 'Fixed in every session, before the harness''s own prompt: 191 tok'
    }

    It 'Should list what lies outside the fixed cost' {
        Set-Variable -Option Constant Lines ([String[]](Get-TestLines (Show-Context -RepositoryRoot $Root -ProjectDirectory $Project -UserDirectory $User)))

        $Lines | Should -Contain '10 tok 40 ch ~/.claude/CLAUDE.md'
        $Lines | Should -Contain '10 tok the description of two (~/.claude/skills)'
        $Lines | Should -Contain '5 tok 20 ch .github/copilot-instructions.md'
        $Lines | Should -Contain '2 tok 8 ch sub/CLAUDE.md'
        $Lines | Should -Contain '3 tok 12 ch memory/one.md'
        @($Lines -match '^\d+ tok \d+ ch \.claude/skills/one/SKILL\.md$').Count | Should -BeExactly 1
    }

    It 'Should leave out an instruction file that git ignores' {
        Mock Test-IgnoredPath { return $True }

        Set-Variable -Option Constant Lines ([String[]](Get-TestLines (Show-Context -RepositoryRoot $Root -ProjectDirectory $Project -UserDirectory $User)))

        $Lines | Should -Not -Contain '2 tok 8 ch sub/CLAUDE.md'
        $Lines | Should -Not -Contain 'Loaded when a session works in that directory:'
    }

    It 'Should not count an AGENTS.md that no entry file imports' {
        Set-Variable -Option Constant Bare ([String](Join-Path $TestDrive 'context-bare'))
        New-TestFile (Join-Path $Bare 'CLAUDE.md') ('c' * 40)
        New-TestFile (Join-Path $Bare 'AGENTS.md') ('a' * 400)

        Set-Variable -Option Constant Lines ([String[]](Get-TestLines (Show-Context -RepositoryRoot $Bare -ProjectDirectory (Join-Path $TestDrive 'none') -UserDirectory (Join-Path $TestDrive 'none'))))

        $Lines | Should -Contain 'Not loaded by Claude Code (read by other platforms):'
        $Lines | Should -Contain '100 tok 400 ch AGENTS.md'
        $Lines | Should -Contain 'Fixed in every session, before the harness''s own prompt: 10 tok'
    }
}

Describe 'Get-NamedPaths' {
    BeforeAll {
        Mock Test-IgnoredPath { return $Path -like '*build/out.ps1' }

        Set-Variable -Option Constant Root ([String](Join-Path $TestDrive 'paths'))
        Set-Variable -Option Constant Skill ([String](Join-Path (Join-Path (Join-Path (Join-Path $Root '.claude') 'skills') 'one') 'SKILL.md'))

        New-TestFile (Join-Path $Root 'test.bat')
        New-TestFile (Join-Path (Join-Path $Root 'tools') 'build.ps1')
        New-TestFile (Join-Path (Join-Path (Join-Path $Root 'src') 'App lifecycle') 'Updater.ps1')
        New-TestFile (Join-Path (Join-Path $Root 'build') 'made.txt')
        New-TestFile (Join-Path (Join-Path (Join-Path (Join-Path $Root '.claude') 'skills') 'two') 'SKILL.md')
        New-TestFile $Skill (@(
                '# One',
                '',
                'See [two](../two/SKILL.md#step-1), [three](../three/SKILL.md), [a site](https://example.com/x) and [below](#below).',
                'Run `tools\build.ps1 -Full -CI` or `.\test.bat`, never `.\gone.bat`.',
                'The updater is `src/App lifecycle/Updater.ps1`, not `src/App lifecycle/Gone.ps1`.',
                'Not checked: `tools/<name>.ps1`, `tools/*.ps1`, `other/thing.ps1`, `Updater.ps1`, `build/out.ps1`.',
                'An index line is `- [Title](file.md) -',
                'hook`, and `tools\build.ps1` is named twice.',
                '',
                '```powershell',
                '.\fenced.bat',
                '`tools\fenced.ps1`',
                '```',
                ''
            ) -join "`n")

        Set-Variable -Option Constant Named ([PSObject[]]@(Get-NamedPaths $Root $Skill))
    }

    It 'Should find the paths that exist, as written or before a command''s arguments' {
        @($Named | Where-Object { $_.Found } | ForEach-Object { $_.Path }) | Should -BeExactly @(
            '../two/SKILL.md',
            'tools\build.ps1 -Full -CI',
            'test.bat',
            'src/App lifecycle/Updater.ps1',
            'tools\build.ps1'
        )
    }

    It 'Should report the paths that do not exist, with their lines' {
        @($Named | Where-Object { -not $_.Found } | ForEach-Object { "$($_.Line) $($_.Path)" }) | Should -BeExactly @(
            '3 ../three/SKILL.md',
            '4 gone.bat',
            '5 src/App lifecycle/Gone.ps1'
        )
    }

    It 'Should ask git only about a path that was not found' {
        Should -Invoke Test-IgnoredPath -Exactly 4 -Scope Describe
        Should -Invoke Test-IgnoredPath -Exactly 1 -Scope Describe -ParameterFilter { $Path -like '*build/out.ps1' }
    }
}

Describe 'Show-Paths' {
    It 'Should print the paths that were not found, each with its file and line' {
        Mock Test-IgnoredPath { return $False }

        Set-Variable -Option Constant Root ([String](Join-Path $TestDrive 'show-paths'))
        New-TestFile (Join-Path $Root 'CLAUDE.md') "@AGENTS.md`n"
        New-TestFile (Join-Path $Root 'AGENTS.md') "# Rules`n`nRun ``.\test.bat`` and read [the page](docs/page.md).`n"
        New-TestFile (Join-Path $Root 'test.bat')

        Show-Paths $Root | Should -BeExactly @(
            'Paths named in 2 agent files: 2 checked, 1 not found',
            '  AGENTS.md:3  docs/page.md'
        )
    }
}

Describe 'Get-SessionStart' {
    It 'Should return the first timestamp of a transcript, in UTC' {
        Set-Variable -Option Constant Path ([String](Join-Path $TestDrive 'start.jsonl'))
        New-TestTranscript $Path @(
            @{ type = 'ai-title'; aiTitle = 'No stamp here' },
            'not json {',
            @{ type = 'user'; timestamp = '2026-01-03T23:30:00.000+02:00' },
            @{ type = 'user'; timestamp = '2026-01-05T10:00:00.000Z' }
        )

        Get-SessionStart $Path | Should -BeExactly '2026-01-03 21:30:00'
    }

    It 'Should return nothing for a transcript without a timestamp' {
        Set-Variable -Option Constant Path ([String](Join-Path $TestDrive 'no-start.jsonl'))
        New-TestTranscript $Path @(@{ type = 'ai-title'; aiTitle = 'No stamp here' })

        Get-SessionStart $Path | Should -BeExactly ''
    }
}

Describe 'Get-Transcripts' {
    BeforeAll {
        Set-Variable -Option Constant Project ([String](Join-Path $TestDrive 'transcripts'))

        New-TestTranscript (Join-Path $Project 'aaaa1111.jsonl') @(@{ type = 'user'; timestamp = '2026-01-03T10:00:00.000Z' })
        New-TestTranscript (Join-Path $Project 'bbbb2222.jsonl') @(@{ type = 'user'; timestamp = '2026-01-05T10:00:00.000Z' })
        New-TestTranscript (Join-Path $Project 'cccc3333.jsonl') @(@{ type = 'user'; timestamp = '2026-01-04T10:00:00.000Z' })
        New-TestTranscript (Join-Path $Project 'dddd4444.jsonl') @(@{ type = 'ai-title'; aiTitle = 'No session' })
        New-TestFile (Join-Path $Project 'notes.txt') 'Not a transcript'

        # The one that started first was written to last, as a resumed session is
        (Get-Item -LiteralPath (Join-Path $Project 'aaaa1111.jsonl')).LastWriteTime = (Get-Date).AddDays(1)
    }

    It 'Should return the sessions that started last, newest first' {
        @(Get-Transcripts $Project 2 | ForEach-Object { $_.Id }) | Should -BeExactly @('bbbb2222', 'cccc3333')
    }

    It 'Should drop a transcript that holds no session' {
        @(Get-Transcripts $Project 15 | ForEach-Object { $_.Id }) | Should -BeExactly @('bbbb2222', 'cccc3333', 'aaaa1111')
    }

    It 'Should leave out the excluded sessions, each by the start of its ID' {
        @(Get-Transcripts -ProjectDirectory $Project -Count 15 -Excluded @('bbbb', '', 'aaaa1111') | ForEach-Object { $_.Id }) | Should -BeExactly @('cccc3333')
    }

    It 'Should return nothing where there is no project directory' {
        @(Get-Transcripts (Join-Path $TestDrive 'nowhere') 15).Count | Should -BeExactly 0
    }
}

Describe 'Read-Session' {
    BeforeAll {
        Set-Variable -Option Constant Stats ([PSObject](Read-Session $TestSession))
    }

    It 'Should count every API call once, with the subagents'' calls' {
        $Stats.Usage['input_tokens'] | Should -BeExactly 13
        $Stats.Usage['cache_creation_input_tokens'] | Should -BeExactly 20
        $Stats.Usage['cache_read_input_tokens'] | Should -BeExactly 400
        $Stats.Usage['output_tokens'] | Should -BeExactly 113
    }

    It 'Should keep the largest context a call was sent' {
        $Stats.PeakContext | Should -BeExactly 301
    }

    It 'Should count the prompts the user typed, and the ones pushing back' {
        $Stats.Title | Should -BeExactly 'A title'
        $Stats.Prompts | Should -BeExactly 2
        $Stats.Corrections | Should -BeExactly @('No, revert that')
    }

    It 'Should count the tool calls by tool' {
        $Stats.Tools.Count | Should -BeExactly 3
        $Stats.Tools['PowerShell'] | Should -BeExactly 4
        $Stats.Tools['Read'] | Should -BeExactly 1
        $Stats.Tools['WebFetch'] | Should -BeExactly 1
    }

    It 'Should label a flagged shell failure by its signature' {
        Set-Variable -Option Constant Failure ([PSObject]$Stats.Failures[0])

        $Failure.Tool | Should -BeExactly 'PowerShell'
        $Failure.Said | Should -BeExactly 'a command PowerShell does not know (Get-Thing)'
        $Failure.Input | Should -BeExactly 'Get-Thing'
        $Failure.Flagged | Should -BeTrue
    }

    It 'Should find a failure in a shell result that was not flagged' {
        Set-Variable -Option Constant Failure ([PSObject]$Stats.Failures[1])

        $Failure.Said | Should -BeExactly 'git refused'
        $Failure.Input | Should -BeExactly 'git add x; Get-Date'
        $Failure.Flagged | Should -BeFalse
    }

    It 'Should label another tool''s failure by what it said' {
        Set-Variable -Option Constant Failure ([PSObject]$Stats.Failures[2])

        $Stats.Failures.Count | Should -BeExactly 5
        $Failure.Tool | Should -BeExactly 'WebFetch'
        $Failure.Said | Should -BeExactly 'Request failed with status code 404'
        $Failure.Flagged | Should -BeTrue
    }

    It 'Should give every shell result flagged for its exit code alone the same label' {
        $Stats.Failures[3].Said | Should -BeExactly 'flagged for its exit code alone'
        $Stats.Failures[3].Input | Should -BeExactly "'--- search'; git grep -n Missing"
        $Stats.Failures[4].Said | Should -BeExactly 'flagged for its exit code alone'
        $Stats.Failures[4].Flagged | Should -BeTrue
    }

    It 'Should keep the largest results' {
        $Stats.Largest[0].Characters | Should -BeExactly 2000
        $Stats.Largest[0].Tool | Should -BeExactly 'Read'
        $Stats.Largest[0].Input | Should -BeExactly 'C:\x.txt'
    }

    It 'Should count a line that is not JSON without stopping at it' {
        $Stats.Skipped | Should -BeExactly 1
    }
}

Describe 'Show-Sessions' {
    It 'Should print the numbers of each session' {
        Set-Variable -Option Constant Lines ([String[]](Get-TestLines (Show-Sessions $TestProject 15)))

        $Lines[0] | Should -BeExactly "Sessions in ${TestProject}:"
        $Lines | Should -Contain '== aaaa1111 2026-01-03 10:00 A title'
        $Lines | Should -Contain 'prompts 2, tool calls 6, errors 4 (+1 unflagged)'
        $Lines | Should -Contain 'input 433 tok (cache read 400), output 113, peak context 301'
        $Lines | Should -Contain 'tools: PowerShell 4, Read 1, WebFetch 1'
        $Lines | Should -Contain 'large result: 500 tok from Read C:\x.txt'
        $Lines | Should -Contain 'correction?: No, revert that'
        $Lines | Should -Contain '1 lines of the transcript could not be read'
        $Lines | Should -Contain 'All 1 sessions: output 113 tok, cache read 400 tok'
    }

    It 'Should say when there are fewer sessions than asked for' {
        Set-Variable -Option Constant Lines ([String[]](Get-TestLines (Show-Sessions -ProjectDirectory $TestProject -Count 15 -Excluded @('aaaa'))))

        $Lines | Should -Contain 'All 0 sessions: output 0 tok, cache read 0 tok'
        $Lines | Should -Contain 'Fewer than the 15 asked for: these are all the transcripts there are'
    }
}

Describe 'Show-Errors' {
    It 'Should group the failed calls by what they said' {
        Set-Variable -Option Constant Lines ([String[]](Get-TestLines (Show-Errors $TestProject 15)))

        $Lines[0] | Should -BeExactly 'Failed tool calls of 1 sessions - how many, in how many sessions:'
        $Lines | Should -Contain '1 in 1 PowerShell: a command PowerShell does not know (Get-Thing)'
        $Lines | Should -Contain '1 in 1 PowerShell: git refused (1 unflagged)'
        $Lines | Should -Contain '1 in 1 WebFetch: Request failed with status code #'
        $Lines | Should -Contain '2 in 1 PowerShell: flagged for its exit code alone'
        $Lines | Should -Contain 'e.g. git add x; Get-Date'
    }
}
