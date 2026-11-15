#Requires -Version 5

# Numbers for the agent-review skill: what every session loads, and what past sessions did.
#
#     Get-AgentStats.ps1 context           the always-loaded files and the skills' descriptions, by size
#     Get-AgentStats.ps1 paths             the paths the agent files name that do not exist
#     Get-AgentStats.ps1 sessions [<n>]    the newest <n> sessions (default 15): tokens, tool calls, errors,
#                                          corrections, the largest tool results
#     Get-AgentStats.ps1 errors [<n>]      every failed tool call of those sessions, grouped by what it said
#
#     -Exclude '<id>[,<id>]'               leave sessions out, each by the start of its ID as 'sessions' prints it.
#                                          Quoted: bare, PowerShell reads an ID of digits as a number and drops
#                                          its leading zero
#
# Run it as 'powershell -NoProfile -ExecutionPolicy Bypass -File <this file> <command>', or with 'pwsh' where
# there is no Windows PowerShell.
#
# Sizes are in characters and in tokens estimated at four characters each: good enough to rank, not to bill.
# Session transcripts are read from Claude Code's project directory for this repository. Excerpts are cut to
# 140 characters and only printed: they may quote a pasted message, so never copy them into a tracked file.
#
# The newest sessions are the ones that started last, by the first timestamp in the transcript, not by the
# file's modification time, which a resumed or still open session moves. The session running the script
# (CLAUDE_CODE_SESSION_ID) is always left out: it is not over, and it holds the review's own calls.
#
# A failed call is one the harness flagged as an error, or a shell result it did not flag that still shows a
# failure: a command in the middle of a chain fails without the result being flagged. Those are found by the
# signatures in Get-FailureSignature, which label a flagged shell failure too, and are counted as "unflagged".

param(
    [Parameter(Position = 0)][String]$Command,
    [Parameter(Position = 1)][Int]$Count = 15,
    [String[]]$Exclude = @()
)

function Get-TokenEstimate {
    param(
        [Parameter(Position = 0, Mandatory)][Long]$Characters
    )

    return [Long][Math]::Round($Characters / 4)
}

# One line of at most $Length characters: what a prompt, a command or an error says
function Get-Excerpt {
    param(
        [Parameter(Position = 0)][String]$Text,
        [Parameter(Position = 1)][Int]$Length = 140
    )

    Set-Variable -Option Constant Flat ([String](@($Text -split '\s+' | Where-Object { $_ }) -join ' '))
    if ($Flat.Length -le $Length) {
        return $Flat
    }

    return $Flat.Substring(0, $Length - 3) + '...'
}

# A property of a transcript entry, or $Null where it has none: under strict mode, reading a missing one throws.
# A list comes back unrolled, one of a single block as that block, so a caller that walks it wraps it in @()
function Get-EntryProperty {
    param(
        [Parameter(Position = 0)][Object]$Entry,
        [Parameter(Position = 1, Mandatory)][String]$Name
    )

    if ($Null -eq $Entry) {
        return $Null
    }

    [Object]$Property = $Entry.PSObject.Properties[$Name]
    if ($Null -eq $Property) {
        return $Null
    }

    return $Property.Value
}

# What an error says: past a shell's "Exit code 1", the first line of its output
function Get-FirstLine {
    param(
        [Parameter(Position = 0)][String]$Text
    )

    [String[]]$Lines = @($Text -split '\r?\n' | Where-Object { $_.Trim() })
    if ($Lines.Count -gt 1 -and $Lines[0].Trim() -match '^Exit code \d+$') {
        return $Lines[1]
    }
    if ($Lines.Count -gt 0) {
        return $Lines[0]
    }

    return '(empty)'
}

# The first failure a shell result shows, as a label to group by: its kind and, where the pattern has a group,
# what tells two failures of that kind apart. Nothing for a result that shows none.
#
# Each pattern is matched against one line and anchored to how the shell or the tool reports the failure, so
# that a file which merely mentions the words is not counted. The kinds are tried in this order over the whole
# result, so the more telling one wins wherever it stands. An error record that is only a native command's
# stderr ('NativeCommandError') is no failure: git writes its progress there. A failing test is not a failed
# call either, and no pattern here matches one. Add a pattern for a failure a transcript shows and this misses
function Get-FailureSignature {
    param(
        [Parameter(Position = 0)][String]$Text
    )

    Set-Variable -Option Constant Signatures ([Object[]]@(
            @('the Bash tool could not fork', 'fork: (?:retry: )?Resource temporarily unavailable'),
            @('a command PowerShell does not know', '^(?:\S+ : )?The term ''([^'']+)'' is not recognized as the name of'),
            @('a PowerShell parse error', '^\s*\+ CategoryInfo\s*: ParserError'),
            @('a PowerShell error', '^\s*\+ FullyQualifiedErrorId\s*: (?!NativeCommandError)([^,\s]+)'),
            @('git refused', '^(?:git(?:\.exe)? : )?(?:fatal|error): \S'),
            @('a command not found', '^\S+: (?:line \d+: )?(\S+): command not found$'),
            @('a missing file', '^([^\s:]+): .*No such file or directory$'),
            @('a permission refused', '^([^\s:]+): .*(?:Permission denied|Operation not permitted)$')
        ))

    Set-Variable -Option Constant Lines ([String[]]@($Text -split '\r?\n'))

    foreach ($Signature in $Signatures) {
        foreach ($Line in $Lines) {
            [Text.RegularExpressions.Match]$Found = [Regex]::Match($Line, $Signature[1])
            if (-not $Found.Success) {
                continue
            }
            if ($Found.Groups[1].Success) {
                return "$($Signature[0]) ($($Found.Groups[1].Value))"
            }

            return $Signature[0]
        }
    }

    return $Null
}

# Whether a user entry's text is a message the user typed: not a skill's body, a task notification or a harness
# reminder. The entry says where it came from; one that does not is judged by how such texts begin
function Test-Prompt {
    param(
        [Parameter(Position = 0)][Object]$Entry,
        [Parameter(Position = 1)][String]$Text
    )

    if (-not $Text.Trim() -or (Get-EntryProperty $Entry 'isMeta')) {
        return $False
    }

    Set-Variable -Option Constant Origin ([String](Get-EntryProperty (Get-EntryProperty $Entry 'origin') 'kind'))
    if ($Origin) {
        return $Origin -eq 'human'
    }

    return -not $Text.StartsWith('<') -and -not $Text.StartsWith('Base directory for this skill')
}

# A short message that may be pushing back: a long one is a request that happens to say "not", and so is a
# "no" that only counts ("no longer", "no matter"). A hint to read the message, not a verdict
function Test-Correction {
    param(
        [Parameter(Position = 0)][String]$Text
    )

    Set-Variable -Option Constant Pattern ([String]'\b(no(?! (?:longer|matter|more|need)\b)|not|don''t|do not|stop|instead|wrong|why did you|revert|undo|never)\b')

    return $Text.Length -lt 400 -and $Text -match $Pattern
}

# The description in a skill's front matter, which every session is shown: on its line, or folded over the
# indented lines below it
function Get-SkillDescription {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant Lines ([String[]]@(Get-Content -LiteralPath $Path -Encoding UTF8))

    for ([Int]$Index = 0; $Index -lt $Lines.Count; $Index++) {
        if ($Lines[$Index] -notmatch '^description:\s*(.*)$') {
            continue
        }

        [String]$Value = $Matches[1].Trim()
        if ($Value -notmatch '^[>|][+-]?$') {
            return $Value
        }

        [String[]]$Folded = @()
        while ($Index + 1 -lt $Lines.Count -and $Lines[$Index + 1] -match '^\s+\S') {
            $Index++
            $Folded += $Lines[$Index].Trim()
        }

        return $Folded -join ' '
    }

    return ''
}

function Get-FileLength {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path
    )

    # An empty file reads as $Null, which the type turns into an empty string
    [String]$Text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    return [Long]$Text.Length
}

function Get-RelativePath {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Root,
        [Parameter(Position = 1, Mandatory)][String]$Path
    )

    if (-not $Path.StartsWith($Root, [StringComparison]::OrdinalIgnoreCase)) {
        return $Path
    }

    return $Path.Substring($Root.Length).TrimStart('\', '/') -replace '\\', '/'
}

function Format-SizeRow {
    param(
        [Parameter(Position = 0, Mandatory)][Long]$Characters,
        [Parameter(Position = 1, Mandatory)][String]$Label
    )

    return '  {0,6} tok  {1,7} ch  {2}' -f (Get-TokenEstimate $Characters), $Characters, $Label
}

# Claude Code names a project's directory after the project's path, with every character that is neither a
# letter nor a digit turned into a hyphen
function Get-ProjectSlug {
    param(
        [Parameter(Position = 0, Mandatory)][String]$RepositoryRoot
    )

    return $RepositoryRoot.TrimEnd('\', '/') -replace '[^A-Za-z0-9]', '-'
}

# The instruction files Claude Code loads into every session, each once: its own entry files and what they
# import. A line holding nothing but '@<path>' imports that file, relative to the file naming it
function Get-InstructionFiles {
    param(
        [Parameter(Position = 0, Mandatory)][String]$RepositoryRoot
    )

    [Collections.Generic.List[String]]$Files = @()

    foreach ($Name in @('CLAUDE.md', '.claude/CLAUDE.md', 'CLAUDE.local.md')) {
        [String]$EntryFile = Join-Path $RepositoryRoot $Name
        if (Test-Path -LiteralPath $EntryFile -PathType Leaf) {
            $Files.Add((Convert-Path -LiteralPath $EntryFile))
        }
    }

    for ([Int]$Index = 0; $Index -lt $Files.Count; $Index++) {
        foreach ($Line in @(Get-Content -LiteralPath $Files[$Index] -Encoding UTF8)) {
            if ($Line -notmatch '^\s*@(\S+)\s*$') {
                continue
            }

            [String]$Imported = Join-Path (Split-Path -Parent $Files[$Index]) $Matches[1]
            if ((Test-Path -LiteralPath $Imported -PathType Leaf) -and (Convert-Path -LiteralPath $Imported) -notin $Files) {
                $Files.Add((Convert-Path -LiteralPath $Imported))
            }
        }
    }

    return $Files
}

# The skills under a directory: each one's name, file and the length of its description
function Get-Skills {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Directory
    )

    if (-not (Test-Path -LiteralPath $Directory)) {
        return
    }

    Get-ChildItem -LiteralPath $Directory -Recurse -File -Filter 'SKILL.md' |
        ForEach-Object {
            [PSCustomObject]@{
                Name        = $_.Directory.Name
                Path        = $_.FullName
                Description = [Long](Get-SkillDescription $_.FullName).Length
            }
        } |
        Sort-Object -Property @{ Expression = 'Description'; Descending = $True }, Name
}

# What every platform's sessions are told to read: the instruction files, the other platforms' entry files and
# every Markdown file of the skills
function Get-AgentFiles {
    param(
        [Parameter(Position = 0, Mandatory)][String]$RepositoryRoot
    )

    [Collections.Generic.List[String]]$Files = @(Get-InstructionFiles $RepositoryRoot)

    foreach ($Name in @('AGENTS.md', '.github/copilot-instructions.md')) {
        [String]$File = Join-Path $RepositoryRoot $Name
        if ((Test-Path -LiteralPath $File -PathType Leaf) -and (Convert-Path -LiteralPath $File) -notin $Files) {
            $Files.Add((Convert-Path -LiteralPath $File))
        }
    }

    Set-Variable -Option Constant SkillsPath ([String](Join-Path (Join-Path $RepositoryRoot '.claude') 'skills'))
    if (Test-Path -LiteralPath $SkillsPath) {
        Get-ChildItem -LiteralPath $SkillsPath -Recurse -File -Filter '*.md' | ForEach-Object { $Files.Add($_.FullName) }
    }

    return $Files
}

function Show-Context {
    param(
        [Parameter(Position = 0, Mandatory)][String]$RepositoryRoot,
        [Parameter(Position = 1, Mandatory)][String]$ProjectDirectory,
        [Parameter(Position = 2, Mandatory)][String]$UserDirectory
    )

    Set-Variable -Option Constant Root ([String](Convert-Path -LiteralPath $RepositoryRoot))
    Set-Variable -Option Constant MemoryPath ([String](Join-Path $ProjectDirectory 'memory'))
    Set-Variable -Option Constant IndexPath ([String](Join-Path $MemoryPath 'MEMORY.md'))
    Set-Variable -Option Constant SkillsPath ([String](Join-Path (Join-Path $Root '.claude') 'skills'))
    Set-Variable -Option Constant Loaded ([String[]]@(Get-InstructionFiles $Root))
    [Long]$Fixed = 0

    'Loaded at the start of every session:'
    foreach ($File in $Loaded) {
        [Long]$Characters = Get-FileLength $File
        $Fixed += $Characters
        Format-SizeRow $Characters (Get-RelativePath $Root $File)
    }
    if (Test-Path -LiteralPath $IndexPath) {
        [Long]$Characters = Get-FileLength $IndexPath
        $Fixed += $Characters
        Format-SizeRow $Characters 'memory/MEMORY.md (the index)'

        [Int[]]$LongLines = @(Get-Content -LiteralPath $IndexPath -Encoding UTF8 | ForEach-Object { $_.Length } | Where-Object { $_ -gt 200 })
        if ($LongLines.Count -gt 0) {
            "          $($LongLines.Count) of its lines over 200 characters, the longest $(($LongLines | Measure-Object -Maximum).Maximum)"
        }
    }

    Set-Variable -Option Constant Skills ([PSObject[]]@(Get-Skills $SkillsPath))
    [Long]$Described = 0
    $Skills | ForEach-Object { $Described += $_.Description }
    $Fixed += $Described

    ''
    "Skill descriptions (listed in every session): $(Get-TokenEstimate $Described) tok over $($Skills.Count) skills"
    foreach ($Skill in $Skills) {
        '  {0,6} tok  {1}' -f (Get-TokenEstimate $Skill.Description), $Skill.Name
    }

    ''
    "Fixed in every session, before the harness's own prompt: $(Get-TokenEstimate $Fixed) tok"

    # The user's own files: no part of the repository, yet every session on this machine loads them as well
    Set-Variable -Option Constant UserFile ([String](Join-Path $UserDirectory 'CLAUDE.md'))
    Set-Variable -Option Constant UserSkills ([PSObject[]]@(Get-Skills (Join-Path $UserDirectory 'skills')))
    if ((Test-Path -LiteralPath $UserFile) -or $UserSkills.Count -gt 0) {
        ''
        'Outside the repository, loaded in every session on this machine:'
        if (Test-Path -LiteralPath $UserFile) {
            Format-SizeRow (Get-FileLength $UserFile) '~/.claude/CLAUDE.md'
        }
        foreach ($Skill in $UserSkills) {
            '  {0,6} tok  the description of {1} (~/.claude/skills)' -f (Get-TokenEstimate $Skill.Description), $Skill.Name
        }
    }

    # Claude Code loads neither on its own: AGENTS.md only where an entry file imports it
    [String[]]$Others = @()
    foreach ($Name in @('AGENTS.md', '.github/copilot-instructions.md')) {
        [String]$File = Join-Path $Root $Name
        if ((Test-Path -LiteralPath $File -PathType Leaf) -and (Convert-Path -LiteralPath $File) -notin $Loaded) {
            $Others += Convert-Path -LiteralPath $File
        }
    }
    if ($Others.Count -gt 0) {
        ''
        'Not loaded by Claude Code (read by other platforms):'
        foreach ($File in $Others) {
            Format-SizeRow (Get-FileLength $File) (Get-RelativePath $Root $File)
        }
    }

    # An instruction file below the root, unless git ignores it, as it does a draft or a build output
    [String[]]$Nested = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.md' |
            Where-Object { $_.Name -in @('CLAUDE.md', 'AGENTS.md') -and $_.FullName -notin $Loaded -and $_.FullName -notin $Others } |
            ForEach-Object { $_.FullName } |
            Where-Object { -not (Test-IgnoredPath $Root $_) })
    if ($Nested.Count -gt 0) {
        ''
        'Loaded when a session works in that directory:'
        foreach ($File in $Nested) {
            Format-SizeRow (Get-FileLength $File) (Get-RelativePath $Root $File)
        }
    }

    ''
    'Read on demand (the skills'' files, then the memories):'
    if (Test-Path -LiteralPath $SkillsPath) {
        foreach ($Item in (Get-ChildItem -LiteralPath $SkillsPath -Recurse -File -Filter '*.md')) {
            Format-SizeRow (Get-FileLength $Item.FullName) (Get-RelativePath $Root $Item.FullName)
        }
    }
    if (Test-Path -LiteralPath $MemoryPath) {
        foreach ($Item in (Get-ChildItem -LiteralPath $MemoryPath -File -Filter '*.md' | Where-Object { $_.Name -ne 'MEMORY.md' })) {
            Format-SizeRow (Get-FileLength $Item.FullName) "memory/$($Item.Name)"
        }
    }
}

# Whether git ignores a path: one that is, such as a build output, is not expected to exist
function Test-IgnoredPath {
    param(
        [Parameter(Position = 0, Mandatory)][String]$RepositoryRoot,
        [Parameter(Position = 1, Mandatory)][String]$Path
    )

    $Null = git -C $RepositoryRoot check-ignore --quiet -- $Path
    return $LASTEXITCODE -eq 0
}

# Whether a path named in prose exists: as written, or without what follows it, as with a command's arguments
function Test-NamedPath {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Base,
        [Parameter(Position = 1, Mandatory)][String]$Named
    )

    [String]$Candidate = $Named -replace ':\d+$'

    while ($Candidate) {
        try {
            if (Test-Path -LiteralPath (Join-Path $Base $Candidate)) {
                return $True
            }
        } catch {
            return $False
        }

        [Int]$Space = $Candidate.LastIndexOf(' ')
        if ($Space -lt 1) {
            return $False
        }
        $Candidate = $Candidate.Substring(0, $Space).TrimEnd()
    }

    return $False
}

# The paths an agent file names, each with its line and whether it was found. A path is the target of a
# Markdown link, relative to the file, or a code span that starts with '.\' or with one of the repository's
# top-level entries, relative to the repository. Left out: fenced code, a span holding a placeholder or a
# wildcard, and a bare file name, which says nothing of where the file is
function Get-NamedPaths {
    param(
        [Parameter(Position = 0, Mandatory)][String]$RepositoryRoot,
        [Parameter(Position = 1, Mandatory)][String]$File
    )

    Set-Variable -Option Constant TopLevel ([String[]]@(Get-ChildItem -LiteralPath $RepositoryRoot -Force | ForEach-Object { $_.Name }))
    Set-Variable -Option Constant Blank ([Text.RegularExpressions.MatchEvaluator] { param($Found) $Found.Value -replace '[^\r\n]', ' ' })

    # Blanked rather than removed, so that the line numbers hold
    [String]$Text = Get-Content -LiteralPath $File -Raw -Encoding UTF8
    $Text = [Regex]::Replace($Text, '(?ms)^[ \t]*```.*?^[ \t]*```[ \t]*\r?$', $Blank)

    [Collections.Generic.List[PSObject]]$Named = @()

    # A code span may run over a line break, though not over an empty line
    Set-Variable -Option Constant SpanPattern ([String]'`((?:[^`\r\n]|\r?\n(?![ \t]*\r?\n))+)`')

    foreach ($Span in [Regex]::Matches($Text, $SpanPattern)) {
        [String]$Value = ($Span.Groups[1].Value -replace '\s+', ' ').Trim()
        if ($Value -match '[<>*{}$%|]') {
            continue
        }

        [String]$Relative = $Value -replace '^\.[\\/]'
        if (-not $Relative) {
            continue
        }
        if ($Relative -ne $Value -or ($Relative -match '[\\/]' -and ($Relative -split '[\\/]')[0] -in $TopLevel)) {
            $Named.Add([PSCustomObject]@{ Index = $Span.Index; Path = $Relative; Base = $RepositoryRoot })
        }
    }

    # A link inside a code span is an example of one
    Set-Variable -Option Constant Prose ([String][Regex]::Replace($Text, $SpanPattern, $Blank))
    foreach ($Link in [Regex]::Matches($Prose, '\[[^\]]*\]\(([^)\s]+)\)')) {
        [String]$Target = $Link.Groups[1].Value
        if ($Target -match '^(?:[a-z][a-z0-9+.-]*:|#)') {
            continue
        }

        $Named.Add([PSCustomObject]@{ Index = $Link.Index; Path = [Uri]::UnescapeDataString(($Target -replace '#.*$')); Base = (Split-Path -Parent $File) })
    }

    [Hashtable]$Seen = @{}
    foreach ($Item in ($Named | Sort-Object -Property Index)) {
        if ($Seen.ContainsKey($Item.Path)) {
            continue
        }
        $Seen[$Item.Path] = $True

        [Bool]$Found = Test-NamedPath $Item.Base $Item.Path
        if (-not $Found -and (Test-IgnoredPath $RepositoryRoot "$($Item.Base)/$($Item.Path)")) {
            continue
        }

        [PSCustomObject]@{
            File  = $File
            Line  = @($Text.Substring(0, $Item.Index) -split '\n').Count
            Path  = $Item.Path
            Found = $Found
        }
    }
}

function Show-Paths {
    param(
        [Parameter(Position = 0, Mandatory)][String]$RepositoryRoot
    )

    Set-Variable -Option Constant Root ([String](Convert-Path -LiteralPath $RepositoryRoot))
    Set-Variable -Option Constant Files ([String[]]@(Get-AgentFiles $Root))
    Set-Variable -Option Constant Named ([PSObject[]]@($Files | ForEach-Object { Get-NamedPaths $Root $_ }))
    Set-Variable -Option Constant Missing ([PSObject[]]@($Named | Where-Object { -not $_.Found }))

    "Paths named in $($Files.Count) agent files: $($Named.Count) checked, $($Missing.Count) not found"
    foreach ($Item in $Missing) {
        "  $(Get-RelativePath $Root $Item.File):$($Item.Line)  $($Item.Path)"
    }
}

# When a session began: the first timestamp its transcript holds, in UTC, or nothing for one that holds none
function Get-SessionStart {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant Reader ([IO.StreamReader]::new((Convert-Path -LiteralPath $Path)))
    try {
        while ($Null -ne ($Line = $Reader.ReadLine())) {
            try {
                [Object]$Stamp = Get-EntryProperty (ConvertFrom-Json -InputObject $Line) 'timestamp'
                # Windows PowerShell leaves the stamp a string, PowerShell 7 has already made a date of it
                if ($Stamp -is [String] -and $Stamp) {
                    $Stamp = [DateTime]::Parse($Stamp, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AdjustToUniversal)
                }
                if ($Stamp -is [DateTime]) {
                    return $Stamp.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
                }
            } catch {
                continue
            }
        }
    } finally {
        $Reader.Dispose()
    }

    return ''
}

# The $Count sessions that started last, newest first, without the excluded ones: each excluded by the start
# of its ID. A transcript without a timestamp holds no session and drops out
function Get-Transcripts {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ProjectDirectory,
        [Parameter(Position = 1, Mandatory)][Int]$Count,
        [Parameter(Position = 2)][String[]]$Excluded = @()
    )

    if (-not (Test-Path -LiteralPath $ProjectDirectory)) {
        return
    }

    Set-Variable -Option Constant Prefixes ([String[]]@($Excluded | Where-Object { $_ }))

    Get-ChildItem -LiteralPath $ProjectDirectory -File -Filter '*.jsonl' |
        Where-Object {
            [String]$Id = $_.BaseName
            -not @($Prefixes | Where-Object { $Id.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) }).Count
        } |
        ForEach-Object { [PSCustomObject]@{ Id = $_.BaseName; Started = Get-SessionStart $_.FullName; Path = $_.FullName } } |
        Where-Object { $_.Started } |
        Sort-Object -Property Started -Descending |
        Select-Object -First $Count
}

# Adds an API call's tokens to $Usage, once. One response is written as several transcript lines, one to each
# content block, each carrying the same usage, so a call is told apart by its message's ID: summed line by
# line, a session's tokens come out several times what they are. Returns the context the call was sent, and 0
# for a call already counted
function Add-CallUsage {
    param(
        [Parameter(Position = 0, Mandatory)][Object]$Entry,
        [Parameter(Position = 1, Mandatory)][Hashtable]$Usage,
        [Parameter(Position = 2, Mandatory)][AllowEmptyCollection()][Hashtable]$Seen
    )

    Set-Variable -Option Constant Message ([Object](Get-EntryProperty $Entry 'message'))

    [String]$Key = Get-EntryProperty $Message 'id'
    if (-not $Key) {
        $Key = Get-EntryProperty $Entry 'uuid'
    }
    if ($Seen.ContainsKey($Key)) {
        return [Long]0
    }
    $Seen[$Key] = $True

    Set-Variable -Option Constant CallUsage ([Object](Get-EntryProperty $Message 'usage'))
    [Long]$Context = 0

    foreach ($Name in @($Usage.Keys)) {
        [Object]$Value = Get-EntryProperty $CallUsage $Name
        if ($Value -is [ValueType]) {
            $Usage[$Name] += [Long]$Value
            if ($Name -ne 'output_tokens') {
                $Context += [Long]$Value
            }
        }
    }

    return $Context
}

# What a tool call was about: its command, its file, or what else names it
function Get-ToolInput {
    param(
        [Parameter(Position = 0)][Object]$ToolInput
    )

    foreach ($Name in @('command', 'file_path', 'pattern', 'skill', 'url', 'description')) {
        [String]$Value = Get-EntryProperty $ToolInput $Name
        if ($Value) {
            return $Value
        }
    }

    return ''
}

function Get-ResultText {
    param(
        [Parameter(Position = 0)][Object]$Block
    )

    [Object]$Content = Get-EntryProperty $Block 'content'
    if ($Content -is [String]) {
        return $Content
    }

    return @(@($Content) | ForEach-Object { [String](Get-EntryProperty $_ 'text') }) -join "`n"
}

# One session's numbers. Its tokens include its subagents', whose transcripts lie in a directory of their own
function Read-Session {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant ShellTools ([String[]]@('Bash', 'PowerShell'))
    Set-Variable -Option Constant FullPath ([String](Convert-Path -LiteralPath $Path))
    Set-Variable -Option Constant SubagentsPath ([String](Join-Path (Join-Path (Split-Path -Parent $FullPath) ([IO.Path]::GetFileNameWithoutExtension($FullPath))) 'subagents'))

    [Hashtable]$Usage = @{ input_tokens = [Long]0; cache_creation_input_tokens = [Long]0; cache_read_input_tokens = [Long]0; output_tokens = [Long]0 }
    [Hashtable]$Seen = @{}
    [Hashtable]$Tools = @{}
    [Hashtable]$ToolNames = @{}
    [Hashtable]$ToolInputs = @{}
    [Collections.Generic.List[String]]$Corrections = @()
    [Collections.Generic.List[PSObject]]$Failures = @()
    [Collections.Generic.List[PSObject]]$Results = @()
    [String]$Title = ''
    [Int]$Prompts = 0
    [Int]$Skipped = 0
    [Long]$PeakContext = 0

    foreach ($Line in [IO.File]::ReadAllLines($FullPath)) {
        if (-not $Line.Trim()) {
            continue
        }

        try {
            [Object]$Entry = ConvertFrom-Json -InputObject $Line
        } catch {
            $Skipped++
            continue
        }

        [String]$Type = Get-EntryProperty $Entry 'type'
        [Object]$Message = Get-EntryProperty $Entry 'message'

        if ($Type -eq 'ai-title') {
            foreach ($Name in @('aiTitle', 'title')) {
                [String]$Value = Get-EntryProperty $Entry $Name
                if ($Value) {
                    $Title = $Value
                    break
                }
            }
        } elseif ($Type -eq 'assistant') {
            [Long]$Context = Add-CallUsage -Entry $Entry -Usage $Usage -Seen $Seen
            if ($Context -gt $PeakContext) {
                $PeakContext = $Context
            }

            foreach ($Block in @(Get-EntryProperty $Message 'content')) {
                if ((Get-EntryProperty $Block 'type') -ne 'tool_use') {
                    continue
                }

                [String]$UseId = Get-EntryProperty $Block 'id'
                [String]$Name = Get-EntryProperty $Block 'name'
                $Tools[$Name] = 1 + [Int]$Tools[$Name]
                $ToolNames[$UseId] = $Name
                $ToolInputs[$UseId] = Get-Excerpt (Get-ToolInput (Get-EntryProperty $Block 'input'))
            }
        } elseif ($Type -eq 'user' -and -not (Get-EntryProperty $Entry 'isSidechain')) {
            foreach ($Block in @(Get-EntryProperty $Message 'content')) {
                [String]$BlockType = Get-EntryProperty $Block 'type'

                if ($Block -is [String] -or $BlockType -eq 'text') {
                    [String]$Text = if ($Block -is [String]) { $Block } else { Get-EntryProperty $Block 'text' }
                    if (Test-Prompt $Entry $Text) {
                        $Prompts++
                        if (Test-Correction $Text) {
                            $Corrections.Add((Get-Excerpt $Text))
                        }
                    }
                } elseif ($BlockType -eq 'tool_result') {
                    [String]$UseId = Get-EntryProperty $Block 'tool_use_id'
                    [String]$Name = if ($ToolNames.ContainsKey($UseId)) { $ToolNames[$UseId] } else { '?' }
                    [String]$ToolInput = $ToolInputs[$UseId]
                    [String]$Text = Get-ResultText $Block
                    [String]$Signature = if ($Name -in $ShellTools) { Get-FailureSignature $Text } else { '' }
                    [Bool]$Flagged = [Bool](Get-EntryProperty $Block 'is_error')

                    $Results.Add([PSCustomObject]@{ Characters = $Text.Length; Tool = $Name; Input = $ToolInput })

                    if ($Flagged -or $Signature) {
                        [String]$Said = if ($Signature) { $Signature } else { Get-Excerpt (Get-FirstLine $Text) }
                        $Failures.Add([PSCustomObject]@{ Tool = $Name; Said = $Said; Input = $ToolInput; Flagged = $Flagged })
                    }
                }
            }
        }
    }

    if (Test-Path -LiteralPath $SubagentsPath) {
        foreach ($File in (Get-ChildItem -LiteralPath $SubagentsPath -File -Filter '*.jsonl')) {
            foreach ($Line in [IO.File]::ReadAllLines($File.FullName)) {
                try {
                    [Object]$Entry = ConvertFrom-Json -InputObject $Line
                } catch {
                    continue
                }

                if ((Get-EntryProperty $Entry 'type') -eq 'assistant') {
                    $Null = Add-CallUsage -Entry $Entry -Usage $Usage -Seen $Seen
                }
            }
        }
    }

    return [PSCustomObject]@{
        Title       = $Title
        Prompts     = $Prompts
        Corrections = $Corrections
        Tools       = $Tools
        Failures    = $Failures
        Largest     = [PSObject[]]@($Results | Sort-Object -Property Characters -Descending | Select-Object -First 5)
        Usage       = $Usage
        PeakContext = $PeakContext
        Skipped     = $Skipped
    }
}

function Show-Sessions {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ProjectDirectory,
        [Parameter(Position = 1, Mandatory)][Int]$Count,
        [Parameter(Position = 2)][String[]]$Excluded = @()
    )

    Set-Variable -Option Constant Transcripts ([PSObject[]]@(Get-Transcripts -ProjectDirectory $ProjectDirectory -Count $Count -Excluded $Excluded))
    [Long]$Output = 0
    [Long]$CacheRead = 0

    "Sessions in ${ProjectDirectory}:"

    foreach ($Transcript in $Transcripts) {
        [PSObject]$Stats = Read-Session $Transcript.Path
        [Hashtable]$Usage = $Stats.Usage
        [Long]$Context = $Usage['input_tokens'] + $Usage['cache_read_input_tokens'] + $Usage['cache_creation_input_tokens']
        [Int]$ToolCalls = 0
        $Stats.Tools.Values | ForEach-Object { $ToolCalls += $_ }
        [Int]$Flagged = @($Stats.Failures | Where-Object { $_.Flagged }).Count
        [String]$Title = if ($Stats.Title) { $Stats.Title } else { '(untitled)' }
        $Output += $Usage['output_tokens']
        $CacheRead += $Usage['cache_read_input_tokens']

        ''
        "== $($Transcript.Id.Substring(0, [Math]::Min(8, $Transcript.Id.Length)))  $($Transcript.Started.Substring(0, 16))  $Title"
        "   prompts $($Stats.Prompts), tool calls $ToolCalls, errors $Flagged (+$($Stats.Failures.Count - $Flagged) unflagged)"
        '   input {0:N0} tok (cache read {1:N0}), output {2:N0}, peak context {3:N0}' -f $Context, $Usage['cache_read_input_tokens'], $Usage['output_tokens'], $Stats.PeakContext
        [String[]]$Tools = @($Stats.Tools.GetEnumerator() |
                Sort-Object -Property @{ Expression = 'Value'; Descending = $True }, Name |
                Select-Object -First 8 |
                ForEach-Object { "$($_.Name) $($_.Value)" })
        "   tools: $($Tools -join ', ')"
        foreach ($Result in ($Stats.Largest | Select-Object -First 3)) {
            '   large result: {0:N0} tok from {1} {2}' -f (Get-TokenEstimate $Result.Characters), $Result.Tool, $Result.Input
        }
        foreach ($Text in ($Stats.Corrections | Select-Object -First 4)) {
            "   correction?: $Text"
        }
        if ($Stats.Skipped -gt 0) {
            "   $($Stats.Skipped) lines of the transcript could not be read"
        }
    }

    ''
    'All {0} sessions: output {1:N0} tok, cache read {2:N0} tok' -f $Transcripts.Count, $Output, $CacheRead
    if ($Transcripts.Count -lt $Count) {
        "Fewer than the $Count asked for: these are all the transcripts there are"
    }
}

function Show-Errors {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ProjectDirectory,
        [Parameter(Position = 1, Mandatory)][Int]$Count,
        [Parameter(Position = 2)][String[]]$Excluded = @()
    )

    Set-Variable -Option Constant Transcripts ([PSObject[]]@(Get-Transcripts -ProjectDirectory $ProjectDirectory -Count $Count -Excluded $Excluded))
    [Hashtable]$Groups = @{}

    foreach ($Transcript in $Transcripts) {
        foreach ($Failure in (Read-Session $Transcript.Path).Failures) {
            # Numbers differ from one failure of a kind to the next: a line, a process, a size
            [String]$Said = $Failure.Said -replace '\d+', '#'
            [String]$Key = "$($Failure.Tool): $($Said.Substring(0, [Math]::Min(90, $Said.Length)))"

            if (-not $Groups.ContainsKey($Key)) {
                $Groups[$Key] = [PSCustomObject]@{ Label = $Key; Calls = 0; Unflagged = 0; Sessions = @{}; Example = $Failure.Input }
            }

            $Groups[$Key].Calls++
            $Groups[$Key].Sessions[$Transcript.Id] = $True
            if (-not $Failure.Flagged) {
                $Groups[$Key].Unflagged++
            }
        }
    }

    "Failed tool calls of $($Transcripts.Count) sessions - how many, in how many sessions:"
    foreach ($Group in ($Groups.Values | Sort-Object -Property @{ Expression = 'Calls'; Descending = $True }, Label | Select-Object -First 40)) {
        [String]$Hidden = if ($Group.Unflagged -gt 0) { "  ($($Group.Unflagged) unflagged)" } else { '' }
        '{0,4} in {1,2}  {2}{3}' -f $Group.Calls, $Group.Sessions.Count, $Group.Label, $Hidden
        "              e.g. $($Group.Example)"
    }
}

# Dot-sourced, as its tests do, the script only defines its functions
if ($MyInvocation.InvocationName -eq '.') {
    return
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Set-Variable -Option Constant Commands ([String[]]@('context', 'paths', 'sessions', 'errors'))
if ($Command -notin $Commands -or $Count -lt 1) {
    Write-Host "Usage: Get-AgentStats.ps1 <$($Commands -join '|')> [<sessions>] [-Exclude '<id>[,<id>]']"
    exit 1
}

# An excerpt may hold any character the user typed
[Console]::OutputEncoding = [Text.Encoding]::UTF8

# This file lies four directories below the repository: .claude\skills\agent-review\scripts
Set-Variable -Option Constant RepositoryRoot ([String](Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))))
Set-Variable -Option Constant UserDirectory ([String](Join-Path $HOME '.claude'))
Set-Variable -Option Constant ProjectDirectory ([String](Join-Path (Join-Path $UserDirectory 'projects') (Get-ProjectSlug $RepositoryRoot)))
# Given through -File, a list arrives as one string with its commas in it
Set-Variable -Option Constant Excluded ([String[]]@(@($Exclude | ForEach-Object { $_ -split ',' }) + $env:CLAUDE_CODE_SESSION_ID | Where-Object { $_ }))

switch ($Command) {
    'context' { Show-Context -RepositoryRoot $RepositoryRoot -ProjectDirectory $ProjectDirectory -UserDirectory $UserDirectory }
    'paths' { Show-Paths $RepositoryRoot }
    'sessions' { Show-Sessions -ProjectDirectory $ProjectDirectory -Count $Count -Excluded $Excluded }
    'errors' { Show-Errors -ProjectDirectory $ProjectDirectory -Count $Count -Excluded $Excluded }
}
