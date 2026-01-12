BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')

    function Add { }

    Set-Variable -Option Constant TAB_CONTROL (
        New-MockObject -Type Windows.Forms.TabControl -Properties @{
            Controls = New-MockObject -Type Windows.Forms.Control -Methods @{
                Add = { Add }
            }
        }
    )
}

Describe 'New-TabPage' {
    BeforeEach {
        [Windows.Forms.GroupBox]$script:PREVIOUS_GROUP = @{}
        [Windows.Forms.TabPage]$script:CURRENT_TAB = $Null

        Mock Add { }
    }

    It 'Should create a new tab' {
        New-TabPage $TestText

        Should -Invoke Add -Exactly 1

        $script:PREVIOUS_GROUP | Should -BeNullOrEmpty

        $script:CURRENT_TAB.UseVisualStyleBackColor | Should -BeTrue
        $script:CURRENT_TAB.Text | Should -BeExactly $TestText
    }
}
