function Set-WindowsPersonalisationConfig {
    Write-ActivityProgress 80 'Applying Windows personalisation configuration...'

    try {
        Set-WinHomeLocation -GeoId 140 -ErrorAction Stop
    } catch {
        Out-Failure "Failed to set home location to Latvia: $_"
    }

    try {
        Set-Variable -Option Constant LanguageList ([Collections.Generic.List[PSCustomObject]](Get-WinUserLanguageList -ErrorAction Stop))
        if (-not ($LanguageList | Where-Object LanguageTag -Like 'lv')) {
            $LanguageList.Add('lv')
            Set-WinUserLanguageList $LanguageList -Force -ErrorAction Stop
        }
    } catch {
        Out-Failure "Failed to add Latvian language to user language list: $_"
    }

    [Collections.Generic.List[String]]$ConfigLines = $CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER)
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE)

    Write-ActivityProgress 90

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
