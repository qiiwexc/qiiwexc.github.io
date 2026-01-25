function Set-CheckboxState {
    param(
        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$Control,
        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$Dependant
    )

    $Dependant.Enabled = $Control.Checked

    if (-not $Dependant.Enabled) {
        $Dependant.Checked = $False
    }
}
