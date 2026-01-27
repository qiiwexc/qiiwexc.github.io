BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestUrl ([String]'TEST_URL')
}

Describe 'Open-InBrowser' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Start-Process {}
        Mock Out-Failure {}
    }

    It 'Should open URL in the browser' {
        Open-InBrowser $TestUrl

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestUrl }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        Open-InBrowser $TestUrl

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
    }
}
