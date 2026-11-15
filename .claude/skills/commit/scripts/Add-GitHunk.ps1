#Requires -Version 5

# Staging part of a file, for the commit skill: 'git add -p' without its prompts.
#
#     Add-GitHunk.ps1 list <path>                  the file's unstaged hunks, numbered from 1
#     Add-GitHunk.ps1 stage <path> <n> [<n>...]    stage those hunks and leave the rest unstaged
#     Add-GitHunk.ps1 content <path> <file>        stage the content of <file> as <path>, for part of a hunk
#
# Run it from the repository's root as 'powershell -NoProfile -ExecutionPolicy Bypass -File <this file> <command>',
# or with 'pwsh' where there is no Windows PowerShell.
#
# The hunks are those of 'git diff -- <path>': what the working tree has that the index does not. 'stage' applies a
# patch of the chosen ones to the index alone ('git apply --cached'), and 'content' points the index at a stored
# copy of <file>, so neither touches the working tree. Run 'list' again after a 'stage': the hunks that are left
# are renumbered.
#
# A diff goes from git to a file and back as bytes, never through the pipeline: Windows PowerShell would decode
# what git prints with the console's code page and end every line it passes on with CR LF, and the patch would no
# longer match the file.

param(
    [Parameter(Position = 0)][String]$Command,
    [Parameter(Position = 1)][String]$Path,
    [Parameter(Position = 2, ValueFromRemainingArguments)][String[]]$Rest = @()
)

# ISO 8859-1 maps every byte to the character of the same number, so what is read with it is written back unchanged
function Get-ByteEncoding {
    return [Text.Encoding]::GetEncoding(28591)
}

# Runs git in a repository and returns the lines it printed. A failure throws what git said
function Invoke-Git {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Repository,
        [Parameter(Position = 1, Mandatory)][String[]]$Arguments
    )

    # Under 'Stop', Windows PowerShell makes a terminating error of the first line a native command writes to its
    # error stream, before the exit code can be read
    $ErrorActionPreference = 'Continue'

    [String[]]$Output = @(& git -C $Repository @Arguments 2>&1 | ForEach-Object { "$_" })
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments[0]) failed: $($Output -join ' ')"
    }

    return $Output
}

# The unstaged changes of one path as git prints them, each byte as one character
function Get-FileDiff {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Repository,
        [Parameter(Position = 1, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant PatchFile ([String][IO.Path]::GetTempFileName())

    try {
        # The plain text and the prefixes are spelled out: a user's configuration can change both, and
        # 'git apply' takes only this form
        $Null = Invoke-Git $Repository @('diff', '--no-color', '--no-ext-diff', '--no-textconv', '--src-prefix=a/', '--dst-prefix=b/', "--output=$PatchFile", '--', $Path)

        return (Get-ByteEncoding).GetString([IO.File]::ReadAllBytes($PatchFile))
    } finally {
        Remove-Item -LiteralPath $PatchFile -Force -ErrorAction SilentlyContinue
    }
}

# A diff's file header, and each of its hunks from its @@ line on. Only a hunk's own first line starts with @@:
# every line of its content starts with a space, a sign or a backslash
function Split-Diff {
    param(
        [Parameter(Position = 0)][String]$Diff
    )

    [String]$Header = ''
    [Collections.Generic.List[String]]$Hunks = New-Object Collections.Generic.List[String]

    foreach ($Line in [Regex]::Split($Diff, '(?<=\n)')) {
        if ($Line.StartsWith('@@')) {
            $Hunks.Add($Line)
        } elseif ($Hunks.Count -gt 0) {
            $Hunks[$Hunks.Count - 1] += $Line
        } else {
            $Header += $Line
        }
    }

    return @{
        Header = $Header
        Hunks  = [String[]]$Hunks
    }
}

# The header and the hunks of one file's unstaged changes. Throws where there is nothing to pick from
function Get-FileHunks {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Repository,
        [Parameter(Position = 1, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant Diff ([String](Get-FileDiff $Repository $Path))

    if ([Regex]::Matches($Diff, '(?m)^diff --git ').Count -gt 1) {
        throw "'$Path' holds more than one changed file: hunks are picked one file at a time"
    }

    Set-Variable -Option Constant Parts ([Hashtable](Split-Diff $Diff))

    if ($Parts.Hunks.Count -eq 0) {
        throw "'$Path' has no unstaged hunks: it has not changed, or the change is a new file, a binary file or a mode alone, which 'git add' stages whole"
    }

    return $Parts
}

# Prints the hunks of one file's unstaged changes, each under its number
function Show-Hunks {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Repository,
        [Parameter(Position = 1, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant Hunks ([String[]](Get-FileHunks $Repository $Path).Hunks)

    for ([Int]$Index = 0; $Index -lt $Hunks.Count; $Index++) {
        "=== hunk $($Index + 1) of $($Hunks.Count) ==="
        # To be read, the file's bytes are taken as UTF-8
        [Text.Encoding]::UTF8.GetString((Get-ByteEncoding).GetBytes($Hunks[$Index])).TrimEnd("`r", "`n")
    }
}

# Stages the hunks of one file picked by their numbers, and leaves the others unstaged
function Add-Hunks {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Repository,
        [Parameter(Position = 1, Mandatory)][String]$Path,
        [Parameter(Position = 2)][String[]]$Picked = @()
    )

    Set-Variable -Option Constant Parts ([Hashtable](Get-FileHunks $Repository $Path))
    Set-Variable -Option Constant Total ([Int]$Parts.Hunks.Count)

    if ($Picked.Count -eq 0) {
        throw "Name the hunks of '$Path' to stage, by the numbers 'list' prints: 1 to $Total"
    }

    [Int[]]$Numbers = @()
    foreach ($Each in $Picked) {
        [Int]$Number = 0
        if (-not [Int]::TryParse($Each, [ref]$Number) -or $Number -lt 1 -or $Number -gt $Total) {
            throw "'$Each' is not a hunk of '$Path': pick whole numbers from 1 to $Total, as 'list' prints them"
        }
        $Numbers += $Number
    }
    $Numbers = @($Numbers | Sort-Object -Unique)

    Set-Variable -Option Constant Patch ([String]($Parts.Header + (@($Numbers | ForEach-Object { $Parts.Hunks[$_ - 1] }) -join '')))
    Set-Variable -Option Constant PatchFile ([String][IO.Path]::GetTempFileName())

    try {
        [IO.File]::WriteAllBytes($PatchFile, (Get-ByteEncoding).GetBytes($Patch))

        # --recount: each hunk's line counts are worked out again, so a hunk staged without the ones before it
        # still applies at its own place
        $Null = Invoke-Git $Repository @('apply', '--cached', '--recount', $PatchFile)
    } finally {
        Remove-Item -LiteralPath $PatchFile -Force -ErrorAction SilentlyContinue
    }

    "Staged hunk $($Numbers -join ', ') of $Path"
}

# Points the index at a stored copy of a file's content, for a commit that takes only part of a hunk: the file is
# what the path should hold once that commit is made
function Set-IndexContent {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Repository,
        [Parameter(Position = 1, Mandatory)][String]$Path,
        [Parameter(Position = 2, Mandatory)][String]$File
    )

    if (-not (Test-Path -LiteralPath $File -PathType Leaf)) {
        throw "There is no file '$File' to take the content from"
    }

    # The mode the index has for the path, and a plain file's for a path that is new to it
    Set-Variable -Option Constant Entries ([String[]]@(Invoke-Git $Repository @('ls-files', '--stage', '--', $Path)))
    if ($Entries.Count -gt 1) {
        throw "'$Path' holds more than one file: content is staged one file at a time"
    }
    Set-Variable -Option Constant Mode ([String]$(if ($Entries.Count -eq 1) { ($Entries[0] -split ' ')[0] } else { '100644' }))

    # --path: the content is stored as 'git add' would store that path's, its line endings converted the same way
    Set-Variable -Option Constant Blob ([String]@(Invoke-Git $Repository @('hash-object', '-w', "--path=$Path", '--', (Convert-Path -LiteralPath $File)))[0])

    # The index names a path from the repository's root, with forward slashes
    Set-Variable -Option Constant Prefix ([String](@(Invoke-Git $Repository @('rev-parse', '--show-prefix')) -join ''))
    Set-Variable -Option Constant IndexPath ([String]($Prefix + ($Path -replace '\\', '/' -replace '^\./')))

    $Null = Invoke-Git $Repository @('update-index', '--add', '--cacheinfo', "$Mode,$Blob,$IndexPath")

    "Staged the content of $File as $IndexPath"
}

# Dot-sourced, as its tests do, the script only defines its functions
if ($MyInvocation.InvocationName -eq '.') {
    return
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# A hunk may hold any character the file does
[Console]::OutputEncoding = [Text.Encoding]::UTF8

Set-Variable -Option Constant Repository ([String](Get-Location).Path)
Set-Variable -Option Constant Valid ([Bool]$(
        switch ($Command) {
            'list' { $Path -and $Rest.Count -eq 0 }
            'stage' { $Path -and $Rest.Count -gt 0 }
            'content' { $Path -and $Rest.Count -eq 1 }
            default { $False }
        }
    ))

if (-not $Valid) {
    Write-Host 'Usage: Add-GitHunk.ps1 list <path> | stage <path> <n> [<n>...] | content <path> <file>'
    exit 1
}

try {
    switch ($Command) {
        'list' { Show-Hunks $Repository $Path }
        'stage' { Add-Hunks -Repository $Repository -Path $Path -Picked $Rest }
        'content' { Set-IndexContent -Repository $Repository -Path $Path -File $Rest[0] }
    }
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
