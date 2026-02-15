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
        $script:PREVIOUS_BUTTON = $Null
        $script:PREVIOUS_LABEL_OR_CHECKBOX = $Null
        $script:CENTERED_CHECKBOX_GROUP = $Null

        $script:CURRENT_GROUP = New-Object Windows.Controls.StackPanel
        $script:FORM = [PSCustomObject]@{}
        $script:FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($key) return $TestStyle }
    }

    It 'Should create a new button' {
        New-Button $TestText $TestFunction

        $script:CURRENT_GROUP.Children.Count | Should -BeExactly 1

        $script:PREVIOUS_BUTTON | Should -Not -BeNullOrEmpty
        $script:PREVIOUS_BUTTON.Content | Should -BeExactly $TestText
        $script:PREVIOUS_BUTTON.IsEnabled | Should -BeTrue
        $script:PREVIOUS_BUTTON.Style | Should -BeExactly $TestStyle

        $script:PREVIOUS_LABEL_OR_CHECKBOX | Should -BeNullOrEmpty
        $script:CENTERED_CHECKBOX_GROUP | Should -BeNullOrEmpty
    }

    It 'Should create a disabled button' {
        New-Button $TestText $TestFunction -Disabled

        $script:PREVIOUS_BUTTON.IsEnabled | Should -BeFalse
    }

    It 'Should add margin when previous button exists' {
        $script:PREVIOUS_BUTTON = New-Object Windows.Controls.Button

        New-Button $TestText

        $script:PREVIOUS_BUTTON.Margin.Top | Should -BeExactly 14
        $script:PREVIOUS_BUTTON.Margin.Bottom | Should -BeExactly 4
    }

    It 'Should add margin when previous label/checkbox exists' {
        $script:PREVIOUS_LABEL_OR_CHECKBOX = New-Object Windows.Controls.TextBlock

        New-Button $TestText

        $script:PREVIOUS_BUTTON.Margin.Top | Should -BeExactly 14
        $script:PREVIOUS_BUTTON.Margin.Bottom | Should -BeExactly 4
    }

    It 'Should clear CENTERED_CHECKBOX_GROUP' {
        $script:CENTERED_CHECKBOX_GROUP = New-Object Windows.Controls.StackPanel

        New-Button $TestText

        $script:CENTERED_CHECKBOX_GROUP | Should -BeNullOrEmpty
    }
}
