function New-GroupBox {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text,
        [Int][Parameter(Position = 1)]$IndexOverride
    )

    Set-Variable -Option Constant GroupBox ([Windows.Forms.GroupBox](New-Object Windows.Forms.GroupBox))

    Set-Variable -Scope Script PREVIOUS_GROUP ([Windows.Forms.GroupBox]$CURRENT_GROUP)
    Set-Variable -Scope Script PAD_CHECKBOXES ([Bool]$True)

    [Int]$GroupIndex = 0

    if ($IndexOverride) {
        $GroupIndex = $IndexOverride
    } else {
        $CURRENT_TAB.Controls | ForEach-Object { $GroupIndex += $_.Length }
    }

    if ($GroupIndex -lt 3) {
        if ($GroupIndex -eq 0) {
            Set-Variable -Option Constant Location ([Drawing.Point]'15, 15')
        } else {
            Set-Variable -Option Constant Location ($PREVIOUS_GROUP.Location + [Drawing.Point]"$($GROUP_WIDTH + 15), 0")
        }
    } else {
        Set-Variable -Option Constant PreviousGroup $CURRENT_TAB.Controls[$GroupIndex - 3]
        Set-Variable -Option Constant Location ($PreviousGroup.Location + [Drawing.Point]"0, $($PreviousGroup.Height + 15)")
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
