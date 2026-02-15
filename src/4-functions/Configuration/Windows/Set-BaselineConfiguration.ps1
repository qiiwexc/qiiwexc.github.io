function Set-BaselineConfiguration {
    try {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value 3 -ErrorAction Stop
    } catch {
        Out-Failure "Failed to enable time zone auto update: $_"
    }

    try {
        Set-Variable -Option Constant UnelevatedExplorerTaskName ([String]'CreateExplorerShellUnelevatedTask')
        if (Get-ScheduledTask | Where-Object { $_.TaskName -eq $UnelevatedExplorerTaskName }) {
            Unregister-ScheduledTask -TaskName $UnelevatedExplorerTaskName -Confirm:$False -ErrorAction Stop
        }
    } catch {
        Out-Failure "Failed to remove unelevated Explorer scheduled task: $_"
    }

    if ($SYSTEM_LANGUAGE -match 'ru') {
        Set-Variable -Option Constant LocalisedConfig ([String]$CONFIG_BASELINE_RUSSIAN)
    } else {
        Set-Variable -Option Constant LocalisedConfig ([String]$CONFIG_BASELINE_ENGLISH)
    }

    if ($OS_VERSION -ge 11) {
        Set-Variable -Option Constant TaskManagerConfig ([String]"$env:LocalAppData\Microsoft\Windows\TaskManager\settings.json")

        if ($SYSTEM_LANGUAGE -match 'ru') {
            Set-Content $TaskManagerConfig $CONFIG_TASK_MANAGER_RUSSIAN -NoNewline
        } else {
            Set-Content $TaskManagerConfig $CONFIG_TASK_MANAGER_ENGLISH -NoNewline
        }
    }

    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_BASELINE
    $ConfigLines.Add("`n")
    $ConfigLines.Add((Add-SysPrepConfig $LocalisedConfig))

    try {
        $VolumeItems = Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*' -ErrorAction Stop
        if ($VolumeItems) {
            Set-Variable -Option Constant VolumeRegistries ([String[]]$VolumeItems.Name)
            foreach ($Registry in $VolumeRegistries) {
                $ConfigLines.Add("`n[$Registry]`n")
                $ConfigLines.Add("`"MaxCapacity`"=dword:000FFFFF`n")
            }
        }
    } catch {
        Out-Failure "Failed to read the registry: $_"
    }

    try {
        Import-RegistryConfiguration 'Windows Baseline Config' $ConfigLines -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows base configuration: $_"
    }
}
