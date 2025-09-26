function Set-WindowsConfiguration {
    Set-MpPreference -PUAProtection Enabled
    Set-MpPreference -MeteredConnectionUpdates $True

    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sCurrency' -Value ([Char]0x20AC)
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value 3

    Unregister-ScheduledTask -TaskName 'CreateExplorerShellUnelevatedTask' -Confirm:$False -ErrorAction SilentlyContinue

    Set-PowerConfiguration

    Import-RegistryConfiguration $CHECKBOX_Config_Windows.Text ($CONFIG_WINDOWS + (Get-DynamicWindowsConfiguration))
}


function Set-PowerConfiguration {
    Write-Log $INF 'Setting power scheme overlay...'

    powercfg /OverlaySetActive OVERLAY_SCHEME_MAX

    Out-Success

    Write-Log $INF 'Applying Windows power scheme settings...'

    foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
        powercfg /SetAcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
        powercfg /SetDcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
    }

    Out-Success
}


function Get-DynamicWindowsConfiguration {
    Write-Log $INF 'Creating Windows configuration file...'

    [String]$ConfigLines = ''

    try {
        $UserRegistries = (Get-Item 'Registry::HKEY_USERS\*').Name | Where-Object { $_ -match 'S-1-5-21' -and $_ -notmatch '_Classes$' }
        foreach ($Registry in $UserRegistries) {
            Set-Variable -Option Constant User ($Registry -replace 'HKEY_USERS\\', '')
            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\InstallService\Stubification\$User]`n"
            $ConfigLines += "`"EnableAppOffloading`"=dword:00000000`n"
        }

        $VolumeRegistries = (Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*').Name
        foreach ($Registry in $VolumeRegistries) {
            $ConfigLines += "`n[$Registry]`n"
            $ConfigLines += "`"MaxCapacity`"=dword:000FFFFF`n"
        }

        $NotificationRegistries = (Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*').Name
        foreach ($Registry in $NotificationRegistries) {
            $ConfigLines += "`n[$Registry]`n"
            $ConfigLines += "`"IsPromoted`"=dword:00000001`n"
        }

        $FileExtensionRegistries = (Get-Item 'Registry::HKEY_CLASSES_ROOT\*' -ErrorAction SilentlyContinue).Name | Where-Object { $_ -match 'HKEY_CLASSES_ROOT\\\.' }
        foreach ($Registry in $FileExtensionRegistries) {
            $PersistentHandlerRegistries = (Get-Item "Registry::$Registry\*").Name | Where-Object { $_ -match 'PersistentHandler' }

            foreach ($Reg in $PersistentHandlerRegistries) {
                $PersistentHandler = Get-ItemProperty "Registry::$Reg"
                $DefaultHandler = $PersistentHandler.'(default)'

                if ($DefaultHandler -and !($DefaultHandler -eq '{098F2470-BAE0-11CD-B579-08002B30BFEB}')) {
                    $ConfigLines += "`n[$Reg]`n"
                    $ConfigLines += "@=`"{098F2470-BAE0-11CD-B579-08002B30BFEB}`"`n"
                    $ConfigLines += "`"OriginalPersistentHandler`"=`"$DefaultHandler`"`n"
                }

            }
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to read the registry'
    }

    Out-Success

    return $ConfigLines
}
