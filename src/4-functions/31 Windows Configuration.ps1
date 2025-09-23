Function Set-WindowsConfiguration {
    Set-MpPreference -PUAProtection Enabled
    Set-MpPreference -MeteredConnectionUpdates $True

    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sCurrency" -Value "€"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3

    Unregister-ScheduledTask -TaskName "CreateExplorerShellUnelevatedTask" -Confirm:$False -ErrorAction SilentlyContinue

    Set-PowerConfiguration

    Import-RegistryConfiguration $CHECKBOX_Config_Windows.Text ($CONFIG_WINDOWS + (Get-DynamicWindowsConfiguration))
}


Function Set-PowerConfiguration {
    Write-Log $INF 'Setting power scheme overlay...'

    powercfg /OverlaySetActive OVERLAY_SCHEME_MAX

    Out-Success

    Write-Log $INF 'Applying Windows power scheme settings...'

    ForEach ($PowerSetting In $CONFIG_POWER_SETTINGS) {
        powercfg /SetAcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
        powercfg /SetDcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
    }

    Out-Success
}


Function Get-DynamicWindowsConfiguration {
    Write-Log $INF 'Creating Windows configuration file...'

    [String]$ConfigLines = ''

    try {
        $UserRegistries = (Get-Item 'Registry::HKEY_USERS\*').Name | Where-Object { $_ -Match 'S-1-5-21' -and $_ -NotMatch '_Classes$' }
        ForEach ($Registry In $UserRegistries) {
            Set-Variable -Option Constant User ($Registry -Replace 'HKEY_USERS\\', '')
            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\InstallService\Stubification\$User]`n"
            $ConfigLines += "`"EnableAppOffloading`"=dword:00000000`n"

    # $ConfigLines += "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\InstallService\Stubification\$User]
    # `"EnableAppOffloading`"=dword:00000000

    # [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]
    # `"RotatingLockScreenEnabled`"=dword:00000001
    # `"RotatingLockScreenOverlayEnabled`"=dword:00000001`n"
        }

        $VolumeRegistries = (Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*').Name
        ForEach ($Registry In $VolumeRegistries) {
            $ConfigLines += "`n[$Registry]`n"
            $ConfigLines += "`"MaxCapacity`"=dword:000FFFFF`n"
        }

        $NotificationRegistries = (Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*').Name
        ForEach ($Registry In $NotificationRegistries) {
            $ConfigLines += "`n[$Registry]`n"
            $ConfigLines += "`"IsPromoted`"=dword:00000001`n"
        }

        $FileExtensionRegistries = (Get-Item 'Registry::HKEY_CLASSES_ROOT\*' -ErrorAction SilentlyContinue).Name | Where-Object { $_ -Match 'HKEY_CLASSES_ROOT\\\.' }
        ForEach ($Registry In $FileExtensionRegistries) {
            $PersistentHandlerRegistries = (Get-Item "Registry::$Registry\*").Name | Where-Object { $_ -Match 'PersistentHandler' }

            ForEach ($Reg In $PersistentHandlerRegistries) {
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

    Return $ConfigLines
}
