BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')
}

Describe 'Initialize-AppDirectory' {
    BeforeEach {
        Mock New-Item {}
    }

    It 'Should create the application directory' {
        Initialize-AppDirectory

        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter {
            $Path -eq $PATH_APP_DIR -and
            $ItemType -eq 'Directory' -and
            $Force -eq $True
        }
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        { Initialize-AppDirectory } | Should -Throw $TestException

        Should -Invoke New-Item -Exactly 1
    }
}
