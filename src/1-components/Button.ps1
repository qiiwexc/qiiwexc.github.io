function New-Button {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [Switch]$Disabled
    )

    Set-Variable -Option Constant Button (New-Object Windows.Forms.Button)

    [Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [Drawing.Point]$Shift = '0, 0'

    if ($PREVIOUS_LABEL_OR_CHECKBOX -or $PREVIOUS_RADIO) {
        [Int]$PreviousLabelOrCheckboxY = if ($PREVIOUS_LABEL_OR_CHECKBOX) { $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y } else { 0 }
        [Int]$PreviousRadioY = if ($PREVIOUS_RADIO) { $PREVIOUS_RADIO.Location.Y } else { 0 }

        [Int]$PreviousMiscElement = if ($PreviousLabelOrCheckboxY -gt $PreviousRadioY) { $PreviousLabelOrCheckboxY } else { $PreviousRadioY }

        $InitialLocation.Y = $PreviousMiscElement
        $Shift = '0, 30'
    } elseif ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "0, $INTERVAL_BUTTON"
    }


    [Drawing.Point]$Location = $InitialLocation + $Shift

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
    Set-Variable -Scope Script PREVIOUS_RADIO $Null
    Set-Variable -Scope Script PREVIOUS_BUTTON $Button
}
