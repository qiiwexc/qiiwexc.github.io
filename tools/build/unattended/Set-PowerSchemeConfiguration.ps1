function Set-PowerSchemeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigsPath,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)]$TemplateContent
    )

    . "$ConfigsPath\Windows\Power settings.ps1"

    [Collections.Generic.List[String]]$PowerSettings = @("powercfg /OverlaySetActive OVERLAY_SCHEME_MAX`n")
    foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
        [String]$Config = "SCHEME_ALL $($PowerSetting.SubGroup) $($PowerSetting.Setting) $($PowerSetting.Value)"
        $PowerSettings.Add("powercfg /SetAcValueIndex $Config`n")
        $PowerSettings.Add("powercfg /SetDcValueIndex $Config`n")
    }

    return $TemplateContent.Replace('{POWER_SCHEME_CONFIGURATION}', (-join $PowerSettings).trim())
}
