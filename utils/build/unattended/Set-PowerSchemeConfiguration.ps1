function Set-PowerSchemeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigsPath,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)][AllowEmptyString()]$TemplateContent
    )

    . "$ConfigsPath\Windows\Power settings.ps1"

    [Collections.Generic.List[String]]$PowerSettings = @()
    foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
        [String]$Config = "SCHEME_BALANCED $($PowerSetting.SubGroup) $($PowerSetting.Setting) $($PowerSetting.Value)"
        $PowerSettings.Add("powercfg /SetAcValueIndex $Config`n")
        $PowerSettings.Add("powercfg /SetDcValueIndex $Config`n")
    }

    return $TemplateContent.Replace('{POWER_SCHEME_CONFIGURATION}', (-join $PowerSettings).trim())
}
