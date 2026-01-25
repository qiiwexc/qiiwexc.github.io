BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')
    Set-Variable -Option Constant TestContent ([String]"TEST_CONTENT_LINE1`r`nTEST_CONTENT_LINE2`r`n`r`n ")
}

Describe 'Read-TextFile' {
    BeforeEach {
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
}
