function New-CheckBox {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text,
        [String][Parameter(Position = 1)]$Name,
        [Switch]$Padded,
        [Switch]$Disabled,
        [Switch]$Checked
    )

    Set-Variable -Option Constant CheckBox ([Windows.Forms.CheckBox](New-Object Windows.Forms.CheckBox))

    [Drawing.Point]$BaseLocation = $INITIAL_LOCATION_BUTTON
    [Drawing.Point]$Shift = '0, 0'

    if ($PREVIOUS_BUTTON) {
        $BaseLocation = $PREVIOUS_BUTTON.Location
        $Shift = "$CHECKBOX_PADDING, $($COMMON_PADDING * 2)"
    }

    if ($PREVIOUS_LABEL_OR_CHECKBOX) {
        $BaseLocation.Y = $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y

        if ($Padded) {
            $Shift = "$CHECKBOX_PADDING, $CHECKBOX_HEIGHT"
        } else {
            $Shift = "0, $INTERVAL_CHECKBOX"
        }
    }

    Set-Variable -Option Constant Location ([Drawing.Point]($BaseLocation + $Shift))

    $CheckBox.Text = $Text
    $CheckBox.Name = $Name
    $CheckBox.Checked = $Checked
    $CheckBox.Enabled = -not $Disabled
    $CheckBox.Size = "175, $CHECKBOX_HEIGHT"
    $CheckBox.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
    $CURRENT_GROUP.Controls.Add($CheckBox)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX ([Windows.Forms.CheckBox]$CheckBox)

    return $CheckBox
}
