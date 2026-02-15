function Update-Dependencies {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ResourcesPath,
        [String][Parameter(Position = 1, Mandatory)]$BuilderPath,
        [String][Parameter(Position = 2, Mandatory)]$WipPath
    )

    New-Activity 'Checking for dependency updates'

    Write-ActivityProgress 5

    Set-Variable -Option Constant UpdatesPath ([String]"$BuilderPath\updates")

    Set-Variable -Option Constant EnvFile ([String]'.env')
    Set-Variable -Option Constant DependenciesFile ([String]"$ResourcesPath\dependencies.json")

    . "$UpdatesPath\Compare-Commits.ps1"
    . "$UpdatesPath\Compare-Tags.ps1"
    . "$UpdatesPath\Invoke-GitAPI.ps1"
    . "$UpdatesPath\Read-GitHubToken.ps1"
    . "$UpdatesPath\Select-Releases.ps1"
    . "$UpdatesPath\Set-NewVersion.ps1"
    . "$UpdatesPath\Update-FileDependency.ps1"
    . "$UpdatesPath\Update-GitDependency.ps1"
    . "$UpdatesPath\Update-WebDependency.ps1"

    Set-Variable -Option Constant GitHubToken ([String](Read-GitHubToken $EnvFile))
    if (-not $GitHubToken) {
        Write-LogWarning 'GitHub token not found. Continuing unauthenticated (rate limits may apply).'
    }

    Write-ActivityProgress 10
    Set-Variable -Option Constant Dependencies ([Dependency[]](Read-JsonFile $DependenciesFile))

    if (-not $Dependencies -or $Dependencies.Count -eq 0) {
        Write-LogWarning 'No dependencies found in configuration file.'
        Write-ActivityCompleted
        return
    }

    [Collections.Generic.List[Collections.Generic.List[String]]]$ChangeLogs = @()

    Set-Variable -Option Constant DependencyStep ([Math]::Floor(75 / $Dependencies.Count))
    Write-ActivityProgress 15

    $ErrorActionPreference = 'Continue'
    [Int]$Iteration = 1
    foreach ($Dependency in $Dependencies) {
        [String]$Source = $Dependency.source
        [String]$Name = $Dependency.name

        [Int]$Percentage = 15 + $Iteration * $DependencyStep
        Write-ActivityProgress $Percentage

        Write-LogInfo "Checking for updates for '$Name' (current version: $($Dependency.version))"

        switch ($Source) {
            ('GitHub') {
                $ChangeLogs.Add((Update-GitDependency $Dependency $GitHubToken))
            }
            ('GitLab') {
                $ChangeLogs.Add((Update-GitDependency $Dependency))
            }
            ('URL') {
                $ChangeLogs.Add((Update-WebDependency $Dependency))
            }
            ('File') {
                $ChangeLogs.Add((Update-FileDependency $Dependency $WipPath))
            }
        }

        $Iteration++
    }
    $ErrorActionPreference = 'Stop'

    Write-ActivityProgress 90

    Set-Variable -Option Constant UrlsToOpen ([String[]]($ChangeLogs | Select-Object -Unique | Where-Object { $_ }))
    Write-LogInfo "$($UrlsToOpen.Count) update(s) found"

    Write-ActivityProgress 95

    if ($UrlsToOpen.Count -gt 0) {
        Write-LogInfo "Saving updated dependencies to $DependenciesFile"
        Write-JsonFile $DependenciesFile $Dependencies
    }

    Write-ActivityCompleted

    return $UrlsToOpen
}
