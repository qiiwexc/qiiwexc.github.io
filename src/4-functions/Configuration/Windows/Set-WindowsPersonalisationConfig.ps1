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

    [String]$ConfigLines = ''

    try {
        Set-Variable -Option Constant NotificationRegistries ((Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*').Name)
        foreach ($Registry in $NotificationRegistries) {
            $ConfigLines += "`n[$Registry]`n"
            $ConfigLines += "`"IsPromoted`"=dword:00000001`n"
        }

        foreach ($User in (Get-UsersRegistryKeys)) {
            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n"
            $ConfigLines += "`"RotatingLockScreenEnabled`"=dword:00000001`n"
            $ConfigLines += "`"RotatingLockScreenOverlayEnabled`"=dword:00000001`n"

            $ConfigLines += "`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]`n"
            $ConfigLines += "`"DoNotTrack`"=dword:00000001`n"

            $ConfigLines += "`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]`n"
            $ConfigLines += "`"EnableCortana`"=dword:00000000`n"
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to read the registry'
    }

    Import-RegistryConfiguration $FileName ($CONFIG_WINDOWS_PERSONALISATION + $ConfigLines)
}
