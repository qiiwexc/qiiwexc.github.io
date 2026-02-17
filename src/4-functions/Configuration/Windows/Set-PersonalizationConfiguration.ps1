function Set-PersonalizationConfiguration {
    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_PERSONALIZATION

    try {
        if ($OS_VERSION -ge 11) {
            $NotificationItems = Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*' -ErrorAction Stop
            if ($NotificationItems) {
                Set-Variable -Option Constant NotificationRegistries ([String[]]$NotificationItems.Name)
                foreach ($Registry in $NotificationRegistries) {
                    $ConfigLines.Add("`n[$Registry]`n")
                    $ConfigLines.Add("`"IsPromoted`"=dword:00000001`n")
                }
            }
        }

        foreach ($User in (Get-UsersRegistryKeys)) {
            $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n")
            $ConfigLines.Add("`"RotatingLockScreenEnabled`"=dword:00000001`n")
        }
    } catch {
        Out-Failure "Failed to read the registry: $_"
    }

    try {
        Import-RegistryConfiguration 'Windows Personalization Config' $ConfigLines -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows personalization configuration: $_"
    }
}
