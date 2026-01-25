function Set-WindowsBaseConfiguration {
    Set-WindowsSecurityConfiguration

    Set-PowerSchemeConfiguration

    try {
        Write-ActivityProgress 20 'Applying currency symbol configuration...'
        Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sCurrency' -Value ([Char]0x20AC) -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to set currency symbol: $_"
    }

    try {
        Write-ActivityProgress 25 'Applying time zone auto update configuration...'
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value 3 -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to enable time zone auto update: $_"
    }

    Write-ActivityProgress 40 'Disabling telemetry tasks...'

    try {
        Set-Variable -Option Constant UnelevatedExplorerTaskName ([String]'CreateExplorerShellUnelevatedTask')
        if (Get-ScheduledTask | Where-Object { $_.TaskName -eq $UnelevatedExplorerTaskName }) {
            Unregister-ScheduledTask -TaskName $UnelevatedExplorerTaskName -Confirm:$False -ErrorAction Stop
        }
    } catch {
        Out-Failure "Failed to remove unelevated Explorer scheduled task: $_"
    }

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

        Out-Success
    } catch {
        Out-Failure "Failed to disable telemetry tasks: $_"
    }

    Write-ActivityProgress 40 'Building configuration to apply...'

    if ($SYSTEM_LANGUAGE -match 'ru') {
        Set-Variable -Option Constant LocalisedConfig ([String]$CONFIG_WINDOWS_RUSSIAN)
    } else {
        Set-Variable -Option Constant LocalisedConfig ([String]$CONFIG_WINDOWS_ENGLISH)
    }

    [Collections.Generic.List[String]]$ConfigLines = $CONFIG_WINDOWS_HKEY_CURRENT_USER.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_HKEY_CURRENT_USER)
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_HKEY_LOCAL_MACHINE)
    $ConfigLines.Add("`n")
    $ConfigLines.Add($LocalisedConfig.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT'))
    $ConfigLines.Add("`n")
    $ConfigLines.Add($LocalisedConfig)

    try {
        foreach ($User in (Get-UsersRegistryKeys)) {
            $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n")
            $ConfigLines.Add("`"RotatingLockScreenOverlayEnabled`"=dword:00000000`n")

            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]`n")
            $ConfigLines.Add("`"DoNotTrack`"=dword:00000001`n")

            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]`n")
            $ConfigLines.Add("`"EnableCortana`"=dword:00000000`n")
        }

        Set-Variable -Option Constant VolumeRegistries ([String[]](Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*' -ErrorAction Stop).Name)
        foreach ($Registry in $VolumeRegistries) {
            $ConfigLines.Add("`n[$Registry]`n")
            $ConfigLines.Add("`"MaxCapacity`"=dword:000FFFFF`n")
        }

        Out-Success
    } catch {
        Out-Failure "Failed to read the registry: $_"
    }

    try {
        Write-ActivityProgress 50 'Importing base configuration...'
        Import-RegistryConfiguration 'Windows Base Config' $ConfigLines -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows base configuration: $_"
    }
}
