#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestTag ([String]'TEST_TAG')
    Set-Variable -Option Constant TestStyle ([Windows.Style](New-Object Windows.Style))

    Set-Variable -Option Constant FORM ([PSCustomObject]@{})
    $FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($Key) return $TestStyle }
}

Describe 'New-CheckBox' {
    BeforeEach {
        Set-Variable -Option Constant Parent ([Windows.Controls.StackPanel]::new())
    }

    It 'Should add a checkbox to its parent' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBox $Parent $TestText -Tag $TestTag))

        $Parent.Children.Count | Should -BeExactly 1
        $Parent.Children[0] | Should -BeExactly $Result
        $Result.Content | Should -BeExactly $TestText
        $Result.Tag | Should -BeExactly $TestTag
        $Result.IsChecked | Should -BeFalse
        $Result.IsEnabled | Should -BeTrue
        $Result.Style | Should -BeExactly $TestStyle
        $Result.Margin | Should -Be ([Windows.Thickness]::new(10, 4, 0, 4))
    }

    It 'Should create a disabled checked checkbox' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBox $Parent $TestText -Disabled -Checked))

        $Result.IsChecked | Should -BeTrue
        $Result.IsEnabled | Should -BeFalse
    }

    It 'Should line up with a centred group' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBox $Parent $TestText -Centered))

        $Result.Margin | Should -Be ([Windows.Thickness]::new(0, 4, 0, 4))
    }
}
