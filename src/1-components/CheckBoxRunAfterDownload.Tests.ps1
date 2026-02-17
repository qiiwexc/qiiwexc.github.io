BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$(Split-Path $PSCommandPath -Parent)\CheckBox.ps1"

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestStyle ([Windows.Style](New-Object Windows.Style))
}

Describe 'New-CheckBoxRunAfterDownload' {
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

    It 'Should create a centered checkbox with correct parameters' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBoxRunAfterDownload -Disabled))

        $Result.Content | Should -BeExactly 'Start after download'
        $Result.IsEnabled | Should -BeFalse
        $Result.IsChecked | Should -BeFalse
        $Result.Margin.Bottom | Should -BeExactly 2

        $script:LayoutContext.CenteredCheckboxGroup | Should -Not -BeNullOrEmpty
        $script:LayoutContext.CenteredCheckboxGroup.HorizontalAlignment | Should -BeExactly ([Windows.HorizontalAlignment]::Center)
        $script:LayoutContext.CenteredCheckboxGroup.Children.Count | Should -BeExactly 1

        $script:LayoutContext.CurrentGroup.Children.Count | Should -BeExactly 1
        $script:LayoutContext.PreviousLabelOrCheckbox | Should -BeExactly $Result
    }

    It 'Should create a checked checkbox' {
        Set-Variable -Option Constant Result ([Windows.Controls.CheckBox](New-CheckBoxRunAfterDownload -Checked))

        $Result.IsChecked | Should -BeTrue
        $Result.IsEnabled | Should -BeTrue
    }
}
