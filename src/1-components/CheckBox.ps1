function New-CheckBox {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Text,
        [Parameter(Position = 1)][String]$Name,
        [Switch]$Disabled,
        [Switch]$Checked
    )

    Set-Variable -Option Constant CheckBox ([Windows.Controls.CheckBox](New-Object Windows.Controls.CheckBox))

    $CheckBox.Content = $Text
    $CheckBox.Tag = $Name
    $CheckBox.IsChecked = [Bool]$Checked
    $CheckBox.IsEnabled = -not $Disabled
    $CheckBox.Style = $FORM.FindResource('Win11CheckBox')

    if ($CENTERED_CHECKBOX_GROUP) {
        $CheckBox.Margin = [Windows.Thickness]::new(0, 4, 0, 4)
        [void]$CENTERED_CHECKBOX_GROUP.Children.Add($CheckBox)
    } else {
        $CheckBox.Margin = [Windows.Thickness]::new(10, 4, 0, 4)
        [void]$CURRENT_GROUP.Children.Add($CheckBox)
    }

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX ([Windows.Controls.CheckBox]$CheckBox)
    Set-Variable -Scope Script PREVIOUS_BUTTON $Null

    return $CheckBox
}
