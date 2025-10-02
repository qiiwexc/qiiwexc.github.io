function Set-WindowsConfiguration {
    param(
        [System.Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory = $True)]$Base,
        [System.Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory = $True)]$PowerScheme,
        [System.Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory = $True)]$Search,
        [System.Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory = $True)]$FileAssociations,
        [System.Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory = $True)]$Personalisation
    )

    if ($Base.Checked) {
        Set-WindowsBaseConfiguration $Base.Text
    }

    if ($PowerScheme.Checked) {
        Set-PowerSchemeConfiguration
    }

    if ($Search.Checked) {
        Set-SearchConfiguration $Search.Text
    }

    if ($FileAssociations.Checked) {
        Set-FileAssociations
    }

    if ($Personalisation.Checked) {
        Set-WindowsPersonalisationConfig $Personalisation.Text
    }
}
