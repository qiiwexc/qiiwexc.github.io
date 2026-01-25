BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Read-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')
    Set-Variable -Option Constant TestContent ([String]'{"TEST_KEY":"TEST_VALUE"}')
}

Describe 'Read-JsonFile' {
    BeforeEach {
        Mock Read-TextFile { return $TestContent }
    }

    It 'Should read and parse JSON file' {
        Set-Variable -Option Constant Result ([PSCustomObject](Read-JsonFile $TestPath))

        $Result.TEST_KEY | Should -BeExactly 'TEST_VALUE'

        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestPath }
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { Read-JsonFile $TestPath } | Should -Throw $TestException

        Should -Invoke Read-TextFile -Exactly 1
    }
}
