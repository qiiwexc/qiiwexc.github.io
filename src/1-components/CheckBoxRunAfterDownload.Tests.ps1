BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$(Split-Path $PSCommandPath -Parent)\CheckBox.ps1"

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestCheckBox ([Windows.Forms.CheckBox]@{ Name = 'TEST_CHECKBOX' })
}

Describe 'New-CheckBoxRunAfterDownload' {
    BeforeEach {
        Mock New-CheckBox { return $TestCheckBox }
    }

    It 'Should create a checkbox with correct parameters' {
        Set-Variable -Option Constant Result ([Windows.Forms.CheckBox](New-CheckBoxRunAfterDownload -Disabled))

        Should -Invoke New-CheckBox -Exactly 1
        Should -Invoke New-CheckBox -Exactly 1 -ParameterFilter {
            $Text -eq 'Start after download' -and
            $Disabled -eq $True -and
            $Checked -eq $False
        }

        $Result | Should -BeExactly $TestCheckBox
    }
}
