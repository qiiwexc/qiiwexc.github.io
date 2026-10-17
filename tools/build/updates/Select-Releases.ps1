function Select-Releases {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency,
        [Parameter(Position = 1)][String]$GitHubToken
    )

    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    Set-Variable -Option Constant Releases ([GitRelease[]]@(Invoke-GitAPI "https://api.github.com/repos/$Repository/releases?per_page=5" $GitHubToken))

    # Nothing to compare with fails the check: left as it is, the version would read as "nothing newer"
    # and drop the versions waiting out their quarantine as withdrawn
    if (-not $Releases -or $Releases.Count -eq 0) {
        throw "No releases found for '$Repository'"
    }

    # Rely exclusively on the GitHub API's authoritative 'prerelease' flag — a missing
    # flag (e.g. a malformed or truncated response) is treated as not-a-prerelease
    Set-Variable -Option Constant FilteredReleases ([GitRelease[]]@($Releases | Where-Object { $_.PSObject.Properties['tag_name'] -and (-not $_.PSObject.Properties['prerelease'] -or $_.prerelease -ne $true) }))

    if ($FilteredReleases.Count -eq 0 -or -not $FilteredReleases[0].tag_name) {
        throw "None of the $($Releases.Count) most recent releases of '$Repository' is a stable one with a tag"
    }

    Set-Variable -Option Constant LatestVersion ([String]($FilteredReleases[0].tag_name))

    if ($LatestVersion -ne $CurrentVersion) {
        Set-NewVersion $Dependency $LatestVersion

        Set-Variable -Option Constant AllVersions ([String[]]($FilteredReleases | ForEach-Object { $_.tag_name }))
        Set-Variable -Option Constant ParseableVersions ([String[]]($AllVersions | Where-Object {
                    try { [Void][Version]($_ -replace '^v' -replace '-.*$'); $True } catch { $False }
                }))
        Set-Variable -Option Constant SortedVersions ([String[]]($ParseableVersions | Sort-Object { [Version]($_ -replace '^v' -replace '-.*$') } -Descending))
        Set-Variable -Option Constant NewVersionCount ([Int]$SortedVersions.IndexOf($CurrentVersion))

        if ($NewVersionCount -gt 0) {
            Set-Variable -Option Constant NewVersions ([String[]]$SortedVersions[0..($NewVersionCount - 1)])

            [Collections.Generic.List[String]]$Urls = @()

            foreach ($Version in $NewVersions) {
                $Urls.Add("https://github.com/$Repository/releases/tag/$Version")
            }

            return $Urls
        }

        # The current version is further back than the releases listed, so the latest is all there is to link
        if ($NewVersionCount -lt 0) {
            return @("https://github.com/$Repository/releases/tag/$LatestVersion")
        }
    }
}
