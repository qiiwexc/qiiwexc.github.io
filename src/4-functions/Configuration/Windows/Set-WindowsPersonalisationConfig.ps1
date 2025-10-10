﻿function Set-WindowsPersonalisationConfig {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
    )

    Set-Variable -Option Constant LogIndentLevel 1

    Write-ActivityProgress -PercentComplete 90 -Task 'Applying Windows personalisation configuration...'

    Set-WinHomeLocation -GeoId 140

    Set-Variable -Option Constant LanguageList (Get-WinUserLanguageList)
    if (-not ($LanguageList | Where-Object LanguageTag -Like 'lv')) {
        $LanguageList.Add('lv')
        Set-WinUserLanguageList $LanguageList -Force
    }

    [Collections.Generic.List[String]]$ConfigLines = $CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_PERSONALISATION_HKEY_CLASSES_ROOT)
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER)
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE)

    Write-ActivityProgress -PercentComplete 95

    try {
        if ($OS_VERSION -gt 10) {
            Set-Variable -Option Constant NotificationRegistries ((Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*').Name)
            foreach ($Registry in $NotificationRegistries) {
                $ConfigLines.Add("`n[$Registry]`n")
                $ConfigLines.Add("`"IsPromoted`"=dword:00000001`n")
            }
        }

        foreach ($User in (Get-UsersRegistryKeys)) {
            $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n")
            $ConfigLines.Add("`"RotatingLockScreenEnabled`"=dword:00000001`n")
        }
    } catch [Exception] {
        Write-LogException $_ 'Failed to read the registry' $LogIndentLevel
    }

    Import-RegistryConfiguration $FileName $ConfigLines
}
