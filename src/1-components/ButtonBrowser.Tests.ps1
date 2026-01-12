BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$(Split-Path $PSCommandPath -Parent)\Button.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Label.ps1"

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestFunction ([ScriptBlock] { TestFunctionContent: 'TEST_FUNCTION_CONTENT' })

    Set-Variable -Option Constant LabelText ([String]'LABEL_TEXT')
}

Describe 'New-ButtonBrowser' {
    BeforeEach {
        Mock New-Button {}
        Mock New-Label {}
    }

    It 'Should create a button with a label' {
        New-ButtonBrowser $TestText $TestFunction

        Should -Invoke New-Button -Exactly 1
        Should -Invoke New-Button -Exactly 1 -ParameterFilter {
            $Text -eq $TestText -and
            $Function -eq $TestFunction
        }
        Should -Invoke New-Label -Exactly 1
        Should -Invoke New-Label -Exactly 1 -ParameterFilter { $Text -eq 'Open in a browser' }
    }
}
