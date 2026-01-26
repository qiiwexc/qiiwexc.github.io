BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Write-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')
    Set-Variable -Option Constant TestContent ([PSObject]@{TEST_KEY = 'TEST_VALUE' })
    Set-Variable -Option Constant TestContentString ([String]"{`r`n    `"TEST_KEY`":  `"TEST_VALUE`"`r`n}")
}

Describe 'Write-JsonFile' {
    BeforeEach {
        Mock Write-TextFile {}
    }

    It 'Should write JSON file' {
        Write-JsonFile $TestPath $TestContent

        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Content -eq $TestContentString -and
            $Normalize -eq $True
        }
    }

    It 'Should handle Write-TextFile failure' {
        Mock Write-TextFile { throw $TestException }

        { Write-JsonFile $TestPath $TestContent } | Should -Throw $TestException

        Should -Invoke Write-TextFile -Exactly 1
    }
}
