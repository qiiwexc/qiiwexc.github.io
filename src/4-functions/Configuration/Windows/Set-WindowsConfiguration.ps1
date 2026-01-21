function Set-WindowsConfiguration {
    param(
        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$Base,
        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$Personalisation
    )

    New-Activity 'Configuring Windows'

    if ($Base.Checked) {
        Set-WindowsBaseConfiguration
    }

    if ($Personalisation.Checked) {
        Set-WindowsPersonalisationConfig
    }

    Write-ActivityCompleted
}
