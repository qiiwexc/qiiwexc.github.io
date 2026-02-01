function Set-PrivacyConfiguration {
    try {
        Set-Variable -Option Constant TelemetryTaskList (
            [hashtable[]]@(
                @{Name = 'Consolidator'; Path = 'Microsoft\Windows\Customer Experience Improvement Program' },
                @{Name = 'DmClient'; Path = 'Microsoft\Windows\Feedback\Siuf' },
                @{Name = 'DmClientOnScenarioDownload'; Path = 'Microsoft\Windows\Feedback\Siuf' },
                @{Name = 'MareBackup'; Path = 'Microsoft\Windows\Application Experience' },
                @{Name = 'Microsoft-Windows-DiskDiagnosticDataCollector'; Path = 'Microsoft\Windows\DiskDiagnostic' },
                @{Name = 'PcaPatchDbTask'; Path = 'Microsoft\Windows\Application Experience' },
                @{Name = 'Proxy'; Path = 'Microsoft\Windows\Autochk' },
                @{Name = 'QueueReporting'; Path = 'Microsoft\Windows\Windows Error Reporting' },
                @{Name = 'StartupAppTask'; Path = 'Microsoft\Windows\Application Experience' },
                @{Name = 'UsbCeip'; Path = 'Microsoft\Windows\Customer Experience Improvement Program' }
            )
        )

        foreach ($Task in $TelemetryTaskList) {
            Disable-ScheduledTask -TaskName $Task.Name -TaskPath $Task.Path -ErrorAction Stop
        }
    } catch {
        Out-Failure "Failed to disable telemetry tasks: $_"
    }

    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_PRIVACY

    try {
        foreach ($User in (Get-UsersRegistryKeys)) {
            $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n")
            $ConfigLines.Add("`"RotatingLockScreenOverlayEnabled`"=dword:00000000`n")

            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]`n")
            $ConfigLines.Add("`"DoNotTrack`"=dword:00000001`n")

            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]`n")
            $ConfigLines.Add("`"EnableCortana`"=dword:00000000`n")
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
