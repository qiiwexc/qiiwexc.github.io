BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestFunction ([ScriptBlock] { Test = 'Function' })
    Set-Variable -Option Constant TestStyle ([Windows.Style](New-Object Windows.Style))
}

Describe 'New-Button' {
    BeforeEach {
        $script:LayoutContext = @{
            PreviousButton          = $Null
            PreviousLabelOrCheckbox = $Null
            CenteredCheckboxGroup   = $Null
            CurrentGroup            = New-Object Windows.Controls.StackPanel
            CurrentTab              = $Null
        }

        $script:FORM = [PSCustomObject]@{}
        $script:FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($key) return $TestStyle }
    }

    It 'Should create a new button' {
        New-Button $TestText $TestFunction

        $script:LayoutContext.CurrentGroup.Children.Count | Should -BeExactly 1

        $script:LayoutContext.PreviousButton | Should -Not -BeNullOrEmpty
        $script:LayoutContext.PreviousButton.Content | Should -BeExactly $TestText
        $script:LayoutContext.PreviousButton.IsEnabled | Should -BeTrue
        $script:LayoutContext.PreviousButton.Style | Should -BeExactly $TestStyle

        $script:LayoutContext.PreviousLabelOrCheckbox | Should -BeNullOrEmpty
        $script:LayoutContext.CenteredCheckboxGroup | Should -BeNullOrEmpty
    }

    It 'Should create a disabled button' {
        New-Button $TestText $TestFunction -Disabled

        $script:LayoutContext.PreviousButton.IsEnabled | Should -BeFalse
    }

    It 'Should add margin when previous button exists' {
        $script:LayoutContext.PreviousButton = New-Object Windows.Controls.Button

        New-Button $TestText

        $script:LayoutContext.PreviousButton.Margin.Top | Should -BeExactly 14
        $script:LayoutContext.PreviousButton.Margin.Bottom | Should -BeExactly 4
    }

    It 'Should add margin when previous label/checkbox exists' {
        $script:LayoutContext.PreviousLabelOrCheckbox = New-Object Windows.Controls.TextBlock

        New-Button $TestText

        $script:LayoutContext.PreviousButton.Margin.Top | Should -BeExactly 14
        $script:LayoutContext.PreviousButton.Margin.Bottom | Should -BeExactly 4
    }

    It 'Should clear CenteredCheckboxGroup' {
        $script:LayoutContext.CenteredCheckboxGroup = New-Object Windows.Controls.StackPanel

        New-Button $TestText

        $script:LayoutContext.CenteredCheckboxGroup | Should -BeNullOrEmpty
    }
}
