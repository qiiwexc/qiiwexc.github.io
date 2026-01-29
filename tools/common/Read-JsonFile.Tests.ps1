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
        Set-Variable -Option Constant Result ([PSObject](Read-JsonFile $TestPath))

        $Result.TEST_KEY | Should -BeExactly 'TEST_VALUE'

        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestPath }
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { Read-JsonFile $TestPath } | Should -Throw $TestException

        Should -Invoke Read-TextFile -Exactly 1
    }

    It 'Should throw on invalid JSON content' {
        Mock Read-TextFile { return 'not valid json {' }

        { Read-JsonFile $TestPath } | Should -Throw

        Should -Invoke Read-TextFile -Exactly 1
    }

    It 'Should handle empty JSON object' {
        Mock Read-TextFile { return '{}' }

        Read-JsonFile $TestPath | Should -BeNullOrEmpty

        Should -Invoke Read-TextFile -Exactly 1
    }

    It 'Should handle JSON array' {
        Mock Read-TextFile { return '[{"key": "value1"}, {"key": "value2"}]' }

        Set-Variable -Option Constant Result ([PSObject[]](Read-JsonFile $TestPath))

        $Result.Count | Should -Be 2
        $Result[0].key | Should -BeExactly 'value1'
        $Result[1].key | Should -BeExactly 'value2'

        Should -Invoke Read-TextFile -Exactly 1
    }
}
