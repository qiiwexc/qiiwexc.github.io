function New-RadioButton {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text,
        [Switch]$Checked,
        [Switch]$Disabled
    )

    Set-Variable -Option Constant RadioButton ([Windows.Forms.RadioButton](New-Object Windows.Forms.RadioButton))

    [Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [Drawing.Point]$Shift = '0, 0'

    if ($PREVIOUS_RADIO) {
        $InitialLocation.X = $PREVIOUS_BUTTON.Location.X
        $InitialLocation.Y = $PREVIOUS_RADIO.Location.Y
        Set-Variable -Option Constant Shift ([Drawing.Point]'90, 0')
    } elseif ($PREVIOUS_LABEL_OR_CHECKBOX) {
        $InitialLocation = $PREVIOUS_LABEL_OR_CHECKBOX.Location
        Set-Variable -Option Constant Shift ([Drawing.Point]'-15, 20')
    } elseif ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        Set-Variable -Option Constant Shift ([Drawing.Point]"10, $BUTTON_HEIGHT")
    }

    [Drawing.Point]$Location = $InitialLocation + $Shift

    $RadioButton.Text = $Text
    $RadioButton.Checked = $Checked
    $RadioButton.Enabled = -not $Disabled
    $RadioButton.Size = "80, $CHECKBOX_HEIGHT"
    $RadioButton.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
    $CURRENT_GROUP.Controls.Add($RadioButton)

    Set-Variable -Scope Script PREVIOUS_RADIO ([Windows.Forms.RadioButton]$RadioButton)

    return $RadioButton
}
