Function Set-PowerConfiguration {
    Write-Log $INF 'Setting power scheme overlay...'

    powercfg /OverlaySetActive OVERLAY_SCHEME_MAX

    Out-Success

    Write-Log $INF 'Applying Windows power scheme settings...'

    ForEach ($PowerSetting In $CONFIG_POWER_SETTINGS) {
        Write-Log $INF "SubGroup='$($PowerSetting.SubGroup)' Setting='$($PowerSetting.Setting)'"
        powercfg /SetAcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
        powercfg /SetDcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
    }

    Out-Success
}
