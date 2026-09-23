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

    # Not every task exists on every Windows build — a missing one must not stop the rest
    foreach ($Task in $TelemetryTaskList) {
        try {
            Disable-ScheduledTask -TaskName $Task.Name -TaskPath $Task.Path -ErrorAction Stop
        } catch {
            Out-Failure "Failed to disable telemetry task $($Task.Name): $_"
        }
    }

    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_PRIVACY

    try {
        foreach ($User in (Get-UsersRegistryKeys)) {
            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]`n")
            $ConfigLines.Add("`"DoNotTrack`"=dword:00000001`n")
        }
    } catch {
        Out-Failure "Failed to read the registry: $_"
    }

    try {
        Import-RegistryConfiguration 'Windows Privacy Config' $ConfigLines -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows privacy configuration: $_"
    }
}
