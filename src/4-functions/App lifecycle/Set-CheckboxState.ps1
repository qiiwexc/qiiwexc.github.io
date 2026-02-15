function Set-CheckboxState {
    param(
        [Windows.Controls.CheckBox][Parameter(Position = 0, Mandatory)]$Control,
        [Windows.Controls.CheckBox][Parameter(Position = 1, Mandatory)]$Dependant
    )

    $Dependant.IsEnabled = $Control.IsChecked

    if (-not $Dependant.IsEnabled) {
        $Dependant.IsChecked = $False
    }
}
