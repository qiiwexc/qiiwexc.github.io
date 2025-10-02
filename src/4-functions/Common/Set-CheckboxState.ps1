function Set-CheckboxState {
    param(
        [System.Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory = $True)]$Control,
        [System.Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory = $True)]$Dependant
    )

    $Dependant.Enabled = $Control.Checked

    if (-not $Dependant.Enabled) {
        $Dependant.Checked = $False
    }
}
