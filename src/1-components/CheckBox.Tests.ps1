BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestName ([String]'TEST_NAME')

    Set-Variable -Option Constant BUTTON_HEIGHT ([Int]30)
    Set-Variable -Option Constant CHECKBOX_HEIGHT ([Int]20)
    Set-Variable -Option Constant INTERVAL_CHECKBOX ([Int]25)
    Set-Variable -Option Constant INITIAL_LOCATION_BUTTON ([Drawing.Point]'15, 20')

    function Add {}
}

Describe 'New-CheckBox' {
    BeforeEach {
        [Windows.Forms.Button]$script:PREVIOUS_BUTTON = $Null
        [Windows.Forms.CheckBox]$script:PREVIOUS_LABEL_OR_CHECKBOX = $Null
        [Bool]$script:PAD_CHECKBOXES = $False

        [Windows.Forms.GroupBox]$script:CURRENT_GROUP = (
            New-MockObject -Type Windows.Forms.GroupBox -Properties @{
                Height   = 0
                Controls = New-MockObject -Type Windows.Forms.Control -Methods @{
                    Add = { Add }
                }
            }
        )

        [Switch]$TestDisabledArg = $False
        [Switch]$TestCheckedArg = $False

        Mock Add {}
    }

    It 'Should create a new checkbox' {
        Set-Variable -Option Constant Result (
            [Windows.Forms.CheckBox](
                New-CheckBox $TestText $TestName -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        Should -Invoke Add -Exactly 1

        $Result.Text | Should -BeExactly $TestText
        $Result.Name | Should -BeExactly $TestName
        $Result.Checked | Should -BeFalse
        $Result.Enabled | Should -BeTrue
        $Result.Size.Width | Should -BeExactly 175
        $Result.Size.Height | Should -BeExactly $CHECKBOX_HEIGHT
        $Result.Location | Should -BeExactly $INITIAL_LOCATION_BUTTON

        $script:CURRENT_GROUP.Height | Should -BeExactly 50
        $script:PREVIOUS_LABEL_OR_CHECKBOX | Should -BeExactly $Result
    }

    It 'Should create a checkbox under a button' {
        $TestDisabledArg = $True
        $TestCheckedArg = $True

        $script:PREVIOUS_BUTTON = @{ Location = '100, 200' }

        Set-Variable -Option Constant Result (
            [Windows.Forms.CheckBox](
                New-CheckBox $TestText $TestName -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        $Result.Checked | Should -BeTrue
        $Result.Enabled | Should -BeFalse
        $Result.Location.X | Should -BeExactly 125
        $Result.Location.Y | Should -BeExactly 230

        $script:CURRENT_GROUP.Height | Should -BeExactly 260
    }

    It 'Should create a checkbox without padding under a checkbox/label' {
        $script:PREVIOUS_LABEL_OR_CHECKBOX = @{ Location = '100, 200' }

        Set-Variable -Option Constant Result (
            [Windows.Forms.CheckBox](
                New-CheckBox $TestText $TestName -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        $Result.Location.X | Should -BeExactly 15
        $Result.Location.Y | Should -BeExactly 225

        $script:CURRENT_GROUP.Height | Should -BeExactly 255
    }

    It 'Should create a checkbox with padding under a checkbox/label' {
        $script:PREVIOUS_LABEL_OR_CHECKBOX = @{ Location = '100, 200' }
        $script:PAD_CHECKBOXES = $True

        Set-Variable -Option Constant Result (
            [Windows.Forms.CheckBox](
                New-CheckBox $TestText $TestName -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        $Result.Location.X | Should -BeExactly 40
        $Result.Location.Y | Should -BeExactly 220

        $script:CURRENT_GROUP.Height | Should -BeExactly 250
    }

    It 'Should create a checkbox under a button and a checkbox/label' {
        $script:PREVIOUS_BUTTON = @{ Location = '100, 200' }
        $script:PREVIOUS_LABEL_OR_CHECKBOX = @{ Location = '200, 300' }

        Set-Variable -Option Constant Result (
            [Windows.Forms.CheckBox](
                New-CheckBox $TestText $TestName -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        $Result.Location.X | Should -BeExactly 100
        $Result.Location.Y | Should -BeExactly 325

        $script:CURRENT_GROUP.Height | Should -BeExactly 355
    }

}
