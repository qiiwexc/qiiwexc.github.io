function Set-PersonalisationConfiguration {
    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_PERSONALISATION

    try {
        if ($OS_VERSION -ge 11) {
            Set-Variable -Option Constant NotificationRegistries ([String[]](Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*' -ErrorAction Stop).Name)
            foreach ($Registry in $NotificationRegistries) {
                $ConfigLines.Add("`n[$Registry]`n")
                $ConfigLines.Add("`"IsPromoted`"=dword:00000001`n")
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
        Import-RegistryConfiguration 'Windows Personalisation Config' $ConfigLines -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows personalisation configuration: $_"
    }
}
