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

    Unregister-ScheduledTask -TaskName 'CreateExplorerShellUnelevatedTask' -Confirm:$False -ErrorAction SilentlyContinue

    [String]$ConfigLines = ''

    try {
        Set-Variable -Option Constant UserRegistries ((Get-Item 'Registry::HKEY_USERS\*').Name | Where-Object { $_ -match 'S-1-5-21' -and $_ -notmatch '_Classes$' })
        foreach ($Registry in $UserRegistries) {
            Set-Variable -Option Constant User ($Registry.Replace('HKEY_USERS\', ''))
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
