Function New-Tab {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Set-Variable -Option Constant TabPage (New-Object System.Windows.Forms.TabPage)

    $TabPage.UseVisualStyleBackColor = $True
    $TabPage.Text = $Text

    $TAB_CONTROL.Controls.Add($TabPage)

    Set-Variable -Scope Script PREVIOUS_GROUP $Null
    Set-Variable -Scope Script CURRENT_TAB $TabPage
}

Function New-GroupBox {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [Int][Parameter(Position = 1)]$IndexOverride
    )

    Set-Variable -Option Constant GroupBox (New-Object System.Windows.Forms.GroupBox)

    Set-Variable -Scope Script PREVIOUS_GROUP $CURRENT_GROUP

    [Int]$GroupIndex = 0

    if ($IndexOverride) {
        $GroupIndex = $IndexOverride
    }
    else {
        $CURRENT_TAB.Controls | ForEach-Object { $GroupIndex += $_.Length }
    }

    if ($GroupIndex -lt 3) {
        Set-Variable -Option Constant Location $(if ($GroupIndex -eq 0) { "15, 15" } else { $PREVIOUS_GROUP.Location + "$($GROUP_WIDTH + 15), 0" })
    }
    else {
        Set-Variable -Option Constant PreviousGroup $CURRENT_TAB.Controls[$GroupIndex - 3]
        Set-Variable -Option Constant Location ($PreviousGroup.Location + "0, $($PreviousGroup.Height + 15)")
    }

    $GroupBox.Width = $GROUP_WIDTH
    $GroupBox.Text = $Text
    $GroupBox.Location = $Location

    $CURRENT_TAB.Controls.Add($GroupBox)

    Set-Variable -Scope Script PREVIOUS_BUTTON $Null
    Set-Variable -Scope Script PREVIOUS_RADIO $Null
    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null

    Set-Variable -Scope Script CURRENT_GROUP $GroupBox
}
