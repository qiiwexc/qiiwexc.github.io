function Set-WindowsPersonalisationConfig {
    try {
        Write-ActivityProgress 60 'Setting home location to Latvia...'
        Set-WinHomeLocation -GeoId 140 -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to set home location to Latvia: $_"
    }

    try {
        Set-Variable -Option Constant LanguageList ([PSObject](Get-WinUserLanguageList -ErrorAction Stop))
        if (-not ($LanguageList | Where-Object { $_.LanguageTag -like 'lv' })) {
            Write-ActivityProgress 70 'Adding Latvian language to user language list...'
            $LanguageList.Add('lv')
            Set-WinUserLanguageList $LanguageList -Force -ErrorAction Stop
            Out-Success
        }
    } catch {
        Out-Failure "Failed to add Latvian language to user language list: $_"
    }

    Write-ActivityProgress 80 'Building Windows personalisation configuration...'

    [Collections.Generic.List[String]]$ConfigLines = Get-SysPrepConfig $CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER)
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE)

    try {
        if ($OS_VERSION -gt 10) {
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

        Out-Success
    } catch {
        Out-Failure "Failed to read the registry: $_"
    }

    try {
        Write-ActivityProgress 90 'Applying Windows personalisation configuration...'
        Import-RegistryConfiguration 'Windows Personalisation Config' $ConfigLines -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows personalisation configuration: $_"
    }
}
