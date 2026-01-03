Add-Type -TypeDefinition @'
    public enum Source {
        GitHub,
        GitLab,
        URL
    }
'@

function Compare-Tags {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$GitHubToken
    )

    Set-Variable -Option Constant Source ([Source]$Dependency.source)
    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    if ($Source -eq ([Source]::GitLab)) {
        Set-Variable -Option Constant Tags ([Collections.Generic.List[Object]](Invoke-GitAPI "https://gitlab.com/api/v4/projects/$($Dependency.projectId)/repository/tags"))
    } else {
        Set-Variable -Option Constant Tags ([Collections.Generic.List[Object]](Invoke-GitAPI "https://api.github.com/repos/$Repository/tags" $GitHubToken))
    }

    if ($Tags -and $Tags.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($Tags | Select-Object -First 1).Name)

        if ($LatestVersion -ne $CurrentVersion) {
            Set-NewVersion $Dependency $LatestVersion
            return [Collections.Generic.List[Object]]@("https://$($Source.ToString().ToLower()).com/$Repository/compare/$CurrentVersion...$LatestVersion")
        }
    }
}
