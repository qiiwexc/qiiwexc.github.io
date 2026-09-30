function Update-Dependencies {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ResourcesPath,
        [Parameter(Position = 1, Mandatory)][String]$BuilderPath,
        [Parameter(Position = 2, Mandatory)][String]$WipPath,
        [Parameter(Position = 3, Mandatory)][String]$QuarantineFile
    )

    New-Activity 'Checking for dependency updates'

    Write-ActivityProgress 5

    Set-Variable -Option Constant UpdatesPath ([String]"$BuilderPath\updates")

    Set-Variable -Option Constant EnvFile ([String]'.env')
    Set-Variable -Option Constant DependenciesFile ([String]"$ResourcesPath\dependencies.json")
    Set-Variable -Option Constant UrlsFile ([String]"$ResourcesPath\urls.json")

    . "$UpdatesPath\Compare-Commits.ps1"
    . "$UpdatesPath\Compare-Tags.ps1"
    . "$UpdatesPath\Get-QuarantineEnd.ps1"
    . "$UpdatesPath\Invoke-GitAPI.ps1"
    . "$UpdatesPath\Read-GitHubToken.ps1"
    . "$UpdatesPath\Read-QuarantineState.ps1"
    . "$UpdatesPath\Resolve-QuarantinedVersion.ps1"
    . "$UpdatesPath\Select-ChangelogUrls.ps1"
    . "$UpdatesPath\Select-Releases.ps1"
    . "$UpdatesPath\Set-NewVersion.ps1"
    . "$UpdatesPath\Update-DependencyChecksum.ps1"
    . "$UpdatesPath\Update-FileDependency.ps1"
    . "$UpdatesPath\Update-GitDependency.ps1"
    . "$UpdatesPath\Update-WebDependency.ps1"
    . "$UpdatesPath\Write-QuarantineState.ps1"

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

    # The dependencies that open the pull request wait out a quarantine before a new version is applied; the
    # others ride along in it, and a file dependency is updated by hand from files already downloaded
    Set-Variable -Option Constant QuarantinedNames ([String[]]@($Dependencies | Where-Object {
                $_.source -ne 'File' -and $_.PSObject.Properties['opensPullRequest'] -and $_.opensPullRequest -eq $True
            } | ForEach-Object { $_.name }))

    # When each version newer than the recorded one was first seen, kept between runs
    Set-Variable -Option Constant Now ([DateTime]::UtcNow)
    [Collections.Specialized.OrderedDictionary]$QuarantineState = Read-QuarantineState $QuarantineFile $Now

    [Collections.Generic.List[Collections.Generic.List[String]]]$ChangeLogs = @()

    Set-Variable -Option Constant DependencyStep ([Math]::Floor(75 / $Dependencies.Count))
    Write-ActivityProgress 15

    [Int]$FailedCount = 0
    [Bool]$HasVersionChanges = $False
    [Int]$Iteration = 1
    foreach ($Dependency in $Dependencies) {
        [String]$Source = $Dependency.source
        [String]$Name = $Dependency.name
        [String]$PreviousVersion = $Dependency.version
        [Int]$ChangeLogCount = $ChangeLogs.Count

        [Int]$Percentage = 15 + $Iteration * $DependencyStep
        Write-ActivityProgress $Percentage

        Write-LogInfo "Checking for updates for '$Name' (current version: $($Dependency.version))"

        # One unreachable source must not lose the updates found for all the others
        try {
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

            # Held back to the newest version out of quarantine, which may be the recorded one: its links then
            # go only as far as that version, or there are none to follow
            if ($Name -in $QuarantinedNames) {
                [String]$LatestVersion = $Dependency.version
                $Dependency.version = Resolve-QuarantinedVersion $QuarantineState $Name $PreviousVersion $LatestVersion $Now

                if ($Dependency.version -ne $LatestVersion -and $ChangeLogs.Count -gt $ChangeLogCount) {
                    if ($Dependency.version -eq $PreviousVersion) {
                        $ChangeLogs.RemoveAt($ChangeLogCount)
                    } else {
                        [String[]]$LatestUrls = @($ChangeLogs[$ChangeLogCount] | Where-Object { $_ })
                        $ChangeLogs[$ChangeLogCount] = [Collections.Generic.List[String]]@(Select-ChangelogUrls $LatestUrls $LatestVersion $Dependency.version)
                    }
                }
            }

            # The app verifies versioned downloads against the recorded checksum, so a new version
            # is only kept once its checksum is known — otherwise the build would ship a stale one
            if ($Dependency.version -ne $PreviousVersion -and -not (Update-DependencyChecksum $Dependency $UrlsFile)) {
                Write-LogWarning "Keeping '$Name' at version $PreviousVersion"
                $Dependency.version = $PreviousVersion
                $ChangeLogs.RemoveAt($ChangeLogs.Count - 1)
            }

            if ($Dependency.version -ne $PreviousVersion) {
                $HasVersionChanges = $True
            }
        } catch {
            $FailedCount++
            Write-LogWarning "Failed to check '$Name' for updates: $_"
            $Dependency.version = $PreviousVersion
            while ($ChangeLogs.Count -gt $ChangeLogCount) {
                $ChangeLogs.RemoveAt($ChangeLogs.Count - 1)
            }
        }

        $Iteration++
    }

    if ($FailedCount -eq $Dependencies.Count) {
        throw 'Failed to check any dependency for updates'
    }

    # A dependency removed, or no longer opening the pull request, leaves nothing behind
    foreach ($StateName in @($QuarantineState.Keys)) {
        if ($StateName -notin $QuarantinedNames) {
            $QuarantineState.Remove($StateName)
        }
    }
    Write-QuarantineState $QuarantineFile $QuarantineState

    Write-ActivityProgress 90

    Set-Variable -Option Constant UrlsToOpen ([String[]]@($ChangeLogs | ForEach-Object { $_ } | Where-Object { $_ } | Select-Object -Unique | Sort-Object))
    Write-LogInfo "$($UrlsToOpen.Count) update(s) found"

    Write-ActivityProgress 95

    # Saved whenever a version changed, not only when there are changelog links: file dependencies
    # never produce any, and neither does a release further back than the recent ones listed
    if ($HasVersionChanges) {
        Write-LogInfo "Saving updated dependencies to $DependenciesFile"
        Write-JsonFile $DependenciesFile $Dependencies
    }

    Write-ActivityCompleted

    return $UrlsToOpen
}
