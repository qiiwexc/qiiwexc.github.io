Add-Type -TypeDefinition @'
    public enum GitSource {
        GitHub,
        GitLab
    }
'@

function Compare-Tags {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Source ([GitSource]$Dependency.source)
    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    if ($Source -eq ([GitSource]::GitHub)) {
        Set-Variable -Option Constant Tags ([Collections.Generic.List[Object]](Invoke-GitAPI "https://api.github.com/repos/$Repository/tags" $GitHubToken))
    } elseif ($Source -eq ([GitSource]::GitLab)) {
        Set-Variable -Option Constant Tags ([Collections.Generic.List[Object]](Invoke-GitAPI "https://gitlab.com/api/v4/projects/$($Dependency.projectId)/repository/tags"))
    }

    if ($Tags -and $Tags.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($Tags[0].Name))

        if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
            Set-NewVersion $Dependency $LatestVersion
            return [Collections.Generic.List[Object]]@("https://$($Source.ToString().ToLower()).com/$Repository/compare/$CurrentVersion...$LatestVersion")
        }
    }
}
