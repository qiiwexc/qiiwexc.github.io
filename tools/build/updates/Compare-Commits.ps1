function Compare-Commits {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency,
        [Parameter(Position = 1)][String]$GitHubToken
    )

    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    Set-Variable -Option Constant Commits ([GitCommit[]](Invoke-GitAPI "https://api.github.com/repos/$Repository/commits" $GitHubToken))

    # Nothing to compare with fails the check: left as it is, the version would read as "nothing newer"
    # and drop the versions waiting out their quarantine as withdrawn
    if (-not $Commits -or $Commits.Count -eq 0 -or -not $Commits[0].PSObject.Properties['sha'] -or -not $Commits[0].sha) {
        throw "No commits found for '$Repository'"
    }

    Set-Variable -Option Constant LatestVersion ([String]($Commits[0].sha))

    if ($LatestVersion -ne $CurrentVersion) {
        Set-NewVersion $Dependency $LatestVersion
        return @("https://github.com/$Repository/compare/$CurrentVersion...$LatestVersion")
    }
}
