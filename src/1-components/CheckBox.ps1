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

    if ($script:LayoutContext.CenteredCheckboxGroup) {
        $CheckBox.Margin = [Windows.Thickness]::new(0, 4, 0, 4)
        [void]$script:LayoutContext.CenteredCheckboxGroup.Children.Add($CheckBox)
    } else {
        $CheckBox.Margin = [Windows.Thickness]::new(10, 4, 0, 4)
        [void]$script:LayoutContext.CurrentGroup.Children.Add($CheckBox)
    }

    $script:LayoutContext.PreviousLabelOrCheckbox = [Windows.Controls.CheckBox]$CheckBox
    $script:LayoutContext.PreviousButton = $Null

    return $CheckBox
}
