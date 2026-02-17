function Select-Releases {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency,
        [Parameter(Position = 1)][String]$GitHubToken
    )

    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    Set-Variable -Option Constant Releases ([GitRelease[]]@(Invoke-GitAPI "https://api.github.com/repos/$Repository/releases?per_page=5" $GitHubToken))

    if (-not $Releases -or $Releases.Count -eq 0) {
        return
    }

    Set-Variable -Option Constant FilteredReleases ([GitRelease[]]@($Releases | Where-Object { $_.PSObject.Properties['tag_name'] -and $_.tag_name -inotmatch 'beta' }))

    if ($FilteredReleases -and $FilteredReleases.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($FilteredReleases[0].tag_name))

        if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
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
                    $Urls.Add("https://github.com/$Repository/releases/$Version")
                }

                return $Urls
            }
        }
    }
}
