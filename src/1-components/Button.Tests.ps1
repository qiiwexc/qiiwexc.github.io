#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestStyle ([Windows.Style](New-Object Windows.Style))

    Set-Variable -Option Constant FORM ([PSCustomObject]@{})
    $FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($Key) return $TestStyle }
}

Describe 'New-Button' {
    BeforeEach {
        Set-Variable -Option Constant Parent ([Windows.Controls.StackPanel]::new())
        $script:Clicked = $False
    }

    It 'Should add a button to its parent' {
        Set-Variable -Option Constant Result ([Windows.Controls.Button](New-Button $Parent $TestText { $script:Clicked = $True }))

        $Parent.Children.Count | Should -BeExactly 1
        $Parent.Children[0] | Should -BeExactly $Result
        $Result.Content | Should -BeExactly $TestText
        $Result.IsEnabled | Should -BeTrue
        $Result.Style | Should -BeExactly $TestStyle
        $Result.Margin | Should -Be ([Windows.Thickness]::new(0))
    }

    It 'Should run its function when clicked' {
        Set-Variable -Option Constant Result ([Windows.Controls.Button](New-Button $Parent $TestText { $script:Clicked = $True }))

        $Result.RaiseEvent([Windows.RoutedEventArgs]::new([Windows.Controls.Primitives.ButtonBase]::ClickEvent))

        $script:Clicked | Should -BeTrue
    }

    It 'Should create a disabled button' {
        (New-Button $Parent $TestText -Disabled).IsEnabled | Should -BeFalse
    }

    It 'Should set a spaced button apart from what comes before it' {
        Set-Variable -Option Constant Result ([Windows.Controls.Button](New-Button $Parent $TestText -Spaced))

        $Result.Margin | Should -Be ([Windows.Thickness]::new(0, 14, 0, 4))
    }
}
