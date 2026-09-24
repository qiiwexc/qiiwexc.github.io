function Compare-Tags {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency,
        [Parameter(Position = 1)][String]$GitHubToken
    )

    Set-Variable -Option Constant Source ([String]$Dependency.source)
    Set-Variable -Option Constant Repository ([String]$Dependency.repository)
    Set-Variable -Option Constant CurrentVersion ([String]$Dependency.version)

    if ($Source -eq 'GitHub') {
        Set-Variable -Option Constant Tags ([GitTag[]](Invoke-GitAPI "https://api.github.com/repos/$Repository/tags?per_page=100" $GitHubToken))
    } elseif ($Source -eq 'GitLab') {
        Set-Variable -Option Constant Tags ([GitTag[]](Invoke-GitAPI "https://gitlab.com/api/v4/projects/$($Dependency.projectId)/repository/tags?per_page=100"))
    }

    if (-not $Tags -or $Tags.Count -eq 0) {
        return
    }

    # Neither API guarantees newest-first order, so pick the highest version explicitly,
    # ignoring pre-release tags such as 'v2.0.0-rc1'
    Set-Variable -Option Constant ReleaseTags ([GitTag[]]@($Tags | Where-Object { $_.PSObject.Properties['name'] -and $_.name -match '^v?\d+(\.\d+){1,3}$' }))

    if ($ReleaseTags.Count -gt 0) {
        Set-Variable -Option Constant LatestVersion ([String]($ReleaseTags | Sort-Object { [Version]($_.name -replace '^v') } -Descending | Select-Object -First 1).name)
    } elseif ($Tags[0].PSObject.Properties['name']) {
        # No version-like tags at all — fall back to the order the API returned them in
        Set-Variable -Option Constant LatestVersion ([String]$Tags[0].name)
    } else {
        return
    }

    if ($LatestVersion -ne '' -and $LatestVersion -ne $CurrentVersion) {
        Set-NewVersion $Dependency $LatestVersion
        return @("https://$($Source.ToLower()).com/$Repository/compare/$CurrentVersion...$LatestVersion")
    }
}
