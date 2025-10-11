function Set-CapabilitiesRemovalList {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ConfigsPath,
        [Parameter(Position = 1, Mandatory = $True)]$TemplateContent
    )

    . "$ConfigsPath\Windows\Capabilities to remove.ps1"

    [Collections.Generic.List[String]]$FormattedCapabilitiesList = "`n"
    $CONFIG_CAPABILITIES_TO_REMOVE | ForEach-Object { $FormattedCapabilitiesList.Add("  '$($_)';`n") }

    return $TemplateContent.Replace('{CAPABILITY_REMOVAL_LIST}', -join $FormattedCapabilitiesList)
}
