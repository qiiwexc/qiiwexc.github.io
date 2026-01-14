Add-Type -TypeDefinition @'
    public enum Source {
        File,
        GitHub,
        GitLab,
        URL
    }
'@

function Update-Dependencies {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigPath,
        [String][Parameter(Position = 1, Mandatory)]$BuilderPath,
        [String][Parameter(Position = 2, Mandatory)]$WipPath
    )

    Set-Variable -Option Constant UpdatesPath ([String]"$BuilderPath\updates")

    Set-Variable -Option Constant EnvFile ([String]'.env')
    Set-Variable -Option Constant DependenciesFile ([String]"$ConfigPath\dependencies.json")

    . "$UpdatesPath\Compare-Commits.ps1"
    . "$UpdatesPath\Compare-Tags.ps1"
    . "$UpdatesPath\Invoke-GitAPI.ps1"
    . "$UpdatesPath\Read-GitHubToken.ps1"
    . "$UpdatesPath\Select-Tags.ps1"
    . "$UpdatesPath\Set-NewVersion.ps1"
    . "$UpdatesPath\Update-FileDependency.ps1"
    . "$UpdatesPath\Update-GitDependency.ps1"
    . "$UpdatesPath\Update-WebDependency.ps1"

    Write-Progress -Activity 'Update' -PercentComplete 1

    Set-Variable -Option Constant GitHubToken ([String](Read-GitHubToken $EnvFile))
    if (-not $GitHubToken) {
        Write-LogWarning 'GitHub token not found. Continuing unauthenticated (rate limits may apply).'
    }
    Write-Progress -Activity 'Update' -PercentComplete 5

    Set-Variable -Option Constant Dependencies ([Collections.Generic.List[Object]](Get-Content $DependenciesFile -Raw -Encoding UTF8 | ConvertFrom-Json))
    Write-Progress -Activity 'Update' -PercentComplete 10

    [Collections.Generic.List[Collections.Generic.List[String]]]$ChangeLogs = @()

    Set-Variable -Option Constant DependencyStep ([Math]::Floor(80 / $Dependencies.Count))

    [Int]$Iteration = 1
    foreach ($Dependency in $Dependencies) {
        [String]$Source = $Dependency.source
        [String]$Name = $Dependency.name
        [Int]$Percentage = 10 + $Iteration * $DependencyStep

        Write-LogInfo "Checking for updates for '$Name' (current version: $($Dependency.version))"

        switch ($Source) {
            ([Source]::GitHub) {
                $ChangeLogs.Add((Update-GitDependency $Dependency $GitHubToken))
            }
            ([Source]::GitLab) {
                $ChangeLogs.Add((Update-GitDependency $Dependency))
            }
            ([Source]::URL) {
                $ChangeLogs.Add((Update-WebDependency $Dependency))
            }
            ([Source]::File) {
                $ChangeLogs.Add((Update-FileDependency $Dependency $WipPath))
            }
        }

        Write-Progress -Activity 'Update' -PercentComplete $Percentage
        $Iteration++
    }

    Write-Progress -Activity 'Update' -PercentComplete 90

    Set-Variable -Option Constant UrlsToOpen ([Collections.Generic.List[String]]($ChangeLogs | Select-Object -Unique | Where-Object { $_ }))
    Write-LogInfo "$($UrlsToOpen.Count) update(s) found"
    Write-Progress -Activity 'Update' -PercentComplete 95

    if ($UrlsToOpen.Count -gt 0) {
        foreach ($Url in @($UrlsToOpen | ForEach-Object { $_ })) {
            Write-LogInfo "Opening URL: $Url"
            Start-Process $Url
        }
    }

    Write-LogInfo "Saving updated dependencies to $DependenciesFile"
    Set-Variable -Option Constant UpdatedDependencies ([String]($Dependencies | ConvertTo-Json -Depth 10))
    Write-File $DependenciesFile $UpdatedDependencies

    Write-Progress -Activity 'Update' -Complete

    Out-Success
}
