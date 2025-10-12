function New-Label {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text
    )

    Set-Variable -Option Constant Label (New-Object Windows.Forms.Label)

    [Drawing.Point]$Location = $PREVIOUS_BUTTON.Location + "30, $BUTTON_HEIGHT"

    $Label.Size = "145, $CHECKBOX_HEIGHT"
    $Label.Text = $Text
    $Label.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
    $CURRENT_GROUP.Controls.Add($Label)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Label
}
