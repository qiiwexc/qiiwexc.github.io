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
        $script:LayoutContext = @{
            CurrentGroup            = $Null
            PreviousButton          = @{}
            PreviousLabelOrCheckbox = @{}
            CenteredCheckboxGroup   = @{}
            CurrentTab              = New-Object Windows.Controls.WrapPanel
        }
    }

    It 'Should create a new card' {
        New-Card $TestText

        $script:LayoutContext.CurrentTab.Children.Count | Should -BeExactly 1

        $script:LayoutContext.PreviousButton | Should -BeNullOrEmpty
        $script:LayoutContext.PreviousLabelOrCheckbox | Should -BeNullOrEmpty
        $script:LayoutContext.CenteredCheckboxGroup | Should -BeNullOrEmpty

        $script:LayoutContext.CurrentGroup | Should -Not -BeNullOrEmpty
        $script:LayoutContext.CurrentGroup | Should -BeOfType [Windows.Controls.StackPanel]

        Set-Variable -Option Constant CardBorder ([Windows.Controls.Border]$script:LayoutContext.CurrentTab.Children[0])
        $CardBorder.CornerRadius.TopLeft | Should -BeExactly 4
        $CardBorder.Padding.Left | Should -BeExactly 16

        Set-Variable -Option Constant HeaderText ([Windows.Controls.TextBlock]$script:LayoutContext.CurrentGroup.Children[0])
        $HeaderText.Text | Should -BeExactly $TestText
        $HeaderText.FontWeight | Should -BeExactly ([Windows.FontWeights]::Bold)
        $HeaderText.FontSize | Should -BeExactly $FONT_SIZE_HEADER
    }

    It 'Should add multiple cards' {
        New-Card 'First'
        New-Card 'Second'

        $script:LayoutContext.CurrentTab.Children.Count | Should -BeExactly 2
    }
}
