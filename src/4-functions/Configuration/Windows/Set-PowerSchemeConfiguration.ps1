function Set-PowerSchemeConfiguration {
    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Write-ActivityProgress -PercentComplete 15 -Task 'Setting power scheme overlay...'

    powercfg /OverlaySetActive OVERLAY_SCHEME_MAX

    Out-Success $LogIndentLevel

    Write-ActivityProgress -PercentComplete 20 -Task 'Applying Windows power scheme settings...'

    foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
        powercfg /SetAcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
        powercfg /SetDcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
    }

    Out-Success $LogIndentLevel
}
