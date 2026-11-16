BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')
    Set-Variable -Option Constant TestContent ([String]"TEST_CONTENT_LINE1`r`nTEST_CONTENT_LINE2`r`n`r`n ")
}

Describe 'Read-TextFile' {
    BeforeAll {
        Mock Get-Content { return $TestContent }
    }

    It 'Should read text file' {
        Read-TextFile $TestPath | Should -BeExactly $TestContent

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Encoding -eq 'UTF8' -and
            $Raw -eq $True
        }
    }

    It 'Should read text file as list' {
        Read-TextFile $TestPath -AsList | Should -BeExactly $TestContent

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Encoding -eq 'UTF8' -and
            $Raw -eq $False
        }
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { Read-TextFile $TestPath | Should -BeExactly $TestContent } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
    }

    It 'Should return empty string for empty file' {
        Mock Get-Content { return '' }

        Read-TextFile $TestPath | Should -BeExactly ''

        Should -Invoke Get-Content -Exactly 1
    }

    It 'Should handle file with only whitespace' {
        Mock Get-Content { return "   `r`n  " }

        Read-TextFile $TestPath | Should -BeExactly "   `r`n  "

        Should -Invoke Get-Content -Exactly 1
    }

    It 'Should throw when a line holds the replacement character' {
        Mock Get-Content { return @('LINE1', "LINE$([Char]0xFFFD)2") }

        { Read-TextFile $TestPath -AsList } | Should -Throw "'$TestPath' is not UTF-8*"
    }
}

Describe 'Read-TextFile on a file' {
    It 'Should read UTF-8, with or without a byte order mark' {
        Set-Variable -Option Constant Text ([String]"$([Char]0x2014) $([Char]0x041C)")
        [IO.File]::WriteAllText("$TestDrive\bom.txt", $Text, [Text.UTF8Encoding]::new($True))
        [IO.File]::WriteAllText("$TestDrive\no-bom.txt", $Text, [Text.UTF8Encoding]::new($False))

        Read-TextFile "$TestDrive\bom.txt" | Should -BeExactly $Text
        Read-TextFile "$TestDrive\no-bom.txt" | Should -BeExactly $Text
    }

    It 'Should throw on a file saved in an ANSI code page' {
        # An em dash in code page 1252
        [IO.File]::WriteAllBytes("$TestDrive\ansi.txt", [Byte[]]@(0x61, 0x97, 0x62))

        { Read-TextFile "$TestDrive\ansi.txt" } | Should -Throw '*is not UTF-8*'
    }
}
