function New-GroupBox {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text,
        [Int][Parameter(Position = 1)]$IndexOverride
    )

    Set-Variable -Option Constant GroupBox ([Windows.Forms.GroupBox](New-Object Windows.Forms.GroupBox))

    Set-Variable -Scope Script PREVIOUS_GROUP ([Windows.Forms.GroupBox]$CURRENT_GROUP)

    [Int]$GroupIndex = 0

    if ($IndexOverride) {
        $GroupIndex = $IndexOverride
    } else {
        $GroupIndex = $CURRENT_TAB.Controls.Count
    }

    if ($GroupIndex -lt 3) {
        if ($GroupIndex -eq 0) {
            Set-Variable -Option Constant BaseLocation ([Drawing.Point]"$COMMON_PADDING, $COMMON_PADDING")
            Set-Variable -Option Constant Shift ([Drawing.Point]'0, 0')
        } else {
            Set-Variable -Option Constant BaseLocation $PREVIOUS_GROUP.Location
            Set-Variable -Option Constant Shift ([Drawing.Point]"$($GROUP_WIDTH + $COMMON_PADDING), 0")
        }
    } else {
        Set-Variable -Option Constant PreviousGroup $CURRENT_TAB.Controls[$GroupIndex - 3]
        Set-Variable -Option Constant BaseLocation $PreviousGroup.Location
        Set-Variable -Option Constant Shift ([Drawing.Point]"0, $($PreviousGroup.Height + $COMMON_PADDING)")
    }

    $GroupBox.Width = $GROUP_WIDTH
    $GroupBox.Text = $Text
    $GroupBox.Location = $BaseLocation + $Shift

    $CURRENT_TAB.Controls.Add($GroupBox)

    Set-Variable -Scope Script PREVIOUS_BUTTON $Null
    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null

    Set-Variable -Scope Script CURRENT_GROUP $GroupBox
}
