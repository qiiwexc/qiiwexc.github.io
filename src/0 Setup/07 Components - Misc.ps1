Function New-Label {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Set-Variable -Option Constant Label (New-Object System.Windows.Forms.Label)

    [System.Drawing.Point]$Location = ($PREVIOUS_BUTTON.Location + "30, $BUTTON_HEIGHT")

    $Label.Size = "145, $CHECKBOX_HEIGHT"
    $Label.Text = $Text
    $Label.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
    $CURRENT_GROUP.Controls.Add($Label)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Label
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

    if ($PREVIOUS_RADIO) {
        $InitialLocation.X = $PREVIOUS_BUTTON.Location.X
        $InitialLocation.Y = $PREVIOUS_RADIO.Location.Y
        $Shift = "90, 0"
    }
    elseif ($PREVIOUS_LABEL_OR_CHECKBOX) {
        $InitialLocation = $PREVIOUS_LABEL_OR_CHECKBOX.Location
        $Shift = "-15, 20"
    }
    elseif ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "10, $BUTTON_HEIGHT"
    }

    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $RadioButton.Text = $Text
    $RadioButton.Checked = $Checked
    $RadioButton.Enabled = !$Disabled
    $RadioButton.Size = "80, $CHECKBOX_HEIGHT"
    $RadioButton.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
    $CURRENT_GROUP.Controls.Add($RadioButton)

    Set-Variable -Scope Script PREVIOUS_RADIO $RadioButton

    Return $RadioButton
}
