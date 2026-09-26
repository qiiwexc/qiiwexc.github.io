#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\CheckBox.ps1"

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestStyle ([Windows.Style](New-Object Windows.Style))

    Set-Variable -Option Constant FORM ([PSCustomObject]@{})
    $FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($Key) return $TestStyle }
}

Describe 'New-CheckBoxRunAfterDownload' {
    BeforeEach {
        Set-Variable -Option Constant Parent ([Windows.Controls.StackPanel]::new())
    }

    It 'Should add a centred group holding the checkbox to its parent' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBoxRunAfterDownload $Parent -Disabled))

        $Result.Content | Should -BeExactly 'Start after download'
        $Result.IsEnabled | Should -BeFalse
        $Result.IsChecked | Should -BeFalse
        $Result.Margin | Should -Be ([Windows.Thickness]::new(0, 0, 0, 2))

        $Parent.Children.Count | Should -BeExactly 1
        Set-Variable -Option Constant Group ([Windows.Controls.StackPanel]$Parent.Children[0])
        $Group.HorizontalAlignment | Should -BeExactly ([Windows.HorizontalAlignment]::Center)
        $Group.Margin | Should -Be ([Windows.Thickness]::new(0, 3, 0, 3))
        $Group.Children.Count | Should -BeExactly 1
        $Result.Parent | Should -BeExactly $Group
    }

    It 'Should create a checked checkbox' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBoxRunAfterDownload $Parent -Checked))

        $Result.IsChecked | Should -BeTrue
        $Result.IsEnabled | Should -BeTrue
    }
}
