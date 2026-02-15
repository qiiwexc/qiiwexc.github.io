function Set-CheckboxState {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Controls.CheckBox]$Control,
        [Parameter(Position = 1, Mandatory)][Windows.Controls.CheckBox]$Dependant
    )

    $Dependant.IsEnabled = $Control.IsChecked

    if (-not $Dependant.IsEnabled) {
        $Dependant.IsChecked = $False
    }
}
