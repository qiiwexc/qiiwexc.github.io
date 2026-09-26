function New-CheckBox {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Controls.Panel]$Parent,
        [Parameter(Position = 1, Mandatory)][String]$Text,
        [String]$Tag,
        [Switch]$Disabled,
        [Switch]$Checked,
        # In the centred group of a 'Start after download' checkbox, which it lines up with
        [Switch]$Centered
    )

    Set-Variable -Option Constant CheckBox ([Windows.Controls.CheckBox](New-Object Windows.Controls.CheckBox))

    $CheckBox.Content = $Text
    $CheckBox.Tag = $Tag
    $CheckBox.IsChecked = [Bool]$Checked
    $CheckBox.IsEnabled = -not $Disabled
    $CheckBox.Style = $FORM.FindResource('Win11CheckBox')

    if ($Centered) {
        $CheckBox.Margin = [Windows.Thickness]::new(0, 4, 0, 4)
    } else {
        $CheckBox.Margin = [Windows.Thickness]::new(10, 4, 0, 4)
    }

    [void]$Parent.Children.Add($CheckBox)

    return $CheckBox
}
