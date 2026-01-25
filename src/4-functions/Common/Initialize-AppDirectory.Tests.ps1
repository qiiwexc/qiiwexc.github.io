BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\New-Directory.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')
}

Describe 'Initialize-AppDirectory' {
    BeforeEach {
        Mock New-Directory {}
    }

    It 'Should create the application directory' {
        Initialize-AppDirectory

        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $PATH_APP_DIR }
    }

    It 'Should handle New-Directory failure' {
        Mock New-Directory { throw $TestException }

        { Initialize-AppDirectory } | Should -Throw $TestException

        Should -Invoke New-Directory -Exactly 1
    }
}
