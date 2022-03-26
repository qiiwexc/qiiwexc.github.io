Function New-ButtonUAC {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [Switch]$Disabled = $False,
        [String]$ToolTip
    )

    Return New-Button $Text $Function -ToolTip $ToolTip -Disabled:$Disabled -UAC
}

Function New-ButtonBrowser {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [String]$ToolTip
    )

    [System.Drawing.Point]$Shift = "0, $(if ($PREVIOUS_BUTTON) { $INTERVAL_NORMAL } else { 0 })"

    [System.Windows.Forms.Button]$Button = New-Button $Text $Function -Shift $Shift -ToolTip $ToolTip

    [System.Drawing.Point]$LabelLocation = ($PREVIOUS_BUTTON.Location + "$INTERVAL_LONG, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)")
    New-Label 'Opens in the browser' $LabelLocation > $Null

    Return $Button
}

Function New-Button {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [System.Drawing.Point]$Shift,
        [Switch]$Disabled = $False,
        [Switch]$UAC = $False,
        [String]$ToolTip
    )

    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)

    $Button.Font = $BUTTON_FONT
    $Button.Height = $BUTTON_HEIGHT
    $Button.Width = $BUTTON_WIDTH

    $Button.Enabled = -not $Disabled

    [System.Drawing.Point]$InitLocation = if ($PREVIOUS_BUTTON) { $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL } else { $INITIAL_LOCATION_BUTTON }
    [System.Drawing.Point]$Location = if ($Shift) { ($InitLocation + $Shift) } else { $InitLocation }
    $Button.Location = $Location

    $Button.Text = "$(if (-not $UAC -or $IS_ELEVATED) { $Text } else { "$Text *" })"

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($Button, $ToolTip) }

    $Button.Add_Click($Function)

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_BUTTON_NORMAL
    $CURRENT_GROUP.Controls.Add($Button)

    Set-Variable -Scope Script PREVIOUS_BUTTON $Button

    Return $Button
}
