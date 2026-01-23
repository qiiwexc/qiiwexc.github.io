BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Remove-Directory.ps1'
    . '.\src\4-functions\Common\Remove-File.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_TEMP_DIR ([String]'TEST_TEMP_DIR')
    Set-Variable -Option Constant PATH_WINUTIL ([String]'TEST_WINUTIL')
    Set-Variable -Option Constant PATH_OOSHUTUP10 ([String]'TEST_OOSHUTUP10')
    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_APP_DIR')
    Set-Variable -Option Constant OLD_WINDOW_TITLE ([String]'TEST_OLD_WINDOW_TITLE')
}

Describe 'Reset-State' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Remove-Directory {}
        Mock Remove-File {}
        Mock Write-Host {}
    }

    It 'Should clean up files on exit without update' {
        Reset-State

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Remove-Directory -Exactly 3
        Should -Invoke Remove-Directory -Exactly 1 -ParameterFilter {
            $DirectoryPath -eq $PATH_WINUTIL -and
            $Silent -eq $True
        }
        Should -Invoke Remove-Directory -Exactly 1 -ParameterFilter {
            $DirectoryPath -eq $PATH_OOSHUTUP10 -and
            $Silent -eq $True
        }
        Should -Invoke Remove-Directory -Exactly 1 -ParameterFilter {
            $DirectoryPath -eq $PATH_APP_DIR -and
            $Silent -eq $True
        }
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter {
            $FilePath -eq "$PATH_TEMP_DIR\qiiwexc.ps1" -and
            $Silent -eq $True
        }
        Should -Invoke Write-Host -Exactly 1
    }

    It 'Should clean up files on exit with update' {
        Reset-State -Update

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Remove-Directory -Exactly 3
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Write-Host -Exactly 1
    }

    It 'Should handle Remove-Directory failure' {
        Mock Remove-Directory { throw $TestException }

        { Reset-State } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Write-Host -Exactly 0
    }

    It 'Should handle Remove-File failure' {
        Mock Remove-File { throw $TestException }

        { Reset-State } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Remove-Directory -Exactly 3
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Write-Host -Exactly 0
    }
}

Describe 'Exit-App' {
    BeforeAll {
        function Close {}
    }

    BeforeEach {
        Mock Write-LogInfo {}
        Mock Reset-State {}
        Mock Close {}

        [Windows.Forms.Form]$FORM = New-MockObject -Type Windows.Forms.Form -Methods @{ Close = { Close } }
    }

    It 'Should exit the application without update' {
        Exit-App

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Reset-State -Exactly 1
        Should -Invoke Reset-State -Exactly 1 -ParameterFilter { $Update -eq $False }
        Should -Invoke Close -Exactly 1
    }

    It 'Should exit the application with update' {
        Exit-App -Update

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Reset-State -Exactly 1
        Should -Invoke Reset-State -Exactly 1 -ParameterFilter { $Update -eq $True }
        Should -Invoke Close -Exactly 1
    }

    It 'Should handle Reset-State failure' {
        Mock Reset-State { throw $TestException }

        { Exit-App } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Reset-State -Exactly 1
        Should -Invoke Close -Exactly 0
    }
}
