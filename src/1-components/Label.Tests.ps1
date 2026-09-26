#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant FONT_SIZE_NORMAL ([Int]12)
    Set-Variable -Option Constant FONT_NAME ([String]'Segoe UI')
}

Describe 'New-Label' {
    BeforeEach {
        Set-Variable -Option Constant Parent ([Windows.Controls.StackPanel]::new())
    }

    It 'Should add a label to its parent' {
        Set-Variable -Option Constant Result ([Windows.Controls.TextBlock](New-Label $Parent $TestText))

        $Parent.Children.Count | Should -BeExactly 1
        $Parent.Children[0] | Should -BeExactly $Result
        $Result.Text | Should -BeExactly $TestText
        $Result.FontSize | Should -BeExactly $FONT_SIZE_NORMAL
        $Result.Opacity | Should -BeExactly 0.7
        $Result.Margin | Should -Be ([Windows.Thickness]::new(20, 0, 0, 4))
    }

    It 'Should create a centered label' {
        Set-Variable -Option Constant Result ([Windows.Controls.TextBlock](New-Label $Parent $TestText -Centered))

        $Result.HorizontalAlignment | Should -BeExactly ([Windows.HorizontalAlignment]::Center)
        $Result.Margin | Should -Be ([Windows.Thickness]::new(0, 0, 0, 4))
    }
}
