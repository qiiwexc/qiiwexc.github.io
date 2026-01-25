BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms
}

Describe 'Set-CheckboxState' {
    BeforeEach {
        Set-Variable -Option Constant TestControlChecked ([Windows.Forms.CheckBox]@{ Checked = $True })
        Set-Variable -Option Constant TestControlUnchecked ([Windows.Forms.CheckBox]@{ Checked = $False })

        Set-Variable -Option Constant TestDependantEnabled ([Windows.Forms.CheckBox]@{ Enabled = $True; Checked = $True })
        Set-Variable -Option Constant TestDependantDisabled ([Windows.Forms.CheckBox]@{ Enabled = $False; Checked = $False })
    }

    It 'Should set dependant enabled when control is checked' {
        Set-CheckboxState $TestControlChecked $TestDependantDisabled

        $TestDependantDisabled.Enabled | Should -BeTrue
        $TestDependantDisabled.Checked | Should -BeFalse
    }

    It 'Should set dependant disabled when control is unchecked' {
        Set-CheckboxState $TestControlUnchecked $TestDependantDisabled

        $TestDependantDisabled.Enabled | Should -BeFalse
        $TestDependantDisabled.Checked | Should -BeFalse
    }

    It 'Should set dependant enabled when control is checked' {
        Set-CheckboxState $TestControlChecked $TestDependantEnabled

        $TestDependantEnabled.Enabled | Should -BeTrue
        $TestDependantEnabled.Checked | Should -BeTrue
    }

    It 'Should set dependant disabled when control is unchecked' {
        Set-CheckboxState $TestControlUnchecked $TestDependantEnabled

        $TestDependantEnabled.Enabled | Should -BeFalse
        $TestDependantEnabled.Checked | Should -BeFalse
    }
}
