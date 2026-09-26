function Assert-LayoutDefinition {
    param(
        [Parameter(Position = 0, Mandatory)][AllowNull()][Object]$Definition,
        [Parameter(Position = 1, Mandatory)][String[]]$Required,
        [Parameter(Position = 2, Mandatory)][AllowEmptyCollection()][String[]]$Allowed,
        [Parameter(Position = 3, Mandatory)][String]$Where
    )

    if ($Definition -isnot [Hashtable]) {
        throw "${Where}: expected a hashtable"
    }

    foreach ($Key in $Definition.Keys) {
        if ($Key -notin ($Required + $Allowed)) {
            throw "${Where}: unknown key '$Key'"
        }
    }

    foreach ($Key in $Required) {
        if (-not $Definition[$Key]) {
            throw "${Where}: '$Key' is missing"
        }
    }
}


function Add-LayoutCheckBox {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Controls.CheckBox]$CheckBox,
        [Parameter(Position = 1, Mandatory)][Hashtable]$Definition,
        [Parameter(Position = 2, Mandatory)][Hashtable]$Checkboxes,
        [Parameter(Position = 3, Mandatory)][String]$Where
    )

    if ($Checkboxes.ContainsKey($Definition['Name'])) {
        throw "${Where}: a checkbox named '$($Definition['Name'])' already exists"
    }

    if ($Definition['OnClick']) {
        if ($Definition['OnClick'] -isnot [ScriptBlock]) {
            throw "${Where}: 'OnClick' must be a script block"
        }
        $CheckBox.Add_Click($Definition['OnClick'])
    }

    $Checkboxes[$Definition['Name']] = $CheckBox
}


function New-Tab {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Controls.TabControl]$TabControl,
        [Parameter(Position = 1, Mandatory)][Hashtable]$Definition,
        [Parameter(Position = 2, Mandatory)][Hashtable]$Checkboxes
    )

    Assert-LayoutDefinition -Definition $Definition -Required @('Tab', 'Cards') -Allowed @() -Where 'Tab'

    Set-Variable -Option Constant Page ([Windows.Controls.WrapPanel](New-TabPage $TabControl $Definition['Tab']))

    foreach ($CardDefinition in $Definition['Cards']) {
        Assert-LayoutDefinition -Definition $CardDefinition -Required @('Card', 'Items') -Allowed @() -Where "Tab '$($Definition['Tab'])'"

        [String]$CardWhere = "Card '$($CardDefinition['Card'])'"
        [Windows.Controls.StackPanel]$Card = New-Card $Page $CardDefinition['Card']

        # Every button after the card's first item is set apart from what comes before it
        [Bool]$IsFirst = $True

        foreach ($Item in $CardDefinition['Items']) {
            if ($Item -is [Hashtable] -and $Item.ContainsKey('CheckBox')) {
                Assert-LayoutDefinition -Definition $Item -Required @('CheckBox', 'Name') -Allowed @('Tag', 'Checked', 'Disabled', 'OnClick') -Where $CardWhere

                [Windows.Controls.CheckBox]$CheckBox = New-CheckBox $Card $Item['CheckBox'] -Tag ([String]$Item['Tag']) -Checked:([Bool]$Item['Checked']) -Disabled:([Bool]$Item['Disabled'])
                Add-LayoutCheckBox -CheckBox $CheckBox -Definition $Item -Checkboxes $Checkboxes -Where "$CardWhere, checkbox '$($Item['CheckBox'])'"
            } else {
                Assert-LayoutDefinition -Definition $Item -Required @('Button', 'Action') -Allowed @('Disabled', 'Browser', 'StartAfterDownload', 'Options') -Where $CardWhere

                [String]$ButtonWhere = "$CardWhere, button '$($Item['Button'])'"
                if ($Item['Action'] -isnot [ScriptBlock]) {
                    throw "${ButtonWhere}: 'Action' must be a script block"
                }

                if ($Item['Browser']) {
                    [Void](New-ButtonBrowser -Parent $Card -Text $Item['Button'] -Function $Item['Action'] -Spaced:(-not $IsFirst))
                } else {
                    [Void](New-Button -Parent $Card -Text $Item['Button'] -Function $Item['Action'] -Disabled:([Bool]$Item['Disabled']) -Spaced:(-not $IsFirst))
                }

                # A button's options join its 'Start after download' checkbox's centred group, if it has one
                [Windows.Controls.Panel]$OptionsPanel = $Card
                [Bool]$Centered = $False

                if ($Item['StartAfterDownload']) {
                    Assert-LayoutDefinition -Definition $Item['StartAfterDownload'] -Required @('Name') -Allowed @('OnClick') -Where "$ButtonWhere, 'StartAfterDownload'"

                    [Windows.Controls.CheckBox]$StartCheckBox = New-CheckBoxRunAfterDownload $Card -Checked
                    Add-LayoutCheckBox -CheckBox $StartCheckBox -Definition $Item['StartAfterDownload'] -Checkboxes $Checkboxes -Where "$ButtonWhere, 'StartAfterDownload'"

                    $OptionsPanel = $StartCheckBox.Parent
                    $Centered = $True
                }

                foreach ($Option in @($Item['Options'] | Where-Object { $_ })) {
                    [String]$OptionWhere = "$ButtonWhere, option"
                    Assert-LayoutDefinition -Definition $Option -Required @('CheckBox', 'Name') -Allowed @('Tag', 'Checked', 'Disabled', 'OnClick') -Where $OptionWhere

                    [Windows.Controls.CheckBox]$OptionCheckBox = New-CheckBox $OptionsPanel $Option['CheckBox'] -Tag ([String]$Option['Tag']) -Checked:([Bool]$Option['Checked']) -Disabled:([Bool]$Option['Disabled']) -Centered:$Centered
                    Add-LayoutCheckBox -CheckBox $OptionCheckBox -Definition $Option -Checkboxes $Checkboxes -Where "$OptionWhere '$($Option['CheckBox'])'"
                }
            }

            $IsFirst = $False
        }
    }
}
