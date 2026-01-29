function Compare-Tags {
    param(
        [ValidateNotNull()][PSObject][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Source ([String]$Dependency.source)
    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    if ($Source -eq 'GitHub') {
        Set-Variable -Option Constant Tags ([GitTag[]](Invoke-GitAPI "https://api.github.com/repos/$Repository/tags" $GitHubToken))
    } elseif ($Source -eq 'GitLab') {
        Set-Variable -Option Constant Tags ([GitTag[]](Invoke-GitAPI "https://gitlab.com/api/v4/projects/$($Dependency.projectId)/repository/tags"))
    }

    if ($Tags -and $Tags.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($Tags[0].name))

        if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
            Set-NewVersion $Dependency $LatestVersion
            return @("https://$($Source.ToLower()).com/$Repository/compare/$CurrentVersion...$LatestVersion")
        }
    }
}
