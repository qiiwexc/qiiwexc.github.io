function Compare-Commits {
    param(
        [GitHubDependency][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    Set-Variable -Option Constant Commits ([GitCommit[]](Invoke-GitAPI "https://api.github.com/repos/$Repository/commits" $GitHubToken))

    if ($Commits -and $Commits.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($Commits[0].sha))

        if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
            Set-NewVersion $Dependency $LatestVersion
            return @("https://github.com/$Repository/compare/$CurrentVersion...$LatestVersion")
        }
    }
}
