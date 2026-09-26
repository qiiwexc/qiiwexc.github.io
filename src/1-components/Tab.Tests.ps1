#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Button.ps1"
    . "$PSScriptRoot\ButtonBrowser.ps1"
    . "$PSScriptRoot\Card.ps1"
    . "$PSScriptRoot\CheckBox.ps1"
    . "$PSScriptRoot\CheckBoxRunAfterDownload.ps1"
    . "$PSScriptRoot\Label.ps1"
    . "$PSScriptRoot\TabPage.ps1"

    . "$PSScriptRoot\..\4-functions\Common\Start-AsyncOperation.ps1"

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant FONT_NAME ([String]'Segoe UI')
    Set-Variable -Option Constant FONT_SIZE_NORMAL ([Int]12)
    Set-Variable -Option Constant FONT_SIZE_HEADER ([Int]16)
    Set-Variable -Option Constant CARD_COLUMN_WIDTH ([Int]230)

    Set-Variable -Option Constant FORM ([PSCustomObject]@{})
    $FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($Key) return [Windows.Style]::new() }

    Set-Variable -Option Constant SpacedMargin ([Windows.Thickness]::new(0, 14, 0, 4))

    # The items of a rendered card, below its header
    function Get-CardItem {
        param(
            [Parameter(Position = 0, Mandatory)][Windows.Controls.TabControl]$TabControl,
            [Parameter(Position = 1)][Int]$CardIndex = 0
        )

        [Windows.Controls.StackPanel]$Card = $TabControl.Items[0].Content.Content.Children[$CardIndex].Child
        return @($Card.Children | Select-Object -Skip 1)
    }

    function New-TestTab {
        param(
            [Parameter(Position = 0, Mandatory)][Object[]]$Items
        )

        return @{ Tab = 'TEST_TAB'; Cards = @(@{ Card = 'TEST_CARD'; Items = $Items }) }
    }
}

Describe 'New-Tab' {
    BeforeAll {
        Mock Register-AsyncButton {}
    }

    BeforeEach {
        Set-Variable -Option Constant TabControl ([Windows.Controls.TabControl]::new())
        Set-Variable -Option Constant Checkboxes ([Hashtable]@{})
        Set-Variable -Option Constant Buttons ([Hashtable]@{})
        $script:Clicked = [Collections.Generic.List[String]]::new()
    }

    It 'Should render a page with its cards' {
        New-Tab $TabControl @{
            Tab   = 'TEST_TAB'
            Cards = @(
                @{ Card = 'FIRST'; Items = @(@{ Button = 'A'; Action = {} }) }
                @{ Card = 'SECOND'; Items = @(@{ Button = 'B'; Action = {} }) }
            )
        } $Checkboxes $Buttons

        $TabControl.Items.Count | Should -BeExactly 1
        $TabControl.Items[0].Header | Should -BeExactly 'TEST_TAB'
        [Windows.Controls.WrapPanel]$Page = $TabControl.Items[0].Content.Content
        @($Page.Children | ForEach-Object { $_.Child.Children[0].Text }) | Should -BeExactly @('FIRST', 'SECOND')
    }

    It 'Should set apart every button after the first item of its card' {
        New-Tab $TabControl (New-TestTab @(
                @{ Button = 'FIRST'; Action = {} }
                @{ Button = 'BROWSER'; Action = {}; Browser = $True }
                @{ CheckBox = 'STANDALONE'; Name = 'Standalone' }
                @{ Button = 'LAST'; Action = {} }
            )) $Checkboxes $Buttons

        [Object[]]$Items = Get-CardItem $TabControl
        $Items.Count | Should -BeExactly 5
        $Items[0].Content | Should -BeExactly 'FIRST'
        $Items[0].Margin | Should -Be ([Windows.Thickness]::new(0))
        $Items[1].Content | Should -BeExactly 'BROWSER'
        $Items[1].Margin | Should -Be $SpacedMargin
        $Items[2].Text | Should -BeExactly 'Open in a browser'
        $Items[3].Content | Should -BeExactly 'STANDALONE'
        $Items[3].Margin | Should -Be ([Windows.Thickness]::new(10, 4, 0, 4))
        $Items[4].Content | Should -BeExactly 'LAST'
        $Items[4].Margin | Should -Be $SpacedMargin
    }

    It 'Should put the options of a button with a Start after download checkbox in its centred group' {
        New-Tab $TabControl (New-TestTab @(
                @{ Button = 'BUTTON'; Action = {}; StartAfterDownload = @{ Name = 'Start' }; Options = @(@{ CheckBox = 'OPTION'; Name = 'Option' }) }
            )) $Checkboxes $Buttons

        [Object[]]$Items = Get-CardItem $TabControl
        $Items.Count | Should -BeExactly 2
        [Windows.Controls.StackPanel]$Group = $Items[1]
        $Group.HorizontalAlignment | Should -BeExactly ([Windows.HorizontalAlignment]::Center)
        $Group.Children[0] | Should -BeExactly $Checkboxes['Start']
        $Group.Children[1] | Should -BeExactly $Checkboxes['Option']
        $Checkboxes['Start'].Content | Should -BeExactly 'Start after download'
        $Checkboxes['Start'].IsChecked | Should -BeTrue
        $Checkboxes['Option'].Margin | Should -Be ([Windows.Thickness]::new(0, 4, 0, 4))
    }

    It 'Should put the options of any other button in the card' {
        New-Tab $TabControl (New-TestTab @(
                @{ Button = 'BUTTON'; Action = {}; Options = @(@{ CheckBox = 'OPTION'; Name = 'Option' }) }
            )) $Checkboxes $Buttons

        [Object[]]$Items = Get-CardItem $TabControl
        $Items[1] | Should -BeExactly $Checkboxes['Option']
        $Checkboxes['Option'].Margin | Should -Be ([Windows.Thickness]::new(10, 4, 0, 4))
    }

    It 'Should register every checkbox by name, with its tag and state' {
        New-Tab $TabControl (New-TestTab @(
                @{ CheckBox = 'FIRST'; Name = 'First'; Tag = 'TAG'; Checked = $True; Disabled = $True }
                @{ CheckBox = 'SECOND'; Name = 'Second' }
            )) $Checkboxes $Buttons

        $Checkboxes.Keys | Sort-Object | Should -BeExactly @('First', 'Second')
        $Checkboxes['First'].Tag | Should -BeExactly 'TAG'
        $Checkboxes['First'].IsChecked | Should -BeTrue
        $Checkboxes['First'].IsEnabled | Should -BeFalse
        $Checkboxes['Second'].Tag | Should -BeExactly ''
        $Checkboxes['Second'].IsChecked | Should -BeFalse
        $Checkboxes['Second'].IsEnabled | Should -BeTrue
    }

    It 'Should disable a button' {
        New-Tab $TabControl (New-TestTab @(@{ Button = 'BUTTON'; Action = {}; Disabled = $True })) $Checkboxes $Buttons

        (Get-CardItem $TabControl)[0].IsEnabled | Should -BeFalse
    }

    It 'Should register every named button by name' {
        New-Tab $TabControl (New-TestTab @(
                @{ Button = 'NAMED'; Name = 'Named'; Action = {} }
                @{ Button = 'BROWSER'; Name = 'Browser'; Action = {}; Browser = $True }
                @{ Button = 'UNNAMED'; Action = {} }
            )) $Checkboxes $Buttons

        [Object[]]$Items = Get-CardItem $TabControl
        $Buttons.Keys | Sort-Object | Should -BeExactly @('Browser', 'Named')
        $Buttons['Named'] | Should -BeExactly $Items[0]
        $Buttons['Browser'] | Should -BeExactly $Items[1]
    }

    It 'Should register every button whose action starts an operation' {
        New-Tab $TabControl (New-TestTab @(
                @{ Button = 'OPERATION'; Action = { Start-AsyncOperation -Button $this { Update-Windows } } }
                @{ Button = 'CAPTURED'; Action = { $Value = 1; Start-AsyncOperation -Button $this { $Value } -Variables @{ Value = $Value } } }
                @{ Button = 'IMMEDIATE'; Action = { Update-Windows } }
            )) $Checkboxes $Buttons

        [Object[]]$Items = Get-CardItem $TabControl
        Should -Invoke Register-AsyncButton -Exactly 2
        Should -Invoke Register-AsyncButton -Exactly 1 -ParameterFilter { $Button -eq $Items[0] }
        Should -Invoke Register-AsyncButton -Exactly 1 -ParameterFilter { $Button -eq $Items[1] }
    }

    It 'Should run the action of a button and the OnClick of a checkbox when clicked' {
        New-Tab $TabControl (New-TestTab @(
                @{
                    Button             = 'BUTTON'
                    Action             = { $script:Clicked.Add('Action') }
                    StartAfterDownload = @{ Name = 'Start'; OnClick = { $script:Clicked.Add('Start') } }
                    Options            = @(@{ CheckBox = 'OPTION'; Name = 'Option'; OnClick = { $script:Clicked.Add('Option') } })
                }
            )) $Checkboxes $Buttons

        Set-Variable -Option Constant ClickEvent ([Windows.RoutedEvent][Windows.Controls.Primitives.ButtonBase]::ClickEvent)
        (Get-CardItem $TabControl)[0].RaiseEvent([Windows.RoutedEventArgs]::new($ClickEvent))
        $Checkboxes['Start'].RaiseEvent([Windows.RoutedEventArgs]::new($ClickEvent))
        $Checkboxes['Option'].RaiseEvent([Windows.RoutedEventArgs]::new($ClickEvent))

        $script:Clicked | Should -BeExactly @('Action', 'Start', 'Option')
    }

    It 'Should refuse <Case>' -ForEach @(
        @{ Case = 'a tab without cards'; Definition = @{ Tab = 'T' }; Message = "Tab: 'Cards' is missing" }
        @{ Case = 'a card without items'; Definition = @{ Tab = 'T'; Cards = @(@{ Card = 'C' }) }; Message = "Tab 'T': 'Items' is missing" }
        @{ Case = 'an unknown key'; Definition = @{ Tab = 'T'; Cards = @(@{ Card = 'C'; Items = @(@{ Button = 'B'; Action = {}; Colour = 'Red' }) }) }; Message = "Card 'C': unknown key 'Colour'" }
        @{ Case = 'a button without an action'; Definition = @{ Tab = 'T'; Cards = @(@{ Card = 'C'; Items = @(@{ Button = 'B' }) }) }; Message = "Card 'C': 'Action' is missing" }
        @{ Case = 'an action that is not a script block'; Definition = @{ Tab = 'T'; Cards = @(@{ Card = 'C'; Items = @(@{ Button = 'B'; Action = 'Update-Windows' }) }) }; Message = "Card 'C', button 'B': 'Action' must be a script block" }
        @{ Case = 'a checkbox without a name'; Definition = @{ Tab = 'T'; Cards = @(@{ Card = 'C'; Items = @(@{ CheckBox = 'X' }) }) }; Message = "Card 'C': 'Name' is missing" }
        @{ Case = 'an OnClick that is not a script block'; Definition = @{ Tab = 'T'; Cards = @(@{ Card = 'C'; Items = @(@{ CheckBox = 'X'; Name = 'X'; OnClick = 'Set-CheckboxState' }) }) }; Message = "Card 'C', checkbox 'X': 'OnClick' must be a script block" }
        @{ Case = 'two checkboxes with one name'; Definition = @{ Tab = 'T'; Cards = @(@{ Card = 'C'; Items = @(@{ CheckBox = 'X'; Name = 'X' }, @{ CheckBox = 'Y'; Name = 'X' }) }) }; Message = "Card 'C', checkbox 'Y': a checkbox named 'X' already exists" }
        @{ Case = 'two buttons with one name'; Definition = @{ Tab = 'T'; Cards = @(@{ Card = 'C'; Items = @(@{ Button = 'X'; Name = 'X'; Action = {} }, @{ Button = 'Y'; Name = 'X'; Action = {} }) }) }; Message = "Card 'C', button 'Y': a button named 'X' already exists" }
    ) {
        { New-Tab $TabControl $Definition $Checkboxes $Buttons } | Should -Throw -ExpectedMessage $Message
    }
}
