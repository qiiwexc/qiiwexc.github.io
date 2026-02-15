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
        $script:PREVIOUS_LABEL_OR_CHECKBOX = $Null
        $script:PREVIOUS_BUTTON = $Null
        $script:CENTERED_CHECKBOX_GROUP = @{}

        $script:CURRENT_GROUP = New-Object Windows.Controls.StackPanel
    }

    It 'Should create a new label' {
        New-Label $TestText

        $script:CURRENT_GROUP.Children.Count | Should -BeExactly 1

        $script:PREVIOUS_LABEL_OR_CHECKBOX | Should -Not -BeNullOrEmpty
        $script:PREVIOUS_LABEL_OR_CHECKBOX.Text | Should -BeExactly $TestText
        $script:PREVIOUS_LABEL_OR_CHECKBOX.FontSize | Should -BeExactly $FONT_SIZE_NORMAL
        $script:PREVIOUS_LABEL_OR_CHECKBOX.Opacity | Should -BeExactly 0.7
        $script:PREVIOUS_LABEL_OR_CHECKBOX.Margin.Left | Should -BeExactly 20

        $script:PREVIOUS_BUTTON | Should -BeNullOrEmpty
        $script:CENTERED_CHECKBOX_GROUP | Should -BeNullOrEmpty
    }

    It 'Should create a centered label' {
        New-Label $TestText -Centered

        $script:PREVIOUS_LABEL_OR_CHECKBOX.HorizontalAlignment | Should -BeExactly ([Windows.HorizontalAlignment]::Center)
        $script:PREVIOUS_LABEL_OR_CHECKBOX.Margin.Left | Should -BeExactly 0
    }
}
