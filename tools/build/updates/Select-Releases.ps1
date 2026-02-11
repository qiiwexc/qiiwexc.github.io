function Select-Releases {
    param(
        [ValidateNotNull()][PSObject][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    Set-Variable -Option Constant Releases ([GitRelease[]](Invoke-GitAPI "https://api.github.com/repos/$Repository/releases" $GitHubToken))

    Set-Variable -Option Constant FilteredReleases ([GitRelease[]]($Releases | Where-Object { $_.tag_name -inotmatch 'beta' }))

    if ($FilteredReleases -and $FilteredReleases.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($FilteredReleases[0].tag_name))

        if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
            Set-NewVersion $Dependency $LatestVersion

            if ($LatestVersion.StartsWith('v')) {
                Set-Variable -Option Constant Prefix ([String]'v')
            }

            Set-Variable -Option Constant AllVersions ([String[]]($FilteredReleases | ForEach-Object { $_.tag_name }))
            Set-Variable -Option Constant NormalizedVersions ([String[]]($AllVersions | ForEach-Object { $_.TrimStart('v') }))
            Set-Variable -Option Constant SortedVersions ([String[]]($NormalizedVersions | Sort-Object { [Version]$_ } -Descending))
            Set-Variable -Option Constant FullVersions ([String[]]($SortedVersions | ForEach-Object { "$Prefix$($_)" }))
            Set-Variable -Option Constant NewVersionCount ([Int]$FullVersions.IndexOf($CurrentVersion))

            if ($NewVersionCount -gt 0) {
                Set-Variable -Option Constant NewVersions ([String[]]$FullVersions[0..($NewVersionCount - 1)])

                [Collections.Generic.List[String]]$Urls = @()

                foreach ($Version in $NewVersions) {
                    $Urls.Add("https://github.com/$Repository/releases/$Version")
                }

                return $Urls
            }
        }
    }
}
