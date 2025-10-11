function Set-FeaturesRemovalList {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ConfigsPath,
        [Parameter(Position = 1, Mandatory = $True)]$TemplateContent
    )

    . "$ConfigsPath\Windows\Features to remove.ps1"

    [Collections.Generic.List[String]]$FormattedFeatureList = "`n"
    $CONFIG_FEATURES_TO_REMOVE | ForEach-Object { $FormattedFeatureList.Add("  '$($_)';`n") }

    return $TemplateContent.Replace('{FEATURE_REMOVAL_LIST}', -join $FormattedFeatureList)
}
