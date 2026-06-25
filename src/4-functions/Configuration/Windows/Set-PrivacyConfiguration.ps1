function Set-PrivacyConfiguration {
    try {
        Set-Variable -Option Constant TelemetryTaskList (
            [Hashtable[]]@(
                @{Name = 'DmClient'; Path = 'Microsoft\Windows\Feedback\Siuf' },
                @{Name = 'DmClientOnScenarioDownload'; Path = 'Microsoft\Windows\Feedback\Siuf' },
                @{Name = 'PcaPatchDbTask'; Path = 'Microsoft\Windows\Application Experience' },
                @{Name = 'QueueReporting'; Path = 'Microsoft\Windows\Windows Error Reporting' },
                @{Name = 'MareBackup'; Path = 'Microsoft\Windows\Application Experience' }
            )
        )

        foreach ($Task in $TelemetryTaskList) {
            Disable-ScheduledTask -TaskName $Task.Name -TaskPath $Task.Path -ErrorAction Stop
        }
    } catch {
        Out-Failure "Failed to disable telemetry task $($Task.Name): $_"
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
