function New-Button {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [Switch]$Disabled
    )

    Set-Variable -Option Constant Button ([Windows.Forms.Button](New-Object Windows.Forms.Button))

    [Drawing.Point]$BaseLocation = $INITIAL_LOCATION_BUTTON
    [Drawing.Point]$Shift = '0, 0'

    if ($PREVIOUS_LABEL_OR_CHECKBOX) {
        $BaseLocation.Y = $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y
        $Shift = "0, $($COMMON_PADDING * 2)"
    } elseif ($PREVIOUS_BUTTON) {
        $BaseLocation = $PREVIOUS_BUTTON.Location
        $Shift = "0, $INTERVAL_BUTTON"
    }

    Set-Variable -Option Constant Location ([Drawing.Point]($BaseLocation + $Shift))

    $Button.Font = $BUTTON_FONT
    $Button.Height = $BUTTON_HEIGHT
    $Button.Width = $BUTTON_WIDTH
    $Button.Enabled = -not $Disabled
    $Button.Location = $Location

    $Button.Text = $Text

    if ($Function) {
        $Button.Add_Click($Function)
    }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_BUTTON
    $CURRENT_GROUP.Controls.Add($Button)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
    Set-Variable -Scope Script PREVIOUS_BUTTON ([Windows.Forms.Button]$Button)
}
