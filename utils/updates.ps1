#Requires -PSEdition Desktop
#Requires -Version 3

Set-Variable -Option Constant RootPath ([String]'..\')
Set-Variable -Option Constant CommonPath ([String]'.\common')
Set-Variable -Option Constant UpdatesPath ([String]'.\updates')
Set-Variable -Option Constant ConfigPath ([String]"$RootPath\config")
Set-Variable -Option Constant EnvPath ([String]"$RootPath\.env")
Set-Variable -Option Constant DependenciesPath ([String]"$ConfigPath\dependencies.json")

. "$CommonPath\logger.ps1"
. "$UpdatesPath\Compare-Commits.ps1"
. "$UpdatesPath\Compare-Tags.ps1"
. "$UpdatesPath\Invoke-GitAPI.ps1"
. "$UpdatesPath\Read-GitHubToken.ps1"
. "$UpdatesPath\Select-Tags.ps1"
. "$UpdatesPath\Set-NewVersion.ps1"
. "$UpdatesPath\Update-GitDependency.ps1"
. "$UpdatesPath\Update-WebDependency.ps1"

Set-Variable -Option Constant GitHubToken ([String](Read-GitHubToken $EnvPath))
if (-not $GitHubToken) {
    Write-LogWarning 'GitHub token not found. Continuing unauthenticated (rate limits may apply).'
}

Set-Variable -Option Constant Dependencies ([Collections.Generic.List[Object]](Get-Content -Raw -Path $DependenciesPath -Encoding UTF8 | ConvertFrom-Json))

[Collections.Generic.List[Collections.Generic.List[String]]]$ChangeLogs = @()

foreach ($Dependency in $Dependencies) {
    Write-LogInfo "Checking for updates for $($Dependency.name) (current version: $($Dependency.version))"

    switch ($Dependency.source) {
        'GitHub' {
            $ChangeLogs.Add((Update-GitDependency $Dependency $GitHubToken))
        }
        'GitLab' {
            $ChangeLogs.Add((Update-GitDependency $Dependency))
        }
        'URL' {
            $ChangeLogs.Add((Update-WebDependency $Dependency))
        }
        Default {}
    }
}

Set-Variable -Option Constant UrlsToOpen ([Collections.Generic.List[String]]($ChangeLogs | Select-Object -Unique | Where-Object { $_ }))
Write-LogInfo "$($UrlsToOpen.Count) update(s) found"

if ($UrlsToOpen.Count -gt 0) {
    foreach ($Url in @($UrlsToOpen | ForEach-Object { $_ })) {
        Write-LogInfo "Opening URL: $Url"
        [Diagnostics.Process]::Start($Url)
    }

    Write-LogInfo "Saving updated dependencies to $DependenciesPath"
    Set-Variable -Option Constant UpdatedDependencies ([String]($Dependencies | ConvertTo-Json -Depth 10))
    Set-Content -Path $DependenciesPath -Value $UpdatedDependencies -Encoding UTF8
}

Out-Success
