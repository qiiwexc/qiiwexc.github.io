BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestFunction ([ScriptBlock] { Test = 'Function' })

    Set-Variable -Option Constant BUTTON_HEIGHT ([Int]30)
    Set-Variable -Option Constant BUTTON_WIDTH ([Int]170)
    Set-Variable -Option Constant INTERVAL_BUTTON ([Int]45)
    Set-Variable -Option Constant INITIAL_LOCATION_BUTTON ([Drawing.Point]'15, 20')
    Set-Variable -Option Constant BUTTON_FONT ([System.Drawing.Font]'Microsoft Sans Serif, 10')

    function Add {}
}

Describe 'New-Button' {
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

        Mock Add {}
    }

    It 'Should create a new button' {
        New-Button $TestText $TestFunction -Disabled:$TestDisabledArg

        Should -Invoke Add -Exactly 1

        $script:PREVIOUS_BUTTON.Text | Should -BeExactly $TestText
        $script:PREVIOUS_BUTTON.Font | Should -BeExactly $BUTTON_FONT
        $script:PREVIOUS_BUTTON.Enabled | Should -BeTrue
        $script:PREVIOUS_BUTTON.Size.Width | Should -BeExactly $BUTTON_WIDTH
        $script:PREVIOUS_BUTTON.Size.Height | Should -BeExactly $BUTTON_HEIGHT
        $script:PREVIOUS_BUTTON.Location | Should -BeExactly $INITIAL_LOCATION_BUTTON

        $script:CURRENT_GROUP.Height | Should -BeExactly 65
    }

    It 'Should create a button under a button' {
        $TestDisabledArg = $True

        $script:PREVIOUS_BUTTON = @{ Location = '100, 200' }

        New-Button $TestText $TestFunction -Disabled:$TestDisabledArg

        $script:PREVIOUS_BUTTON.Enabled | Should -BeFalse
        $script:PREVIOUS_BUTTON.Location.X | Should -BeExactly 100
        $script:PREVIOUS_BUTTON.Location.Y | Should -BeExactly 245

        $script:CURRENT_GROUP.Height | Should -BeExactly 290
    }

    It 'Should create a button under a checkbox/label' {
        $script:PREVIOUS_LABEL_OR_CHECKBOX = @{ Location = '100, 200' }

        New-Button $TestText $TestFunction -Disabled:$TestDisabledArg

        $script:PREVIOUS_BUTTON.Location.X | Should -BeExactly 15
        $script:PREVIOUS_BUTTON.Location.Y | Should -BeExactly 230

        $script:CURRENT_GROUP.Height | Should -BeExactly 275
    }

    It 'Should create a button under a radio button' {
        $script:PREVIOUS_RADIO = @{ Location = '100, 200' }

        New-Button $TestText $TestFunction -Disabled:$TestDisabledArg

        $script:PREVIOUS_BUTTON.Location.X | Should -BeExactly 15
        $script:PREVIOUS_BUTTON.Location.Y | Should -BeExactly 230

        $script:CURRENT_GROUP.Height | Should -BeExactly 275
    }

    It 'Should create a button under a checkbox/label and a radio button' {
        $script:PREVIOUS_LABEL_OR_CHECKBOX = @{ Location = '100, 200' }
        $script:PREVIOUS_RADIO = @{ Location = '200, 300' }

        New-Button $TestText $TestFunction -Disabled:$TestDisabledArg

        $script:PREVIOUS_BUTTON.Location.X | Should -BeExactly 15
        $script:PREVIOUS_BUTTON.Location.Y | Should -BeExactly 330

        $script:CURRENT_GROUP.Height | Should -BeExactly 375
    }

    It 'Should create a button under a radio button and a checkbox/label' {
        $script:PREVIOUS_LABEL_OR_CHECKBOX = @{ Location = '300, 400' }
        $script:PREVIOUS_RADIO = @{ Location = '200, 300' }

        New-Button $TestText $TestFunction -Disabled:$TestDisabledArg

        $script:PREVIOUS_BUTTON.Location.X | Should -BeExactly 15
        $script:PREVIOUS_BUTTON.Location.Y | Should -BeExactly 430

        $script:CURRENT_GROUP.Height | Should -BeExactly 475
    }
}
