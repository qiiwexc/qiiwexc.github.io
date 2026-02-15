BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestName ([String]'TEST_NAME')
    Set-Variable -Option Constant TestStyle ([Windows.Style](New-Object Windows.Style))
}

Describe 'New-CheckBox' {
    BeforeEach {
        $script:PREVIOUS_BUTTON = $Null
        $script:PREVIOUS_LABEL_OR_CHECKBOX = $Null
        $script:CENTERED_CHECKBOX_GROUP = $Null

        $script:CURRENT_GROUP = New-Object Windows.Controls.StackPanel
        $script:FORM = [PSCustomObject]@{}
        $script:FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($key) return $TestStyle }
    }

    It 'Should create a new checkbox' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBox $TestText $TestName))

        $Result.Content | Should -BeExactly $TestText
        $Result.Tag | Should -BeExactly $TestName
        $Result.IsChecked | Should -BeFalse
        $Result.IsEnabled | Should -BeTrue
        $Result.Style | Should -BeExactly $TestStyle
        $Result.Margin.Left | Should -BeExactly 10
        $Result.Margin.Top | Should -BeExactly 4
        $Result.Margin.Bottom | Should -BeExactly 4

        $script:CURRENT_GROUP.Children.Count | Should -BeExactly 1
        $script:PREVIOUS_LABEL_OR_CHECKBOX | Should -BeExactly $Result
        $script:PREVIOUS_BUTTON | Should -BeNullOrEmpty
    }

    It 'Should create a disabled checked checkbox' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBox $TestText $TestName -Disabled -Checked))

        $Result.IsChecked | Should -BeTrue
        $Result.IsEnabled | Should -BeFalse
    }

    It 'Should add to CENTERED_CHECKBOX_GROUP when set' {
        $script:CENTERED_CHECKBOX_GROUP = New-Object Windows.Controls.StackPanel

        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBox $TestText $TestName))

        $Result.Margin.Left | Should -BeExactly 0
        $script:CENTERED_CHECKBOX_GROUP.Children.Count | Should -BeExactly 1
        $script:CURRENT_GROUP.Children.Count | Should -BeExactly 0
    }
}
