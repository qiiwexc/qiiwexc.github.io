function Select-Tags {
    param(
        [ValidateNotNull()][PSObject][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    Set-Variable -Option Constant Tags ([GitTag[]](Invoke-GitAPI "https://api.github.com/repos/$Repository/tags" $GitHubToken))

    Set-Variable -Option Constant FilteredTags ([GitTag[]]($Tags | Where-Object { $_.name -inotmatch 'beta' }))

    if ($FilteredTags -and $FilteredTags.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($FilteredTags[0].name))

        if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
            Set-NewVersion $Dependency $LatestVersion

            if ($LatestVersion.StartsWith('v')) {
                Set-Variable -Option Constant Prefix ([String]'v')
            }

            Set-Variable -Option Constant AllVersions ([String[]]($FilteredTags | ForEach-Object { $_.name }))
            Set-Variable -Option Constant NormalizedVersions ([String[]]($AllVersions | ForEach-Object { $_.TrimStart('v') }))
            Set-Variable -Option Constant SortedVersions ([String[]]($NormalizedVersions | Sort-Object { [Version]$_ } -Descending))
            Set-Variable -Option Constant FullVersions ([String[]]($SortedVersions | ForEach-Object { "$Prefix$($_)" }))
            Set-Variable -Option Constant NewVersionCount ([Int]$FullVersions.IndexOf($CurrentVersion))

            if ($NewVersionCount -gt 0) {
                Set-Variable -Option Constant NewVersions ([String[]]$FullVersions[0..($NewVersionCount - 1)])

                [Collections.Generic.List[String]]$Urls = @()

                foreach ($Version in $NewVersions) {
                    $Urls.Add("https://github.com/$Repository/releases/tag/$Version")
                }

                return $Urls
            }
        }
    }
}
