BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Start-FromShell.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestUrl ([String]'https://TEST_URL')
}

Describe 'Open-InBrowser' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Start-FromShell {}
        Mock Out-Failure {}
    }

    It 'Should open URL in the browser through the shell' {
        Open-InBrowser $TestUrl

        Should -Invoke Start-FromShell -Exactly 1
        Should -Invoke Start-FromShell -Exactly 1 -ParameterFilter { $Target -eq $TestUrl }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Start-FromShell failure' {
        Mock Start-FromShell { throw $TestException }

        Open-InBrowser $TestUrl

        Should -Invoke Start-FromShell -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
    }
}
