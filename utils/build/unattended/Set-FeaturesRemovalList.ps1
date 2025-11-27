function Set-FeaturesRemovalList {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigsPath,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)][AllowEmptyString()]$TemplateContent
    )

    . "$ConfigsPath\Windows\Features to remove.ps1"

    [Collections.Generic.List[String]]$FormattedFeatureList = "`n"
    $CONFIG_FEATURES_TO_REMOVE | ForEach-Object {
        [String]$Feature = $_.trim()
        $FormattedFeatureList.Add("  '$Feature';`n")
    }

    return $TemplateContent.Replace('{FEATURE_REMOVAL_LIST}', -join $FormattedFeatureList)
}
