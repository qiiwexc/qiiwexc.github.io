function Set-PowerSchemeConfiguration {
    try {
        [Collections.Generic.List[String]]$Failed = @()

        # powercfg reports a failure through its exit code and, under the Stop preference, also by throwing
        try {
            powercfg /OverlaySetActive OVERLAY_SCHEME_MAX
            if ($LASTEXITCODE -ne 0) {
                $Failed.Add('the power mode')
            }
        } catch {
            $Failed.Add('the power mode')
        }

        foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
            if (-not (Test-PowerSetting $PowerSetting.SubGroup $PowerSetting.Setting)) {
                Write-LogDebug "Skipping power setting $($PowerSetting.SubGroup) $($PowerSetting.Setting), which this system does not have"
                continue
            }

            # SCHEME_ALL sets the value in every power scheme, the active one included
            try {
                powercfg /SetAcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
                [Int]$AcExitCode = $LASTEXITCODE
                powercfg /SetDcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
                if ($AcExitCode -ne 0 -or $LASTEXITCODE -ne 0) {
                    $Failed.Add("$($PowerSetting.SubGroup) $($PowerSetting.Setting)")
                }
            } catch {
                $Failed.Add("$($PowerSetting.SubGroup) $($PowerSetting.Setting)")
            }
        }

        # The active scheme takes a changed value only once it is activated again
        powercfg /SetActive SCHEME_CURRENT
        if ($LASTEXITCODE -ne 0) {
            $Failed.Add('the reactivation of the current power scheme')
        }

        if ($Failed.Count -gt 0) {
            Out-Failure "Could not apply $($Failed -join ', ')"
        } else {
            Out-Success
        }
    } catch {
        Out-Failure "Failed to apply power settings configuration: $_"
    }
}
