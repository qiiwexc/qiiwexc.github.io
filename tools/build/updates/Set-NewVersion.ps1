function Set-NewVersion {
    param(
        [Dependency][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$LatestVersion
    )

    Write-LogInfo "New version available: $LatestVersion"
    $Dependency.version = $LatestVersion
}
