function Set-WindowsPersonalisationConfig {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
    )

    Write-LogInfo 'Applying Windows personalisation configuration...'

    Set-WinHomeLocation -GeoId 140

    Set-Variable -Option Constant LanguageList (Get-WinUserLanguageList)
    if (-not ($LanguageList | Where-Object LanguageTag -Like 'lv')) {
        $LanguageList.Add('lv-LV')
        Set-WinUserLanguageList $LanguageList -Force
    }

    [String]$ConfigLines = $CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')

    $ConfigLines += $CONFIG_WINDOWS_PERSONALISATION_HKEY_CLASSES_ROOT
    $ConfigLines += $CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER
    $ConfigLines += $CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE

    try {
        if ($OS_VERSION -gt 10) {
            Set-Variable -Option Constant NotificationRegistries ((Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*').Name)
            foreach ($Registry in $NotificationRegistries) {
                $ConfigLines += "`n[$Registry]`n"
                $ConfigLines += "`"IsPromoted`"=dword:00000001`n"
            }
        }

        foreach ($User in (Get-UsersRegistryKeys)) {
            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n"
            $ConfigLines += "`"RotatingLockScreenEnabled`"=dword:00000001`n"
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to read the registry'
    }

    Import-RegistryConfiguration $FileName $ConfigLines
}
