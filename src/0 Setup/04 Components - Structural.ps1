Function New-Tab {
    Param(
        [String][Parameter(Position = 0)]$Text
    )

    Set-Variable -Option Constant Tab (New-Object System.Windows.Forms.TabPage)

    $Tab.UseVisualStyleBackColor = $True
    $Tab.Text = $Text

    $TAB_CONTROL.Controls.Add($Tab)

    Set-Variable -Scope Script CURRENT_TAB $Tab
}

Function New-GroupBox {
    Param(
        [String][Parameter(Position = 0)]$Text,
        [System.Drawing.Point][Parameter(Position = 1)]$Location
    )

    Set-Variable -Option Constant GroupBox (New-Object System.Windows.Forms.GroupBox)

    $GroupBox.Width = $GROUP_WIDTH

    $GroupBox.Text = $Text
    $GroupBox.Height = 20
    $GroupBox.Location = $Location

    $CURRENT_TAB.Controls.Add($GroupBox)

    Set-Variable -Scope Script PREVIOUS_BUTTON $False

    Set-Variable -Scope Script CURRENT_GROUP $GroupBox
    Return $GroupBox
}
