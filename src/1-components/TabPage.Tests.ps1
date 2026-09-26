#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant TestText ([String]'TEST_TEXT')
    Set-Variable -Option Constant CARD_COLUMN_WIDTH ([Int]230)
}

Describe 'New-TabPage' {
    It 'Should add a tab, and return the panel for its cards' {
        Set-Variable -Option Constant TabControl ([Windows.Controls.TabControl]::new())

        Set-Variable -Option Constant Result ([Windows.Controls.WrapPanel](New-TabPage $TabControl $TestText))

        $TabControl.Items.Count | Should -BeExactly 1

        Set-Variable -Option Constant TabItem ([Windows.Controls.TabItem]$TabControl.Items[0])
        $TabItem.Header | Should -BeExactly $TestText
        $TabItem.Content | Should -BeOfType [Windows.Controls.ScrollViewer]
        $TabItem.Content.Content | Should -BeExactly $Result
        $Result.ItemWidth | Should -BeExactly $CARD_COLUMN_WIDTH
    }
}
