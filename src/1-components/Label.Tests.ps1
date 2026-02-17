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
        $script:LayoutContext = @{
            PreviousLabelOrCheckbox = $Null
            PreviousButton          = $Null
            CenteredCheckboxGroup   = @{}
            CurrentGroup            = New-Object Windows.Controls.StackPanel
            CurrentTab              = $Null
        }
    }

    It 'Should create a new label' {
        New-Label $TestText

        $script:LayoutContext.CurrentGroup.Children.Count | Should -BeExactly 1

        $script:LayoutContext.PreviousLabelOrCheckbox | Should -Not -BeNullOrEmpty
        $script:LayoutContext.PreviousLabelOrCheckbox.Text | Should -BeExactly $TestText
        $script:LayoutContext.PreviousLabelOrCheckbox.FontSize | Should -BeExactly $FONT_SIZE_NORMAL
        $script:LayoutContext.PreviousLabelOrCheckbox.Opacity | Should -BeExactly 0.7
        $script:LayoutContext.PreviousLabelOrCheckbox.Margin.Left | Should -BeExactly 20

        $script:LayoutContext.PreviousButton | Should -BeNullOrEmpty
        $script:LayoutContext.CenteredCheckboxGroup | Should -BeNullOrEmpty
    }

    It 'Should create a centered label' {
        New-Label $TestText -Centered

        $script:LayoutContext.PreviousLabelOrCheckbox.HorizontalAlignment | Should -BeExactly ([Windows.HorizontalAlignment]::Center)
        $script:LayoutContext.PreviousLabelOrCheckbox.Margin.Left | Should -BeExactly 0
    }
}
