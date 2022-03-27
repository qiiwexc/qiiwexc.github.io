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

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Label
}

Function New-CheckBoxRunAfterDownload {
    Param(
        [Switch]$Disabled,
        [Switch]$Checked
    )

    Return New-CheckBox $TXT_START_AFTER_DOWNLOAD  -Disabled:$Disabled -Checked:$Checked -ToolTip $TXT_TIP_START_AFTER_DOWNLOAD
}

Function New-CheckBox {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [String][Parameter(Position = 1)]$Name,
        [Switch]$NoInterval,
        [Switch]$Disabled,
        [Switch]$Checked,
        [String]$ToolTip
    )

    Set-Variable -Option Constant CheckBox (New-Object System.Windows.Forms.CheckBox)

    if (!$PREVIOUS_LABEL_OR_CHECKBOX -and !$PREVIOUS_BUTTON) {
        [System.Drawing.Point]$Location = $INITIAL_LOCATION_BUTTON + "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
    }
    else {
        if ($PREVIOUS_LABEL_OR_CHECKBOX) {
            Set-Variable -Option Constant Shift "0, $($CHECKBOX_HEIGHT + $(if ($NoInterval) { 0 } else {$INTERVAL_SHORT}))"
            Set-Variable -Option Constant Location ($PREVIOUS_LABEL_OR_CHECKBOX.Location + $Shift)
        }
        else {
            [System.Drawing.Point]$InitialLocation = if ($PREVIOUS_BUTTON) { $PREVIOUS_BUTTON.Location } else { $INITIAL_LOCATION_BUTTON }
            # Set-Variable -Option Constant InitialLocation ($InitialLocation + "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)")
            Set-Variable -Option Constant Location ($InitialLocation + "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)")
        }
    }

    $CheckBox.Text = $Text
    $CheckBox.Name = $Name
    $CheckBox.Checked = $Checked
    $CheckBox.Enabled = !$Disabled
    $CheckBox.Size = "145, $CHECKBOX_HEIGHT"
    $CheckBox.Location = $Location

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBox, $ToolTip) }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_LONG
    $CURRENT_GROUP.Controls.Add($CheckBox)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $CheckBox

    Return $CheckBox
}
