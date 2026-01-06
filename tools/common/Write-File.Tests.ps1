BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')
    Set-Variable -Option Constant TestContent ([String]"TEST_CONTENT_LINE1`r`nTEST_CONTENT_LINE2`r`n`r`n ")
}

Describe 'Write-File' {
    BeforeEach {
        Mock New-Item {}
    }

    It 'Should write version to file' {
        Write-File $TestPath $TestContent

        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Value -eq "TEST_CONTENT_LINE1`nTEST_CONTENT_LINE2`n"
        }
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        { Write-File $TestPath $TestContent } | Should -Throw

        Should -Invoke New-Item -Exactly 1
    }
}
