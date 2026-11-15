BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    # A file with exactly this text: no byte order mark, and the line endings it is given
    function Set-TestFile {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Path,
            [Parameter(Position = 1)][String]$Text = ''
        )

        [IO.File]::WriteAllText($Path, $Text)
    }

    # Thirty numbered lines, far enough apart for a change near each end to be a hunk of its own
    function Get-TestText {
        param(
            [Parameter(Position = 0)][Hashtable]$Changed = @{},
            [Parameter(Position = 1)][String]$LineEnding = "`n"
        )

        return (@(1..30 | ForEach-Object { if ($Changed.ContainsKey($_)) { $Changed[$_] } else { "line $_" } }) -join $LineEnding) + $LineEnding
    }

    # A repository of its own, with the thirty lines committed as 'file.txt' under a name with a space in it
    function New-TestRepository {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Name,
            [Parameter(Position = 1)][String]$LineEnding = "`n"
        )

        Set-Variable -Option Constant Repository ([String](Join-Path $TestDrive $Name))
        $Null = New-Item -ItemType Directory -Force (Join-Path $Repository 'some folder')

        foreach ($Arguments in @(
                @('init', '--quiet'),
                @('config', 'user.name', 'Test'),
                @('config', 'user.email', 'test@example.com'),
                @('config', 'core.autocrlf', 'false'),
                @('config', 'commit.gpgsign', 'false')
            )) {
            $Null = Invoke-Git $Repository $Arguments
        }

        Set-TestFile (Join-Path $Repository 'some folder\file.txt') (Get-TestText @{} $LineEnding)
        $Null = Invoke-Git $Repository @('add', '--', 'some folder/file.txt')
        $Null = Invoke-Git $Repository @('commit', '--quiet', '-m', 'first')

        return $Repository
    }

    # The lines the index holds for the file
    function Get-StagedLines {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Repository,
            [Parameter(Position = 1)][String]$Path = 'some folder/file.txt'
        )

        return @(Invoke-Git $Repository @('show', ":$Path"))
    }

    Set-Variable -Option Constant TestPath ([String]'some folder/file.txt')
    Set-Variable -Option Constant TwoChanges ([Hashtable]@{ 2 = 'second'; 28 = 'twenty-eighth' })
}

Describe 'Split-Diff' {
    It 'Should tell the file header from the hunks' {
        Set-Variable -Option Constant Diff ([String]"diff --git a/f b/f`nindex 1..2 100644`n--- a/f`n+++ b/f`n@@ -1,2 +1,2 @@`n-a`n+b`n c`n@@ -9 +9 @@ function`n-x`n+y`n")

        Set-Variable -Option Constant Parts ([Hashtable](Split-Diff $Diff))

        $Parts.Header | Should -BeExactly "diff --git a/f b/f`nindex 1..2 100644`n--- a/f`n+++ b/f`n"
        $Parts.Hunks.Count | Should -Be 2
        $Parts.Hunks[0] | Should -BeExactly "@@ -1,2 +1,2 @@`n-a`n+b`n c`n"
        $Parts.Hunks[1] | Should -BeExactly "@@ -9 +9 @@ function`n-x`n+y`n"
    }

    It 'Should keep the note about a missing final line break in its hunk' {
        Set-Variable -Option Constant Parts ([Hashtable](Split-Diff "--- a/f`n+++ b/f`n@@ -1 +1 @@`n-a`n+b`n\ No newline at end of file`n"))

        $Parts.Hunks.Count | Should -Be 1
        $Parts.Hunks[0] | Should -BeExactly "@@ -1 +1 @@`n-a`n+b`n\ No newline at end of file`n"
    }

    It 'Should find no hunks in <Name>' -ForEach @(
        @{ Name = 'an empty diff'; Diff = '' }
        @{ Name = 'a change of mode alone'; Diff = "diff --git a/f b/f`nold mode 100644`nnew mode 100755`n" }
    ) {
        Set-Variable -Option Constant Parts ([Hashtable](Split-Diff $Diff))

        $Parts.Hunks.Count | Should -Be 0
        $Parts.Header | Should -BeExactly $Diff
    }
}

Describe 'Show-Hunks' {
    BeforeAll {
        Set-Variable -Option Constant Repository ([String](New-TestRepository 'show'))
    }

    It 'Should number the hunks of the unstaged changes' {
        Set-TestFile (Join-Path $Repository $TestPath) (Get-TestText $TwoChanges)

        Set-Variable -Option Constant Output ([String[]]@(Show-Hunks $Repository $TestPath))

        @($Output | Where-Object { $_ -like '=== hunk*' }) | Should -Be @('=== hunk 1 of 2 ===', '=== hunk 2 of 2 ===')
        $Output[1] | Should -Match '(?s)^@@ .*\n-line 2\n\+second\n'
        $Output[3] | Should -Match '(?s)^@@ .*\n-line 28\n\+twenty-eighth\n'
        $Output[3] | Should -Not -Match '\n$'
    }

    It 'Should show a character outside ASCII as the file has it' {
        Set-Variable -Option Constant Accented ([String]"caf$([Char]0x00E9)")
        Set-TestFile (Join-Path $Repository $TestPath) (Get-TestText @{ 2 = $Accented })

        (@(Show-Hunks $Repository $TestPath) -join "`n") | Should -Match ([Regex]::Escape("+$Accented"))
    }

    It 'Should refuse a file without unstaged changes' {
        Set-TestFile (Join-Path $Repository $TestPath) (Get-TestText)

        { Show-Hunks $Repository $TestPath } | Should -Throw '*has no unstaged hunks*'
    }

    It 'Should refuse a new file, which git does not compare' {
        Set-TestFile (Join-Path $Repository 'new.txt') "new`n"

        { Show-Hunks $Repository 'new.txt' } | Should -Throw '*has no unstaged hunks*'
    }

    It 'Should refuse a folder with two changed files' {
        Set-TestFile (Join-Path $Repository 'second.txt') "one`n"
        $Null = Invoke-Git $Repository @('add', '--', 'second.txt')
        Set-TestFile (Join-Path $Repository 'second.txt') "two`n"
        Set-TestFile (Join-Path $Repository $TestPath) (Get-TestText $TwoChanges)

        { Show-Hunks $Repository '.' } | Should -Throw '*more than one changed file*'
    }

    It 'Should throw what git says where there is no repository' {
        Set-Variable -Option Constant Outside ([String](Join-Path $TestDrive 'no repository'))
        $Null = New-Item -ItemType Directory -Force $Outside

        { Show-Hunks $Outside 'file.txt' } | Should -Throw 'git diff failed:*'
    }
}

Describe 'Add-Hunks' {
    It 'Should stage the picked hunk alone, and leave the working tree as it is' {
        Set-Variable -Option Constant Repository ([String](New-TestRepository 'stage-one'))
        Set-Variable -Option Constant Text ([String](Get-TestText $TwoChanges))
        Set-TestFile (Join-Path $Repository $TestPath) $Text

        Add-Hunks -Repository $Repository -Path $TestPath -Picked @('2') | Should -BeExactly "Staged hunk 2 of $TestPath"

        Set-Variable -Option Constant Staged ([String[]](Get-StagedLines $Repository))
        $Staged[1] | Should -BeExactly 'line 2'
        $Staged[27] | Should -BeExactly 'twenty-eighth'
        [IO.File]::ReadAllText((Join-Path $Repository $TestPath)) | Should -BeExactly $Text

        # What is left is the first change, now the only hunk
        Set-Variable -Option Constant Left ([String[]]@(Show-Hunks $Repository $TestPath))
        $Left[0] | Should -BeExactly '=== hunk 1 of 1 ==='
        $Left[1] | Should -Match '\+second'
    }

    It 'Should stage several hunks at once, in whatever order and however often they are named' {
        Set-Variable -Option Constant Repository ([String](New-TestRepository 'stage-all'))
        Set-TestFile (Join-Path $Repository $TestPath) (Get-TestText @{ 2 = 'second'; 15 = 'fifteenth'; 28 = 'twenty-eighth' })

        Add-Hunks -Repository $Repository -Path $TestPath -Picked @('3', '1', '3') | Should -BeExactly "Staged hunk 1, 3 of $TestPath"

        Set-Variable -Option Constant Staged ([String[]](Get-StagedLines $Repository))
        $Staged[1] | Should -BeExactly 'second'
        $Staged[14] | Should -BeExactly 'line 15'
        $Staged[27] | Should -BeExactly 'twenty-eighth'
    }

    It 'Should stage a file with <Name> byte for byte' -ForEach @(
        @{ Name = 'CR LF line endings'; LineEnding = "`r`n"; Changed = @{ 2 = 'second'; 28 = 'twenty-eighth' } }
        @{ Name = 'characters outside ASCII'; LineEnding = "`n"; Changed = @{ 2 = "caf$([Char]0x00E9) $([Char]0x0416)"; 28 = "$([Char]0x26A0)" } }
    ) {
        Set-Variable -Option Constant Repository ([String](New-TestRepository "stage-bytes-$($LineEnding.Length)-$($Changed[28].Length)" $LineEnding))
        Set-TestFile (Join-Path $Repository $TestPath) (Get-TestText $Changed $LineEnding)

        $Null = Add-Hunks -Repository $Repository -Path $TestPath -Picked @('2')
        $Null = Add-Hunks -Repository $Repository -Path $TestPath -Picked @('1')

        # With every hunk staged, the index holds the working file: 'git diff --quiet' fails on any difference
        { Invoke-Git $Repository @('diff', '--quiet', '--', $TestPath) } | Should -Not -Throw
    }

    It 'Should stage a change of a file without a final line break' {
        Set-Variable -Option Constant Repository ([String](New-TestRepository 'stage-no-line-break'))
        Set-TestFile (Join-Path $Repository $TestPath) (Get-TestText @{ 30 = 'thirtieth' }).TrimEnd("`n")

        $Null = Add-Hunks -Repository $Repository -Path $TestPath -Picked @('1')

        { Invoke-Git $Repository @('diff', '--quiet', '--', $TestPath) } | Should -Not -Throw
    }

    It 'Should refuse <Name>, and stage nothing' -ForEach @(
        @{ Name = 'a number past the last hunk'; Picked = @('1', '3'); Message = "*'3' is not a hunk*from 1 to 2*" }
        @{ Name = 'a number below one'; Picked = @('0'); Message = "*'0' is not a hunk*" }
        @{ Name = 'something that is not a number'; Picked = @('first'); Message = "*'first' is not a hunk*" }
        @{ Name = 'no number at all'; Picked = @(); Message = '*Name the hunks*1 to 2*' }
    ) {
        Set-Variable -Option Constant Repository ([String](New-TestRepository "refuse-$($Picked -join '-')"))
        Set-TestFile (Join-Path $Repository $TestPath) (Get-TestText $TwoChanges)

        { Add-Hunks -Repository $Repository -Path $TestPath -Picked $Picked } | Should -Throw $Message

        { Invoke-Git $Repository @('diff', '--cached', '--quiet') } | Should -Not -Throw
    }
}

Describe 'Set-IndexContent' {
    BeforeAll {
        Set-Variable -Option Constant Repository ([String](New-TestRepository 'content'))
        Set-Variable -Option Constant Intermediate ([String](Join-Path $TestDrive 'intermediate.txt'))
    }

    It 'Should stage the content it is given for a file, and leave the working tree as it is' {
        # Lines 2 and 3 are one hunk: the commit takes the first of them only
        Set-Variable -Option Constant Text ([String](Get-TestText @{ 2 = 'second'; 3 = 'third' }))
        Set-TestFile (Join-Path $Repository $TestPath) $Text
        Set-TestFile $Intermediate (Get-TestText @{ 2 = 'second' })

        Set-IndexContent -Repository $Repository -Path 'some folder\file.txt' -File $Intermediate | Should -BeLike "Staged the content of * as $TestPath"

        Set-Variable -Option Constant Staged ([String[]](Get-StagedLines $Repository))
        $Staged[1] | Should -BeExactly 'second'
        $Staged[2] | Should -BeExactly 'line 3'
        [IO.File]::ReadAllText((Join-Path $Repository $TestPath)) | Should -BeExactly $Text

        # The rest is still to come, as the one hunk left
        (@(Show-Hunks $Repository $TestPath) -join "`n") | Should -Match '(?s)^=== hunk 1 of 1 ===.*-line 3\n\+third'
    }

    It 'Should keep the mode the file has' {
        @(Invoke-Git $Repository @('ls-files', '--stage', '--', $TestPath))[0] | Should -Match '^100644 '
    }

    It 'Should add a file that is new to the index' {
        Set-TestFile $Intermediate "new`n"

        $Null = Set-IndexContent -Repository $Repository -Path './added.txt' -File $Intermediate

        @(Invoke-Git $Repository @('ls-files', '--stage', '--', 'added.txt'))[0] | Should -Match '^100644 [0-9a-f]+ 0\s+added\.txt$'
        Get-StagedLines $Repository 'added.txt' | Should -Be @('new')
    }

    It 'Should refuse a content file that does not exist' {
        { Set-IndexContent -Repository $Repository -Path $TestPath -File (Join-Path $TestDrive 'missing.txt') } | Should -Throw '*There is no file*'
    }

    It 'Should refuse a folder' {
        { Set-IndexContent -Repository $Repository -Path '.' -File $Intermediate } | Should -Throw '*more than one file*'
    }
}

Describe 'Add-GitHunk.ps1' {
    It 'Should print how it is used and fail, given <Name>' -ForEach @(
        @{ Name = 'no command'; Arguments = @() }
        @{ Name = 'a command it does not have'; Arguments = @('unstage', 'file.txt') }
        @{ Name = 'hunks to list'; Arguments = @('list', 'file.txt', '1') }
        @{ Name = 'no hunks to stage'; Arguments = @('stage', 'file.txt') }
        @{ Name = 'no content file'; Arguments = @('content', 'file.txt') }
    ) {
        Set-Variable -Option Constant Engine ([String](Get-Process -Id $PID).Path)
        Set-Variable -Option Constant Script ([String]$PSCommandPath.Replace('.Tests.ps1', '.ps1'))

        Set-Variable -Option Constant Output ([String](& $Engine -NoProfile -ExecutionPolicy Bypass -File $Script @Arguments | Out-String))

        $LASTEXITCODE | Should -Be 1
        $Output | Should -Match '^Usage: Add-GitHunk\.ps1 list <path>'
    }
}
