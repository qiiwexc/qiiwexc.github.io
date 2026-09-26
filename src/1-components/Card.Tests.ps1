#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant FONT_SIZE_HEADER ([Int]16)
    Set-Variable -Option Constant FONT_NAME ([String]'Segoe UI')
}

Describe 'New-Card' {
    BeforeEach {
        Set-Variable -Option Constant Parent ([Windows.Controls.WrapPanel]::new())
    }

    It 'Should add a card to its parent, and return the panel for its items' {
        Set-Variable -Option Constant Result ([Windows.Controls.StackPanel](New-Card $Parent $TestText))

        $Parent.Children.Count | Should -BeExactly 1

        Set-Variable -Option Constant CardBorder ([Windows.Controls.Border]$Parent.Children[0])
        $CardBorder.CornerRadius.TopLeft | Should -BeExactly 4
        $CardBorder.Padding.Left | Should -BeExactly 16
        $CardBorder.Child | Should -BeExactly $Result

        Set-Variable -Option Constant HeaderText ([Windows.Controls.TextBlock]$Result.Children[0])
        $HeaderText.Text | Should -BeExactly $TestText
        $HeaderText.FontWeight | Should -BeExactly ([Windows.FontWeights]::Bold)
        $HeaderText.FontSize | Should -BeExactly $FONT_SIZE_HEADER
    }

    It 'Should add multiple cards' {
        [Void](New-Card $Parent 'First')
        [Void](New-Card $Parent 'Second')

        $Parent.Children.Count | Should -BeExactly 2
    }
}
