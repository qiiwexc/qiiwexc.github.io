function Set-WindowsConfiguration {
    param(
        [Parameter(Position = 0, Mandatory)][Object]$Security,
        [Parameter(Position = 1, Mandatory)][Object]$Performance,
        [Parameter(Position = 2, Mandatory)][Object]$Baseline,
        [Parameter(Position = 3, Mandatory)][Object]$Annoyances,
        [Parameter(Position = 4, Mandatory)][Object]$Privacy,
        [Parameter(Position = 5, Mandatory)][Object]$Localization,
        [Parameter(Position = 6, Mandatory)][Object]$Personalization,
        [Switch]$RestorePoint
    )

    if (Test-WindowsDebloatIsRunning) {
        Write-LogWarning 'Windows debloat utility is currently running, which may interfere with the Windows configuration process'
        Write-LogWarning 'Repeat the attempt after the debloat utility has finished running'
        return
    }

    if (Test-OOShutUp10IsRunning) {
        Write-LogWarning 'OOShutUp10++ utility is running, which may interfere with the Windows configuration process'
        Write-LogWarning 'Repeat the attempt after OOShutUp10++ utility has finished running'
        return
    }

    New-Activity 'Configuring Windows'

    # Nothing here keeps what it overwrites: the restore point is the way back
    if ($RestorePoint) {
        Write-ActivityProgress 5 'Creating a restore point...'
        try {
            New-RestorePoint
        } catch {
            Out-Failure "Failed to create a restore point, so nothing was changed. Untick 'Create a restore point' to apply the configuration without one: $_"
            Write-ActivityCompleted $False
            return
        }
    } else {
        Write-LogWarning 'No restore point was created: these changes can only be undone by hand'
    }

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

    if ($Localization.IsChecked) {
        Write-ActivityProgress 80 'Applying Windows localization configuration...'
        Set-LocalizationConfiguration
    }

    if ($Personalization.IsChecked) {
        Write-ActivityProgress 90 'Applying Windows personalization configuration...'
        Set-PersonalizationConfiguration
    }

    Write-ActivityCompleted
}
