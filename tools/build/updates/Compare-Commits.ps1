function Compare-Commits {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency,
        [Parameter(Position = 1)][String]$GitHubToken
    )

    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    Set-Variable -Option Constant Commits ([GitCommit[]](Invoke-GitAPI "https://api.github.com/repos/$Repository/commits" $GitHubToken))

    if ($Commits -and $Commits.Count -gt 0 -and $Commits[0].PSObject.Properties['sha']) {
        Set-Variable -Option Constant LatestVersion ([String]($Commits[0].sha))

        if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
            Set-NewVersion $Dependency $LatestVersion
            return @("https://github.com/$Repository/compare/$CurrentVersion...$LatestVersion")
        }
    }
}
