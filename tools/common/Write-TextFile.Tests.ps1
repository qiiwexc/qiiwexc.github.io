BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')
    Set-Variable -Option Constant TestContent ([String[]]@("TEST_CONTENT_LINE1`r`nTEST_CONTENT_LINE2`r`n`r`n "))
}

Describe 'Write-TextFile' {
    BeforeEach {
        Mock Set-Content {}
        Mock New-Item {}
    }

    It 'Should write text file' {
        Write-TextFile $TestPath $TestContent

        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Value -eq $TestContent -and
            $NoNewline -eq $False
        }
        Should -Invoke New-Item -Exactly 0
    }

    It 'Should add a new line and write text file' {
        Write-TextFile $TestPath $TestContent -NoNewline

        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Value -eq $TestContent -and
            $NoNewline -eq $True
        }
        Should -Invoke New-Item -Exactly 0
    }

    It 'Should normalize and write text file' {
        Write-TextFile $TestPath $TestContent -Normalize

        Should -Invoke Set-Content -Exactly 0
        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Value -eq "TEST_CONTENT_LINE1`nTEST_CONTENT_LINE2`n"
        }
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Write-TextFile $TestPath $TestContent } | Should -Throw $TestException

        Should -Invoke Set-Content -Exactly 1
        Should -Invoke New-Item -Exactly 0
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        { Write-TextFile $TestPath $TestContent -Normalize } | Should -Throw $TestException

        Should -Invoke Set-Content -Exactly 0
        Should -Invoke New-Item -Exactly 1
    }
}
