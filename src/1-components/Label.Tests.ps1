BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')

    Set-Variable -Option Constant BUTTON_HEIGHT ([Int]30)
    Set-Variable -Option Constant CHECKBOX_HEIGHT ([Int]20)

    Set-Variable -Option Constant PREVIOUS_BUTTON ([Windows.Forms.Button]@{ Location = '15, 20' })

    function Add { }
}

Describe 'New-Label' {
    BeforeEach {
        [Windows.Forms.Label]$script:PREVIOUS_LABEL_OR_CHECKBOX = $Null
        [Windows.Forms.GroupBox]$script:CURRENT_GROUP = (
            New-MockObject -Type Windows.Forms.GroupBox -Properties @{
                Height   = 0
                Controls = New-MockObject -Type Windows.Forms.Control -Methods @{
                    Add = { Add }
                }
            }
        )

        Mock Add { }
    }

    It 'Should create a new label' {
        New-Label $TestText

        Should -Invoke Add -Exactly 1

        $script:CURRENT_GROUP.Height | Should -BeExactly 80

        $script:PREVIOUS_LABEL_OR_CHECKBOX.Text | Should -BeExactly $TestText
        $script:PREVIOUS_LABEL_OR_CHECKBOX.Size.Width | Should -BeExactly 145
        $script:PREVIOUS_LABEL_OR_CHECKBOX.Size.Height | Should -BeExactly $CHECKBOX_HEIGHT
        $script:PREVIOUS_LABEL_OR_CHECKBOX.Location.X | Should -BeExactly 55
        $script:PREVIOUS_LABEL_OR_CHECKBOX.Location.Y | Should -BeExactly 50
    }
}
