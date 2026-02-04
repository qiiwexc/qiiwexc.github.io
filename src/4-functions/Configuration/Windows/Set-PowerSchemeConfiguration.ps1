function Set-PowerSchemeConfiguration {
    try {
        powercfg /OverlaySetActive OVERLAY_SCHEME_MAX

        foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
            powercfg /SetAcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
            powercfg /SetDcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
        }

        Out-Success
    } catch {
        Out-Failure "Failed to apply power settings configuration: $_"
    }
}
