BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant TestPreviousGroup ([Windows.Forms.GroupBox]@{ Location = '100, 200' })

    Set-Variable -Option Constant GROUP_WIDTH ([Int]200)

    function Add {}
}

Describe 'New-GroupBox' {
    BeforeEach {
        [Windows.Forms.GroupBox]$script:PREVIOUS_GROUP = $Null
        [Windows.Forms.GroupBox]$script:CURRENT_GROUP = $TestPreviousGroup
        [Bool]$script:PAD_CHECKBOXES = $False
        [Windows.Forms.Button]$script:PREVIOUS_BUTTON = @{}
        [Windows.Forms.RadioButton]$script:PREVIOUS_RADIO = @{}
        [Windows.Forms.CheckBox]$script:PREVIOUS_LABEL_OR_CHECKBOX = @{}
        [Windows.Forms.TabPage]$script:CURRENT_TAB = New-MockObject -Type Windows.Forms.TabPage -Properties @{
            Controls = New-MockObject -Type Windows.Forms.Control -Properties @{
                Count = 0
            } -Methods @{
                Add = { Add }
            }
        }

        Mock Add {}
    }

    It 'Should create a new group box' {
        New-GroupBox $TestText

        Should -Invoke Add -Exactly 1

        $script:PREVIOUS_GROUP | Should -BeExactly $TestPreviousGroup
        $script:PAD_CHECKBOXES | Should -BeTrue

        $script:PREVIOUS_BUTTON | Should -BeNullOrEmpty
        $script:PREVIOUS_RADIO | Should -BeNullOrEmpty
        $script:PREVIOUS_LABEL_OR_CHECKBOX | Should -BeNullOrEmpty

        $script:CURRENT_GROUP.Width | Should -BeExactly $GROUP_WIDTH
        $script:CURRENT_GROUP.Text | Should -BeExactly $TestText
        $script:CURRENT_GROUP.Location.X | Should -BeExactly 15
        $script:CURRENT_GROUP.Location.Y | Should -BeExactly 15
    }

    It 'Should add a second group box' {
        [Windows.Forms.TabPage]$script:CURRENT_TAB = New-MockObject -Type Windows.Forms.TabPage -Properties @{
            Controls = New-MockObject -Type Windows.Forms.Control -Properties @{
                Count = 1
            } -Methods @{
                Add = { Add }
            }
        }

        New-GroupBox $TestText

        $script:CURRENT_GROUP.Location.X | Should -BeExactly 315
        $script:CURRENT_GROUP.Location.Y | Should -BeExactly 200
    }

    It 'Should add group box with index override' {
        [Windows.Forms.TabPage]$script:CURRENT_TAB = New-MockObject -Type Windows.Forms.TabPage -Properties @{
            Controls = New-MockObject -Type Windows.Forms.Control -Methods @{
                Add = { Add }
            }
        }

        New-GroupBox $TestText 1

        $script:CURRENT_GROUP.Location.X | Should -BeExactly 315
        $script:CURRENT_GROUP.Location.Y | Should -BeExactly 200
    }

    It 'Should add a 4th group box' {
        [Windows.Forms.TabPage]$script:CURRENT_TAB = New-MockObject -Type Windows.Forms.TabPage -Properties @{
            Controls = (
                [Collections.Generic.List[Windows.Forms.Control]]@(
                    @{Location = ([Drawing.Point]'15, 100'); Height = 150 },
                    @{},
                    @{}
                )
            )
        }

        New-GroupBox $TestText

        $script:CURRENT_GROUP.Location.X | Should -BeExactly 15
        $script:CURRENT_GROUP.Location.Y | Should -BeExactly 265
    }
}
