function Set-WindowsBaseConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
    )

    Write-LogInfo 'Applying Windows configuration...'

    if ($PS_VERSION -ge 5) {
        Set-MpPreference -PUAProtection Enabled
        Set-MpPreference -MeteredConnectionUpdates $True
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
            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\InstallService\Stubification\$User]`n"
            $ConfigLines += "`"EnableAppOffloading`"=dword:00000000`n"
        }

        Set-Variable -Option Constant VolumeRegistries ((Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*').Name)
        foreach ($Registry in $VolumeRegistries) {
            $ConfigLines += "`n[$Registry]`n"
            $ConfigLines += "`"MaxCapacity`"=dword:000FFFFF`n"
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to read the registry'
    }

    Import-RegistryConfiguration $FileName ($CONFIG_WINDOWS_BASE + $ConfigLines)
}
