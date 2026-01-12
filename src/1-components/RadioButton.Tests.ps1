BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')

    Set-Variable -Option Constant BUTTON_HEIGHT ([Int]30)
    Set-Variable -Option Constant CHECKBOX_HEIGHT ([Int]20)
    Set-Variable -Option Constant INITIAL_LOCATION_BUTTON ([Drawing.Point]'15, 20')

    function Add { }
}

Describe 'New-RadioButton' {
    BeforeEach {
        [Windows.Forms.Button]$script:PREVIOUS_BUTTON = $Null
        [Windows.Forms.RadioButton]$script:PREVIOUS_RADIO = $Null
        [Windows.Forms.Label]$script:PREVIOUS_LABEL_OR_CHECKBOX = $Null

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

        Mock Add { }
    }

    It 'Should create a new radio button' {
        Set-Variable -Option Constant Result (
            [Windows.Forms.RadioButton](
                New-RadioButton $TestText -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        Should -Invoke Add -Exactly 1

        $Result.Text | Should -BeExactly $TestText
        $Result.Checked | Should -BeFalse
        $Result.Enabled | Should -BeTrue
        $Result.Size.Width | Should -BeExactly 80
        $Result.Size.Height | Should -BeExactly $CHECKBOX_HEIGHT
        $Result.Location | Should -BeExactly $INITIAL_LOCATION_BUTTON

        $script:CURRENT_GROUP.Height | Should -BeExactly 50
        $script:PREVIOUS_RADIO | Should -BeExactly $Result
    }

    It 'Should create a radio button under a button' {
        $TestDisabledArg = $True
        $TestCheckedArg = $True

        $script:PREVIOUS_BUTTON = @{ Location = '100, 200' }

        Set-Variable -Option Constant Result (
            [Windows.Forms.RadioButton](
                New-RadioButton $TestText -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        $Result.Checked | Should -BeTrue
        $Result.Enabled | Should -BeFalse
        $Result.Location.X | Should -BeExactly 110
        $Result.Location.Y | Should -BeExactly 230

        $script:CURRENT_GROUP.Height | Should -BeExactly 260
    }

    It 'Should create a radio button under a checkbox/label' {
        $script:PREVIOUS_LABEL_OR_CHECKBOX = @{ Location = '100, 200' }

        Set-Variable -Option Constant Result (
            [Windows.Forms.RadioButton](
                New-RadioButton $TestText -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        $Result.Location.X | Should -BeExactly 85
        $Result.Location.Y | Should -BeExactly 220

        $script:CURRENT_GROUP.Height | Should -BeExactly 250
    }

    It 'Should create a radio button under a radio button' {
        $script:PREVIOUS_RADIO = @{ Location = '100, 200' }

        Set-Variable -Option Constant Result (
            [Windows.Forms.RadioButton](
                New-RadioButton $TestText -Disabled:$TestDisabledArg -Checked:$TestCheckedArg
            )
        )

        $Result.Location.X | Should -BeExactly 90
        $Result.Location.Y | Should -BeExactly 200

        $script:CURRENT_GROUP.Height | Should -BeExactly 230
    }

}
