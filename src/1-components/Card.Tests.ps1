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
        $script:CURRENT_GROUP = $Null
        $script:PREVIOUS_BUTTON = @{}
        $script:PREVIOUS_LABEL_OR_CHECKBOX = @{}
        $script:CENTERED_CHECKBOX_GROUP = @{}

        $script:CURRENT_TAB = New-Object Windows.Controls.WrapPanel
    }

    It 'Should create a new card' {
        New-Card $TestText

        $script:CURRENT_TAB.Children.Count | Should -BeExactly 1

        $script:PREVIOUS_BUTTON | Should -BeNullOrEmpty
        $script:PREVIOUS_LABEL_OR_CHECKBOX | Should -BeNullOrEmpty
        $script:CENTERED_CHECKBOX_GROUP | Should -BeNullOrEmpty

        $script:CURRENT_GROUP | Should -Not -BeNullOrEmpty
        $script:CURRENT_GROUP | Should -BeOfType [Windows.Controls.StackPanel]

        Set-Variable -Option Constant CardBorder ([Windows.Controls.Border]$script:CURRENT_TAB.Children[0])
        $CardBorder.CornerRadius.TopLeft | Should -BeExactly 4
        $CardBorder.Padding.Left | Should -BeExactly 16

        Set-Variable -Option Constant HeaderText ([Windows.Controls.TextBlock]$script:CURRENT_GROUP.Children[0])
        $HeaderText.Text | Should -BeExactly $TestText
        $HeaderText.FontWeight | Should -BeExactly ([Windows.FontWeights]::Bold)
        $HeaderText.FontSize | Should -BeExactly $FONT_SIZE_HEADER
    }

    It 'Should add multiple cards' {
        New-Card 'First'
        New-Card 'Second'

        $script:CURRENT_TAB.Children.Count | Should -BeExactly 2
    }
}
