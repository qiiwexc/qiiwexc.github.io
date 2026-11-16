BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    # Latvian, a dash, Cyrillic and the euro sign, which no single ANSI code page holds. From their codes, so that this
    # file stays ASCII
    Set-Variable -Option Constant TestText ([String]"R$([Char]0x012B)ga $([Char]0x2013) $([Char]0x041C)$([Char]0x043E)$([Char]0x0441)$([Char]0x043A)$([Char]0x0432)$([Char]0x0430) $([Char]0x20AC)`nline 2")
}

Describe 'Write-Utf8File' {
    It 'Should write UTF-8 without a byte order mark' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\utf8.txt")

        Write-Utf8File $TestFile $TestText

        Set-Variable -Option Constant Bytes ([Byte[]][IO.File]::ReadAllBytes($TestFile))
        $Bytes[0..2] | Should -Not -Be @(0xEF, 0xBB, 0xBF)
        [Text.UTF8Encoding]::new($False, $True).GetString($Bytes) | Should -BeExactly $TestText
    }

    It 'Should add no line ending of its own' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\ascii.txt")

        Write-Utf8File $TestFile 'TEST'

        [IO.File]::ReadAllBytes($TestFile) | Should -Be ([Byte[]][Char[]]'TEST')
    }

    It 'Should replace what the file held' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\replaced.txt")
        [IO.File]::WriteAllText($TestFile, 'A much longer previous content')

        Write-Utf8File $TestFile 'NEW'

        [IO.File]::ReadAllText($TestFile) | Should -BeExactly 'NEW'
    }

    It 'Should write to a path with wildcard characters as it is' {
        Set-Variable -Option Constant TestFile ([String]"$TestDrive\[brackets].txt")

        Write-Utf8File $TestFile 'TEST'

        [IO.File]::ReadAllText($TestFile) | Should -BeExactly 'TEST'
    }

    It 'Should throw when the file cannot be written' {
        { Write-Utf8File "$TestDrive\missing\file.txt" 'TEST' } | Should -Throw
    }
}
