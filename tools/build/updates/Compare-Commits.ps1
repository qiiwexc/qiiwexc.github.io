function Compare-Commits {
    param(
        [PSCustomObject][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    Set-Variable -Option Constant Commits ([Collections.Generic.List[PSCustomObject]](Invoke-GitAPI "https://api.github.com/repos/$Repository/commits" $GitHubToken))

    if ($Commits -and $Commits.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($Commits[0].Sha))

        if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
            Set-NewVersion $Dependency $LatestVersion
            return [Collections.Generic.List[PSCustomObject]]@("https://github.com/$Repository/compare/$CurrentVersion...$LatestVersion")
        }
    }
}
