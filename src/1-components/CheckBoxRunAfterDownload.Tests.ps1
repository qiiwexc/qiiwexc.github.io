BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$(Split-Path $PSCommandPath -Parent)\CheckBox.ps1"

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestStyle ([Windows.Style](New-Object Windows.Style))
}

Describe 'New-CheckBoxRunAfterDownload' {
    BeforeEach {
        $script:PREVIOUS_BUTTON = $Null
        $script:PREVIOUS_LABEL_OR_CHECKBOX = $Null
        $script:CENTERED_CHECKBOX_GROUP = $Null

        $script:CURRENT_GROUP = New-Object Windows.Controls.StackPanel
        $script:FORM = [PSCustomObject]@{}
        $script:FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($key) return $TestStyle }
    }

    It 'Should create a centered checkbox with correct parameters' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBoxRunAfterDownload -Disabled))

        $Result.Content | Should -BeExactly 'Start after download'
        $Result.IsEnabled | Should -BeFalse
        $Result.IsChecked | Should -BeFalse
        $Result.Margin.Bottom | Should -BeExactly 2

        $script:CENTERED_CHECKBOX_GROUP | Should -Not -BeNullOrEmpty
        $script:CENTERED_CHECKBOX_GROUP.HorizontalAlignment | Should -BeExactly ([Windows.HorizontalAlignment]::Center)
        $script:CENTERED_CHECKBOX_GROUP.Children.Count | Should -BeExactly 1

        $script:CURRENT_GROUP.Children.Count | Should -BeExactly 1
        $script:PREVIOUS_LABEL_OR_CHECKBOX | Should -BeExactly $Result
    }

    It 'Should create a checked checkbox' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBoxRunAfterDownload -Checked))

        $Result.IsChecked | Should -BeTrue
        $Result.IsEnabled | Should -BeTrue
    }
}
