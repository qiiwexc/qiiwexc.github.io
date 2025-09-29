function Set-WindowsPersonalisationConfig {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
    )

    Write-LogInfo 'Applying Windows personalisation configuration...'

    Set-Variable -Option Constant LanguageList (Get-WinUserLanguageList)
    if (-not ($LanguageList | Where-Object LanguageTag -Like 'lv')) {
        $LanguageList.Add('lv-LV')
        Set-WinUserLanguageList $LanguageList -Force
    }

    [String]$ConfigLines = ''

    try {
        foreach ($Registry in (Get-UsersRegistryKeys)) {
            # [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]
            # `"RotatingLockScreenEnabled`"=dword:00000001
            # `"RotatingLockScreenOverlayEnabled`"=dword:00000001`n"
        }

        Set-Variable -Option Constant NotificationRegistries ((Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*').Name)
        foreach ($Registry in $NotificationRegistries) {
            $ConfigLines += "`n[$Registry]`n"
            $ConfigLines += "`"IsPromoted`"=dword:00000001`n"
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to read the registry'
    }

    Import-RegistryConfiguration $FileName ($CONFIG_WINDOWS_PERSONALISATION + $ConfigLines)
}
