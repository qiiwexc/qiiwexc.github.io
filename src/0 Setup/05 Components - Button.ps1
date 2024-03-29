Function New-ButtonBrowser {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1, Mandatory = $True)]$Function
    )

    New-Button $Text $Function > $Null

    New-Label 'Opens in the browser' > $Null
}

Function New-Button {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [Switch]$Disabled,
        [Switch]$UAC
    )

    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_LABEL_OR_CHECKBOX -or $PREVIOUS_RADIO) {
        $PreviousLabelOrCheckboxY = if ($PREVIOUS_LABEL_OR_CHECKBOX) { $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y } else { 0 }
        $PreviousRadioY = if ($PREVIOUS_RADIO) { $PREVIOUS_RADIO.Location.Y } else { 0 }

        $PreviousMiscElement = if ($PreviousLabelOrCheckboxY -gt $PreviousRadioY) { $PreviousLabelOrCheckboxY } else { $PreviousRadioY }

        $InitialLocation.Y = $PreviousMiscElement
        $Shift = "0, 30"
    }
    elseif ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "0, $INTERVAL_BUTTON"
    }


    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $Button.Font = $BUTTON_FONT
    $Button.Height = $BUTTON_HEIGHT
    $Button.Width = $BUTTON_WIDTH
    $Button.Enabled = !$Disabled
    $Button.Location = $Location

    $Button.Text = if ($UAC) { "$Text$REQUIRES_ELEVATION" } else { $Text }

    if ($Function) { $Button.Add_Click($Function) }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_BUTTON
    $CURRENT_GROUP.Controls.Add($Button)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
    Set-Variable -Scope Script PREVIOUS_RADIO $Null
    Set-Variable -Scope Script PREVIOUS_BUTTON $Button

    Return $Button
}
