Function New-ButtonBrowser {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1, Mandatory = $True)]$Function,
        [String]$ToolTip
    )

    New-Button $Text $Function -ToolTip $ToolTip > $Null

    New-Label 'Opens in the browser' > $Null
}

Function New-Button {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [Switch]$Disabled,
        [Switch]$UAC,
        [String]$ToolTip
    )

    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)

    [System.Drawing.Point]$InitialLocation = if ($PREVIOUS_BUTTON) { $PREVIOUS_BUTTON.Location } else { $INITIAL_LOCATION_BUTTON }
    [System.Drawing.Point]$Shift = "0, $(if ($PREVIOUS_LABEL_OR_CHECKBOX) { $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y } elseif ($PREVIOUS_BUTTON) { $INTERVAL_BUTTON_NORMAL } else { 0 })"
    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $Button.Font = $BUTTON_FONT
    $Button.Height = $BUTTON_HEIGHT
    $Button.Width = $BUTTON_WIDTH
    $Button.Enabled = !$Disabled
    $Button.Location = $Location

    $Button.Text = if (!$UAC -or $IS_ELEVATED) { $Text } else { "$Text$REQUIRES_ELEVATION" }

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($Button, $ToolTip) }
    if ($Function) { $Button.Add_Click($Function) }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_BUTTON_NORMAL
    $CURRENT_GROUP.Controls.Add($Button)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
    Set-Variable -Scope Script PREVIOUS_BUTTON $Button

    Return $Button
}