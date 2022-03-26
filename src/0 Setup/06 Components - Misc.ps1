Function New-Label {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [System.Drawing.Point][Parameter(Position = 1)]$Location
    )

    Set-Variable -Option Constant Label (New-Object System.Windows.Forms.Label)

    $Label.Size = $CHECKBOX_SIZE

    $Label.Text = $Text
    $Label.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $Label.Height + $INTERVAL_SHORT
    $CURRENT_GROUP.Controls.Add($Label)

    Set-Variable -Scope Script PREVIOUS_LABEL $Label
}

Function New-CheckBox {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock]$Hook,
        [Switch]$Disabled = $False,
        [Switch]$Checked,
        [String]$ToolTip
    )

    Set-Variable -Option Constant CheckBox (New-Object System.Windows.Forms.CheckBox)

    $CheckBox.Size = $CHECKBOX_SIZE

    $CheckBox.Enabled = -not $Disabled
    $CheckBox.Checked = $Checked
    $CheckBox.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
    $CheckBox.Text = $Text

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBox, $ToolTip) }
    if ($Hook) { $CheckBox.Add_CheckStateChanged($Hook) }

    $CURRENT_GROUP.Height = $Location.Y + $CheckBox.Height + $INTERVAL_SHORT
    $CURRENT_GROUP.Controls.Add($CheckBox)

    Return $CheckBox
}
