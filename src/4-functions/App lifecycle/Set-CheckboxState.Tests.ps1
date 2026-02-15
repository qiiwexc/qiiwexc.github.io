BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
}

Describe 'Set-CheckboxState' {
    BeforeEach {
        Set-Variable -Option Constant TestControlChecked (& { $cb = New-Object Windows.Controls.CheckBox; $cb.IsChecked = $True; $cb })
        Set-Variable -Option Constant TestControlUnchecked (& { $cb = New-Object Windows.Controls.CheckBox; $cb.IsChecked = $False; $cb })

        Set-Variable -Option Constant TestDependantEnabled (& { $cb = New-Object Windows.Controls.CheckBox; $cb.IsEnabled = $True; $cb.IsChecked = $True; $cb })
        Set-Variable -Option Constant TestDependantDisabled (& { $cb = New-Object Windows.Controls.CheckBox; $cb.IsEnabled = $False; $cb.IsChecked = $False; $cb })
    }

    It 'Should set dependant enabled when control is checked' {
        Set-CheckboxState $TestControlChecked $TestDependantDisabled

        $TestDependantDisabled.IsEnabled | Should -BeTrue
        $TestDependantDisabled.IsChecked | Should -BeFalse
    }

    It 'Should set dependant disabled when control is unchecked' {
        Set-CheckboxState $TestControlUnchecked $TestDependantDisabled

        $TestDependantDisabled.IsEnabled | Should -BeFalse
        $TestDependantDisabled.IsChecked | Should -BeFalse
    }

    It 'Should set dependant enabled when control is checked' {
        Set-CheckboxState $TestControlChecked $TestDependantEnabled

        $TestDependantEnabled.IsEnabled | Should -BeTrue
        $TestDependantEnabled.IsChecked | Should -BeTrue
    }

    It 'Should set dependant disabled when control is unchecked' {
        Set-CheckboxState $TestControlUnchecked $TestDependantEnabled

        $TestDependantEnabled.IsEnabled | Should -BeFalse
        $TestDependantEnabled.IsChecked | Should -BeFalse
    }
}
