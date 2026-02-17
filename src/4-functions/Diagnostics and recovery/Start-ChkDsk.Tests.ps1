BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
}

Describe 'Start-ChkDsk' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should start Check Disk' {
        Start-ChkDsk

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'chkdsk' -and
            $ArgumentList -eq 'C:'
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        Start-ChkDsk

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
