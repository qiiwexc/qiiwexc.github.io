function Set-WindowsBaseConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
    )

    Write-LogInfo 'Applying Windows configuration...'

    if ($PS_VERSION -ge 5) {
        Set-MpPreference -CheckForSignaturesBefore $True
        Set-MpPreference -DisableBlockAtFirstSeen $False
        Set-MpPreference -DisableCatchupQuickScan $False
        Set-MpPreference -DisableEmailScanning $False
        Set-MpPreference -DisableRemovableDriveScanning $False
        Set-MpPreference -DisableRestorePoint $False
        Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $False
        Set-MpPreference -DisableScanningNetworkFiles $False
        Set-MpPreference -EnableFileHashComputation $True
        Set-MpPreference -EnableNetworkProtection Enabled
        Set-MpPreference -PUAProtection Enabled
        Set-MpPreference -AllowSwitchToAsyncInspection $True
        Set-MpPreference -MeteredConnectionUpdates $True
        Set-MpPreference -IntelTDTEnabled $True
        Set-MpPreference -BruteForceProtectionLocalNetworkBlocking $True
    }

    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sCurrency' -Value ([Char]0x20AC)
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value 3

    Set-Variable -Option Constant UnelevatedExplorerTaskName 'CreateExplorerShellUnelevatedTask'
    if (Get-ScheduledTask | Where-Object { $_.TaskName -eq $UnelevatedExplorerTaskName } ) {
        Unregister-ScheduledTask -TaskName $UnelevatedExplorerTaskName -Confirm:$False
    }

    [String]$ConfigLines = ''

    try {
        foreach ($Registry in (Get-UsersRegistryKeys)) {
            [String]$User = $Registry.Replace('HKEY_USERS\', '')
            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n"
            $ConfigLines += "`"RotatingLockScreenOverlayEnabled`"=dword:00000000`n"

            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\InstallService\Stubification\$User]`n"
            $ConfigLines += "`"EnableAppOffloading`"=dword:00000000`n"

            $ConfigLines += "`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]`n"
            $ConfigLines += "`"DoNotTrack`"=dword:00000001`n"

            $ConfigLines += "`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]`n"
            $ConfigLines += "`"EnableCortana`"=dword:00000000`n"
        }

        Set-Variable -Option Constant VolumeRegistries ((Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*').Name)
        foreach ($Registry in $VolumeRegistries) {
            $ConfigLines += "`n[$Registry]`n"
            $ConfigLines += "`"MaxCapacity`"=dword:000FFFFF`n"
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to read the registry'
    }

    Set-Variable -Option Constant BaseConfig ($CONFIG_WINDOWS_BASE + $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_WINDOWS_RUSSIAN } else { $CONFIG_WINDOWS_ENGLISH }))

    Import-RegistryConfiguration $FileName ($BaseConfig + $ConfigLines)
}
