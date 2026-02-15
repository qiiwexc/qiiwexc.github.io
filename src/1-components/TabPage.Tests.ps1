BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant CARD_COLUMN_WIDTH ([Int]230)

    Set-Variable -Option Constant TAB_CONTROL (New-Object Windows.Controls.TabControl)
}

Describe 'New-TabPage' {
    BeforeEach {
        $script:CURRENT_TAB = $Null
    }

    It 'Should create a new tab' {
        Set-Variable -Option Constant Result ([Windows.Controls.TabItem](New-TabPage $TestText))

        $TAB_CONTROL.Items.Count | Should -BeExactly 1

        $Result.Header | Should -BeExactly $TestText
        $Result.Content | Should -BeOfType [Windows.Controls.ScrollViewer]

        Set-Variable -Option Constant ScrollViewer ([Windows.Controls.ScrollViewer]$Result.Content)
        $ScrollViewer.Content | Should -BeOfType [Windows.Controls.WrapPanel]

        Set-Variable -Option Constant WrapPanel ([Windows.Controls.WrapPanel]$ScrollViewer.Content)
        $WrapPanel.ItemWidth | Should -BeExactly $CARD_COLUMN_WIDTH

        $script:CURRENT_TAB | Should -BeExactly $WrapPanel
    }
}
