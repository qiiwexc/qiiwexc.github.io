function Set-WindowsBaseConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$FileName
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Write-ActivityProgress 60 'Applying Windows configuration...'

    Set-WindowsSecurityConfiguration

    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sCurrency' -Value ([Char]0x20AC)
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value 3

    Set-Variable -Option Constant UnelevatedExplorerTaskName ([String]'CreateExplorerShellUnelevatedTask')
    if (Get-ScheduledTask | Where-Object { $_.TaskName -eq $UnelevatedExplorerTaskName } ) {
        Unregister-ScheduledTask -TaskName $UnelevatedExplorerTaskName -Confirm:$False
    }

    if ($SYSTEM_LANGUAGE -match 'ru') {
        Set-Variable -Option Constant LocalisedConfig ([String[]]$CONFIG_WINDOWS_RUSSIAN)
    } else {
        Set-Variable -Option Constant LocalisedConfig ([String[]]$CONFIG_WINDOWS_ENGLISH)
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

    Write-ActivityProgress 70

    try {
        foreach ($Registry in (Get-UsersRegistryKeys)) {
            [String]$User = $Registry.Replace('HKEY_USERS\', '')
            $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n")
            $ConfigLines.Add("`"RotatingLockScreenOverlayEnabled`"=dword:00000000`n")

            $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\InstallService\Stubification\$User]`n")
            $ConfigLines.Add("`"EnableAppOffloading`"=dword:00000000`n")

            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]`n")
            $ConfigLines.Add("`"DoNotTrack`"=dword:00000001`n")

            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]`n")
            $ConfigLines.Add("`"EnableCortana`"=dword:00000000`n")
        }

        Set-Variable -Option Constant VolumeRegistries ([String[]](Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*').Name)
        foreach ($Registry in $VolumeRegistries) {
            $ConfigLines.Add("`n[$Registry]`n")
            $ConfigLines.Add("`"MaxCapacity`"=dword:000FFFFF`n")
        }
    } catch {
        Write-LogError "Failed to read the registry: $_" $LogIndentLevel
    }

    Import-RegistryConfiguration $FileName $ConfigLines
}
