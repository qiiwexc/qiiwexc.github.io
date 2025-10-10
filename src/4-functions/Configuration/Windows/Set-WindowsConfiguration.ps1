function Set-WindowsConfiguration {
    param(
        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory = $True)]$Base,
        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory = $True)]$PowerScheme,
        [Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory = $True)]$Search,
        [Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory = $True)]$FileAssociations,
        [Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory = $True)]$Personalisation
    )

    New-Activity 'Configuring Windows...'

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

    Write-ActivityCompleted
}
