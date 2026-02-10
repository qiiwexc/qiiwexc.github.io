function Set-WindowsConfiguration {
    param(
        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$Security,
        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$Performance,
        [Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory)]$Baseline,
        [Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory)]$Annoyances,
        [Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory)]$Privacy,
        [Windows.Forms.CheckBox][Parameter(Position = 5, Mandatory)]$Localisation,
        [Windows.Forms.CheckBox][Parameter(Position = 6, Mandatory)]$Personalisation
    )

    if (Assert-WindowsDebloatIsRunning) {
        Write-LogWarning 'Windows debloat utility is currently running, which may interfere with the Windows configuration process'
        Write-LogWarning 'Repeat the attempt after the debloat utility has finished running'
        return
    }

    if (Assert-OOShutUp10IsRunning) {
        Write-LogWarning 'OOShutUp10++ utility is running, which may interfere with the Windows configuration process'
        Write-LogWarning 'Repeat the attempt after OOShutUp10++ utility has finished running'
        return
    }

    New-Activity 'Configuring Windows'

    if ($Security.Checked) {
        Write-ActivityProgress 10 'Applying malware protection configuration...'
        Set-MalwareProtectionConfiguration

        Write-ActivityProgress 20 'Applying Windows security configuration...'
        Set-SecurityConfiguration
    }

    if ($Performance.Checked) {
        Write-ActivityProgress 30 'Applying Windows power scheme settings...'
        Set-PowerSchemeConfiguration

        Write-ActivityProgress 40 'Applying Windows performance configuration...'
        Set-PerformanceConfiguration
    }

    if ($Baseline.Checked) {
        Write-ActivityProgress 50 'Applying Windows baseline configuration...'
        Set-BaselineConfiguration
    }

    if ($Annoyances.Checked) {
        Write-ActivityProgress 60 'Removing Windows ads and annoyances...'
        Remove-Annoyances
    }

    if ($Privacy.Checked) {
        Write-ActivityProgress 70 'Removing Windows telemetry and improving privacy...'
        Set-PrivacyConfiguration
    }

    if ($Localisation.Checked) {
        Write-ActivityProgress 80 'Applying Windows localisation configuration...'
        Set-LocalisationConfiguration
    }

    if ($Personalisation.Checked) {
        Write-ActivityProgress 90 'Applying Windows personalisation configuration...'
        Set-PersonalisationConfiguration
    }

    Write-ActivityCompleted
}
