function Set-CapabilitiesRemovalList {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigsPath,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)][AllowEmptyString()]$TemplateContent
    )

    . "$ConfigsPath\Windows\Capabilities to remove.ps1"

    [Collections.Generic.List[String]]$FormattedCapabilitiesList = "`n"
    $CONFIG_CAPABILITIES_TO_REMOVE | ForEach-Object {
        [String]$Capability = $_.trim()
        $FormattedCapabilitiesList.Add("  '$Capability';`n")
    }

    return $TemplateContent.Replace('{CAPABILITY_REMOVAL_LIST}', -join $FormattedCapabilitiesList)
}
