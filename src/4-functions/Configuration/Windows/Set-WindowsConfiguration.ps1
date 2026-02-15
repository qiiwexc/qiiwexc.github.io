function Set-WindowsConfiguration {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Security,
        [Object][Parameter(Position = 1, Mandatory)]$Performance,
        [Object][Parameter(Position = 2, Mandatory)]$Baseline,
        [Object][Parameter(Position = 3, Mandatory)]$Annoyances,
        [Object][Parameter(Position = 4, Mandatory)]$Privacy,
        [Object][Parameter(Position = 5, Mandatory)]$Localisation,
        [Object][Parameter(Position = 6, Mandatory)]$Personalisation
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

    if ($Security.IsChecked) {
        Write-ActivityProgress 10 'Applying malware protection configuration...'
        Set-MalwareProtectionConfiguration

        Write-ActivityProgress 20 'Applying Windows security configuration...'
        Set-SecurityConfiguration
    }

    if ($Performance.IsChecked) {
        Write-ActivityProgress 30 'Applying Windows power scheme settings...'
        Set-PowerSchemeConfiguration

        Write-ActivityProgress 40 'Applying Windows performance configuration...'
        Set-PerformanceConfiguration
    }

    if ($Baseline.IsChecked) {
        Write-ActivityProgress 50 'Applying Windows baseline configuration...'
        Set-BaselineConfiguration
    }

    if ($Annoyances.IsChecked) {
        Write-ActivityProgress 60 'Removing Windows ads and annoyances...'
        Remove-Annoyances
    }

    if ($Privacy.IsChecked) {
        Write-ActivityProgress 70 'Removing Windows telemetry and improving privacy...'
        Set-PrivacyConfiguration
    }

    if ($Localisation.IsChecked) {
        Write-ActivityProgress 80 'Applying Windows localisation configuration...'
        Set-LocalisationConfiguration
    }

    if ($Personalisation.IsChecked) {
        Write-ActivityProgress 90 'Applying Windows personalisation configuration...'
        Set-PersonalisationConfiguration
    }

    Write-ActivityCompleted
}
