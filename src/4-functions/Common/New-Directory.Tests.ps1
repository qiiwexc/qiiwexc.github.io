BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')
}

Describe 'New-Directory' {
    BeforeEach {
        Mock New-Item {}
    }

    It 'Should create the application directory' {
        New-Directory $TestPath

        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $ItemType -eq 'Directory' -and
            $Force -eq $True
        }
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        { New-Directory $TestPath } | Should -Throw $TestException

        Should -Invoke New-Item -Exactly 1
    }
}
