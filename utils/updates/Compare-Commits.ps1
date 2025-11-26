function Compare-Commits {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Repository $Dependency.repository
    Set-Variable -Option Constant CurrentVersion $Dependency.version

    Set-Variable -Option Constant Commits (Invoke-GitAPI "https://api.github.com/repos/$Repository/commits" $GitHubToken)

    Set-Variable -Option Constant LatestVersion ($Commits | Select-Object -First 1).Sha

    if ($LatestVersion -ne $CurrentVersion) {
        Set-NewVersion $Dependency $LatestVersion
        return @("https://github.com/$Repository/compare/$CurrentVersion...$LatestVersion")
    }
}
