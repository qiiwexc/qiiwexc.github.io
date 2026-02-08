BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE ([String]'PATH_OFFICE_C2R_CLIENT_EXE')
}

Describe 'Update-MicrosoftOffice' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Test-Path { return $True }
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Out-Failure {}

        [String]$OFFICE_INSTALL_TYPE = 'C2R'
    }

    It 'Should update Microsoft Office' {
        Update-MicrosoftOffice

        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $PATH_OFFICE_C2R_CLIENT_EXE }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $PATH_OFFICE_C2R_CLIENT_EXE -and
            $ArgumentList -eq '/update user'
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if not Click-to-Run installation' {
        [String]$OFFICE_INSTALL_TYPE = 'MSI'

        Update-MicrosoftOffice

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-Path -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if executable not found' {
        Mock Test-Path { return $False }

        Update-MicrosoftOffice

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        Update-MicrosoftOffice

        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        Update-MicrosoftOffice

        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
