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
        [Switch]$Disabled,
        [Switch]$Checked,
        [String]$ToolTip
    )

    Set-Variable -Option Constant CheckBox (New-Object System.Windows.Forms.CheckBox)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "$INTERVAL_CHECKBOX, $INTERVAL_LONG"
    }

    if ($PREVIOUS_LABEL_OR_INTERACTIVE) {
        $InitialLocation.Y = $PREVIOUS_LABEL_OR_INTERACTIVE.Location.Y

        if ($CURRENT_GROUP.Text -eq "Ninite") {
            $Shift = "0, $INTERVAL_CHECKBOX"
        }
        else {
            $Shift = "$INTERVAL_CHECKBOX, $CHECKBOX_HEIGHT"
        }
    }

    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $CheckBox.Text = $Text
    $CheckBox.Name = $Name
    $CheckBox.Checked = $Checked
    $CheckBox.Enabled = !$Disabled
    $CheckBox.Size = "145, $CHECKBOX_HEIGHT"
    $CheckBox.Location = $Location

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBox, $ToolTip) }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_LONG
    $CURRENT_GROUP.Controls.Add($CheckBox)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_INTERACTIVE $CheckBox

    Return $CheckBox
}
