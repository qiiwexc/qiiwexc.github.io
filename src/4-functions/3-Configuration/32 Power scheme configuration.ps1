function Set-PowerSchemeConfiguration {
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
