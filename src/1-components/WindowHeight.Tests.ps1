#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    . "$PSScriptRoot\TabPage.ps1"

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant CARD_COLUMN_WIDTH ([Int]230)

    # Room for three columns of cards, less the tab's padding, but only two once a scroll bar takes its share
    Set-Variable -Option Constant TestWidth ([Int](3 * $CARD_COLUMN_WIDTH + 16 + 4))

    # A window that holds nothing but tabs, each with cards of the given heights, one column wide. A window that is
    # never shown has no layout, so the tabs are laid out in a frame of their own, as tall as the window
    function New-TestWindow {
        param(
            [Parameter(Position = 0, Mandatory)][Double]$Height,
            [Parameter(Position = 1, Mandatory)][Double[][]]$Tabs
        )

        # As the window's own tab control: no border or padding around the tabs
        Set-Variable -Option Constant TabControl ([Windows.Controls.TabControl]::new())
        $TabControl.BorderThickness = [Windows.Thickness]::new(0)
        $TabControl.Padding = [Windows.Thickness]::new(0)

        for ($Index = 0; $Index -lt $Tabs.Count; $Index++) {
            [Windows.Controls.WrapPanel]$Page = New-TabPage $TabControl "Tab $Index"
            foreach ($CardHeight in $Tabs[$Index]) {
                [Void]$Page.Children.Add([Windows.Controls.Border]@{ Height = $CardHeight })
            }
        }
        $TabControl.SelectedIndex = 0

        Set-Variable -Option Constant Frame ([Windows.Controls.Border]::new())
        $Frame.Child = $TabControl

        Set-Variable -Option Constant Window ([Windows.Window]::new())
        $Window.Height = $Height
        $Window.Top = 100

        Set-Variable -Option Constant Test ([PSCustomObject]@{ Window = $Window; TabControl = $TabControl; Frame = $Frame })
        Update-TestLayout $Test

        return $Test
    }

    function Update-TestLayout {
        param(
            [Parameter(Position = 0, Mandatory)][PSCustomObject]$Test
        )

        # Lets the tab control swap in the selected page before it is laid out
        $Test.Frame.Dispatcher.Invoke([Action] {}, [Windows.Threading.DispatcherPriority]::Background)

        $Test.Frame.Measure([Windows.Size]::new($TestWidth, $Test.Window.Height))
        $Test.Frame.Arrange([Windows.Rect]::new(0, 0, $TestWidth, $Test.Window.Height))
        $Test.Frame.UpdateLayout()
    }
}

Describe 'Set-WindowHeight' {
    It 'Should <Change> the window to fit its tallest tab, and keep it centred' -ForEach @(
        @{ Change = 'shrink'; Height = 600 }
        @{ Change = 'grow'; Height = 300 }
    ) {
        Set-Variable -Option Constant Test ([PSCustomObject](New-TestWindow $Height @(@(150), @(320), @(100))))
        Set-Variable -Option Constant Viewport ([Double]$Test.TabControl.SelectedItem.Content.ViewportHeight)
        Set-Variable -Option Constant Expected ([Double][Math]::Ceiling($Height + 320 - $Viewport))

        Set-WindowHeight $Test.Window $Test.TabControl 1000

        $Test.Window.Height | Should -Be $Expected
        $Test.Window.MinHeight | Should -Be $Expected
        $Test.Window.Top | Should -Be (100 + ($Height - $Expected) / 2)
    }

    It 'Should leave the tallest tab no more room than it needs' {
        Set-Variable -Option Constant Test ([PSCustomObject](New-TestWindow 600 @(@(150), @(320), @(100))))

        Set-WindowHeight $Test.Window $Test.TabControl 1000

        $Test.TabControl.SelectedIndex = 1
        Update-TestLayout $Test

        Set-Variable -Option Constant Page ([Windows.Controls.ScrollViewer]$Test.TabControl.SelectedItem.Content)
        $Page.ScrollableHeight | Should -Be 0
        $Page.ViewportHeight - $Page.ExtentHeight | Should -BeLessThan 1
    }

    It 'Should not make the window taller than the maximum' {
        Set-Variable -Option Constant Test ([PSCustomObject](New-TestWindow 300 @(@(150), @(900))))

        Set-WindowHeight $Test.Window $Test.TabControl 500

        $Test.Window.Height | Should -Be 500
        $Test.Window.MinHeight | Should -Be 500
        $Test.Window.Top | Should -Be 0
    }

    It 'Should measure every tab at the width its cards have once no scroll bar shows' {
        # Six cards wrap in two rows of three at the full width, and in three rows of two beside a scroll bar
        Set-Variable -Option Constant Test ([PSCustomObject](New-TestWindow 150 @(@(100, 100, 100, 100, 100, 100), @(50))))
        Set-Variable -Option Constant Page ([Windows.Controls.ScrollViewer]$Test.TabControl.SelectedItem.Content)
        $Page.ComputedVerticalScrollBarVisibility | Should -Be 'Visible'
        Set-Variable -Option Constant Viewport ([Double]$Page.ViewportHeight)

        Set-WindowHeight $Test.Window $Test.TabControl 1000

        $Test.Window.Height | Should -Be ([Math]::Ceiling(150 + 200 - $Viewport))
    }
}
