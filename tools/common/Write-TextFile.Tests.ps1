BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    # An em dash, Cyrillic and the euro sign, which no single ANSI code page holds. From their codes, so that this
    # file stays ASCII
    Set-Variable -Option Constant TestText ([String]"$([Char]0x2014) $([Char]0x041C)$([Char]0x043E)$([Char]0x0441)$([Char]0x043A)$([Char]0x0432)$([Char]0x0430) $([Char]0x20AC)")

    Set-Variable -Option Constant StrictUtf8 ([Text.UTF8Encoding]::new($False, $True))
    Set-Variable -Option Constant Utf8ByteOrderMark ([Byte[]]@(0xEF, 0xBB, 0xBF))
}

Describe 'Write-TextFile' {
    It 'Should write the content as given, in UTF-8 without a byte order mark' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\as-given.txt")

        Write-TextFile $TestFile @("LINE1`r`n$TestText`n", ' ')

        Set-Variable -Option Constant Bytes ([Byte[]][IO.File]::ReadAllBytes($TestFile))
        $Bytes[0..2] | Should -Not -Be $Utf8ByteOrderMark
        $StrictUtf8.GetString($Bytes) | Should -BeExactly "LINE1`r`n$TestText`n "
    }

    It 'Should give a PowerShell script a byte order mark' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\script.ps1")

        Write-TextFile $TestFile "# $TestText"

        Set-Variable -Option Constant Bytes ([Byte[]][IO.File]::ReadAllBytes($TestFile))
        $Bytes[0..2] | Should -Be $Utf8ByteOrderMark
        $StrictUtf8.GetString($Bytes, 3, $Bytes.Count - 3) | Should -BeExactly "# $TestText"
    }

    It 'Should normalise to LF line endings, trimmed, with one at the end' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\normalized.txt")

        Write-TextFile $TestFile "LINE1`r`nLINE2`nLINE3`r`n`r`n " -Normalize

        [IO.File]::ReadAllText($TestFile) | Should -BeExactly "LINE1`nLINE2`nLINE3`n"
    }

    It 'Should normalise to CRLF line endings' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\crlf.txt")

        Write-TextFile $TestFile "LINE1`r`nLINE2`nLINE3`n`n" -Normalize -CrLf

        [IO.File]::ReadAllText($TestFile) | Should -BeExactly "LINE1`r`nLINE2`r`nLINE3`r`n"
    }

    It 'Should replace what the file held' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\replaced.txt")
        [IO.File]::WriteAllText($TestFile, 'A much longer previous content')

        Write-TextFile $TestFile 'NEW'

        [IO.File]::ReadAllText($TestFile) | Should -BeExactly 'NEW'
    }

    It 'Should resolve a PowerShell path and create the missing directory' {
        Write-TextFile 'TestDrive:\missing\file.txt' 'TEST'

        [IO.File]::ReadAllText("$TestDrive\missing\file.txt") | Should -BeExactly 'TEST'
    }

    It 'Should write an empty file' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\empty.txt")

        Write-TextFile $TestFile ''

        [IO.File]::ReadAllBytes($TestFile).Count | Should -Be 0
    }

    It 'Should throw when the file cannot be written' {
        $Null = New-Item -ItemType Directory "$TestDrive\directory"

        { Write-TextFile "$TestDrive\directory" 'TEST' } | Should -Throw
    }
}
