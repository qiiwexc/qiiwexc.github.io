function Set-PowerSchemeConfiguration {
    try {
        powercfg /OverlaySetActive OVERLAY_SCHEME_MAX

        foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
            if (-not (Test-PowerSetting $PowerSetting.SubGroup $PowerSetting.Setting)) {
                Write-LogDebug "Skipping power setting $($PowerSetting.SubGroup) $($PowerSetting.Setting), which this system does not have"
                continue
            }

            powercfg /SetAcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
            powercfg /SetDcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
        }

        Out-Success
    } catch {
        Out-Failure "Failed to apply power settings configuration: $_"
    }
}
