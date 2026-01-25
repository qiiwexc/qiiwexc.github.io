BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE ([String]'PATH_OFFICE_C2R_CLIENT_EXE')
}

Describe 'Update-MicrosoftOffice' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should update Microsoft Office' {
        Update-MicrosoftOffice

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $PATH_OFFICE_C2R_CLIENT_EXE -and
            $ArgumentList -eq '/update user'
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        Update-MicrosoftOffice

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
