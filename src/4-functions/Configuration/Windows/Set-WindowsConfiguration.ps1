function Set-WindowsConfiguration {
    param(
        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$Base,
        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$PowerScheme,
        [Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory)]$Personalisation
    )

    New-Activity 'Configuring Windows'

    if ($PowerScheme.Checked) {
        Set-PowerSchemeConfiguration
    }

    if ($Base.Checked) {
        Set-WindowsBaseConfiguration $Base.Text
    }

    if ($Personalisation.Checked) {
        Set-WindowsPersonalisationConfig $Personalisation.Text
    }

    Write-ActivityCompleted
}
