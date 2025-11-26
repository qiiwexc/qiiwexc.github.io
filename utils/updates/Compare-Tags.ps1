function Compare-Tags {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Source $Dependency.source
    Set-Variable -Option Constant Repository $Dependency.repository
    Set-Variable -Option Constant CurrentVersion $Dependency.version

    if ($Source -eq 'GitLab') {
        Set-Variable -Option Constant Tags (Invoke-GitAPI "https://gitlab.com/api/v4/projects/$($Dependency.projectId)/repository/tags")
    } else {
        Set-Variable -Option Constant Tags (Invoke-GitAPI "https://api.github.com/repos/$Repository/tags" $GitHubToken)
    }

    Set-Variable -Option Constant LatestVersion ($Tags | Select-Object -First 1).Name

    if ($LatestVersion -ne $CurrentVersion) {
        Set-NewVersion $Dependency $LatestVersion
        return @("https://$($Source.ToLower()).com/$Repository/compare/$CurrentVersion...$LatestVersion")
    }
}
