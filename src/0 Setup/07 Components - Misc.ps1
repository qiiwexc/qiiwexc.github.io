Function New-Label {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Set-Variable -Option Constant Label (New-Object System.Windows.Forms.Label)

    [System.Drawing.Point]$Location = ($PREVIOUS_BUTTON.Location + "$INTERVAL_LONG, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)")

    $Label.Size = "145, $CHECKBOX_HEIGHT"
    $Label.Text = $Text
    $Label.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_LONG
    $CURRENT_GROUP.Controls.Add($Label)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_INTERACTIVE $Label
}

Function New-RadioButton {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [Switch]$Checked,
        [Switch]$Disabled
    )

    Set-Variable -Option Constant RadioButton (New-Object System.Windows.Forms.RadioButton)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "10, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
    }

    if ($PREVIOUS_LABEL_OR_INTERACTIVE) {
        $InitialLocation.Y = $PREVIOUS_LABEL_OR_INTERACTIVE.Location.Y
        $Shift = "95, 0"
    }

    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $RadioButton.Text = $Text
    $RadioButton.Checked = $Checked
    $RadioButton.Enabled = !$Disabled
    $RadioButton.Size = "80, $CHECKBOX_HEIGHT"
    $RadioButton.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_LONG
    $CURRENT_GROUP.Controls.Add($RadioButton)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_INTERACTIVE $RadioButton

    Return $RadioButton
}
