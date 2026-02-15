BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    . '.\src\4-functions\Common\Remove-File.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_TEMP_DIR ([String]'TEST_TEMP_DIR')
    Set-Variable -Option Constant ORIGINAL_WINDOW_TITLE ([String]'TEST_ORIGINAL_WINDOW_TITLE')

    Set-Variable -Option Constant WindowTitle ([String]$HOST.UI.RawUI.WindowTitle)
}

AfterAll {
    $HOST.UI.RawUI.WindowTitle = $WindowTitle
}

Describe 'Reset-State' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Remove-File {}
        Mock Write-Host {}
    }

    It 'Should clean up files on exit without update' {
        Reset-State

        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter {
            $FilePath -eq "$PATH_TEMP_DIR\qiiwexc.ps1" -and
            $Silent -eq $True
        }
        Should -Invoke Write-Host -Exactly 1
    }

    It 'Should clean up files on exit with update' {
        Reset-State -Update

        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Write-Host -Exactly 1
    }

    It 'Should handle Remove-File failure' {
        Mock Remove-File { throw $TestException }

        { Reset-State } | Should -Throw $TestException

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

        [Windows.Window]$FORM = New-MockObject -Type Windows.Window -Methods @{ Close = { Close } }
    }

    It 'Should exit the application without update' {
        Exit-App

        Should -Invoke Reset-State -Exactly 1
        Should -Invoke Reset-State -Exactly 1 -ParameterFilter { $Update -eq $False }
        Should -Invoke Close -Exactly 1
    }

    It 'Should exit the application with update' {
        Exit-App -Update

        Should -Invoke Reset-State -Exactly 1
        Should -Invoke Reset-State -Exactly 1 -ParameterFilter { $Update -eq $True }
        Should -Invoke Close -Exactly 1
    }

    It 'Should handle Reset-State failure' {
        Mock Reset-State { throw $TestException }

        { Exit-App } | Should -Throw $TestException

        Should -Invoke Reset-State -Exactly 1
        Should -Invoke Close -Exactly 0
    }
}
