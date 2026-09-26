#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Button.ps1"
    . "$PSScriptRoot\Label.ps1"

    Add-Type -AssemblyName PresentationFramework

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestFunction ([ScriptBlock] { TestFunctionContent: 'TEST_FUNCTION_CONTENT' })
    Set-Variable -Option Constant TestParent ([Windows.Controls.StackPanel]::new())
    Set-Variable -Option Constant TestButton ([Windows.Controls.Button]::new())
}

Describe 'New-ButtonBrowser' {
    BeforeAll {
        Mock New-Button { return $TestButton }
        Mock New-Label {}
    }

    It 'Should create a button with a label, and return the button' {
        New-ButtonBrowser $TestParent $TestText $TestFunction | Should -BeExactly $TestButton

        Should -Invoke New-Button -Exactly 1
        Should -Invoke New-Button -Exactly 1 -ParameterFilter {
            $Parent -eq $TestParent -and
            $Text -eq $TestText -and
            $Function -eq $TestFunction -and
            $Spaced -eq $False
        }
        Should -Invoke New-Label -Exactly 1
        Should -Invoke New-Label -Exactly 1 -ParameterFilter {
            $Parent -eq $TestParent -and
            $Text -eq 'Open in a browser' -and
            $Centered -eq $True
        }
    }

    It 'Should pass the spacing on to the button' {
        New-ButtonBrowser $TestParent $TestText $TestFunction -Spaced

        Should -Invoke New-Button -Exactly 1 -ParameterFilter { $Spaced -eq $True }
    }
}
