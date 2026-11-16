function Set-PrivacyConfiguration {
    # Task paths must start and end with a backslash, otherwise no task matches
    Set-Variable -Option Constant TelemetryTaskList (
        [Hashtable[]]@(
            @{Name = 'DmClient'; Path = '\Microsoft\Windows\Feedback\Siuf\' },
            @{Name = 'DmClientOnScenarioDownload'; Path = '\Microsoft\Windows\Feedback\Siuf\' },
            @{Name = 'PcaPatchDbTask'; Path = '\Microsoft\Windows\Application Experience\' },
            @{Name = 'QueueReporting'; Path = '\Microsoft\Windows\Windows Error Reporting\' },
            @{Name = 'MareBackup'; Path = '\Microsoft\Windows\Application Experience\' }
        )
    )

    # Not every task exists on every Windows build: a missing one is expected, and skipped as quietly as a power setting
    # the system does not have. Only a task that exists and cannot be disabled is a failure, which stops none of the rest
    foreach ($Task in $TelemetryTaskList) {
        if (-not (Get-ScheduledTask -TaskName $Task.Name -TaskPath $Task.Path -ErrorAction SilentlyContinue)) {
            Write-LogDebug "Skipping telemetry task $($Task.Name), which this system does not have"
            continue
        }

        try {
            Disable-ScheduledTask -TaskName $Task.Name -TaskPath $Task.Path -ErrorAction Stop
        } catch {
            Out-Failure "Failed to disable telemetry task $($Task.Name): $_"
        }
    }

    try {
        Import-RegistryConfiguration 'Windows Privacy Config' (Add-SysPrepConfig $CONFIG_PRIVACY) -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows privacy configuration: $_"
    }
}
