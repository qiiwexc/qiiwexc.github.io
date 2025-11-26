function Select-Tags {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Repository $Dependency.repository
    Set-Variable -Option Constant CurrentVersion $Dependency.version

    Set-Variable -Option Constant Tags (Invoke-GitAPI "https://api.github.com/repos/$Repository/tags" $GitHubToken)

    Set-Variable -Option Constant LatestVersion ($Tags | Select-Object -First 1).Name

    if ($LatestVersion -ne $CurrentVersion) {
        Set-NewVersion $Dependency $LatestVersion

        if ($LatestVersion.StartsWith('v')) {
            Set-Variable -Option Constant Prefix 'v'
        }

        Set-Variable -Option Constant AllVersions ($Tags | Select-Object -ExpandProperty Name)
        Set-Variable -Option Constant NormalizedVersions ($AllVersions | ForEach-Object { $_.TrimStart('v') })
        Set-Variable -Option Constant SortedVersions ($NormalizedVersions | Sort-Object { [Version]$_ } -Descending)
        Set-Variable -Option Constant FullVersions ($SortedVersions | ForEach-Object { "$Prefix$($_)" })
        Set-Variable -Option Constant NewVersionCount $FullVersions.IndexOf($CurrentVersion)

        if ($NewVersionCount -gt 0) {
            Set-Variable -Option Constant NewVersions $FullVersions[0..($NewVersionCount - 1)]

            [Collections.Generic.List[String]]$Urls = @()

            foreach ($Version in $NewVersions) {
                $Urls.Add("https://github.com/$Repository/releases/tag/$Version")
            }

            return $Urls
        }
    }
}
