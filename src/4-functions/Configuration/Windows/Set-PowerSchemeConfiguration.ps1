function Set-PowerSchemeConfiguration {
    Write-ActivityProgress -PercentComplete 15 -Task 'Setting power scheme overlay...'

    powercfg /OverlaySetActive OVERLAY_SCHEME_MAX

    Out-Success

    Write-ActivityProgress -PercentComplete 20 -Task 'Applying Windows power scheme settings...'

    foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
        powercfg /SetAcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
        powercfg /SetDcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
    }

    Out-Success
}
