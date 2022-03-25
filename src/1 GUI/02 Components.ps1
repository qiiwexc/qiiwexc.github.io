Function New-Button {
    Param(
        [System.Windows.Forms.GroupBox][Parameter(Position = 0)]$GroupBox,
        [String][Parameter(Position = 1)]$Text,
        [System.Drawing.Point][Parameter(Position = 2)]$Location,
        [ScriptBlock][Parameter(Position = 3)]$Function,
        [Switch]$Disabled = $False,
        [Switch]$UAC = $False,
        [String]$ToolTip
    )

    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)

    $Button.Font = $BUTTON_FONT
    $Button.Height = $HEIGHT_BUTTON
    $Button.Width = $WIDTH_BUTTON

    $Button.Enabled = -not $Disabled
    $Button.Location = $Location

    $Button.Text = "$(if (-not $UAC -or $IS_ELEVATED) { $Text } else { "$Text *" })"

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($Button, $ToolTip) }

    $Button.Add_Click($Function)

    $GroupBox.Controls.Add($Button)

    Return $Button
}
