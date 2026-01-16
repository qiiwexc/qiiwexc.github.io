function Set-NewVersion {
    param(
        [PSCustomObject][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1)]$LatestVersion
    )

    Write-LogInfo "New version available: $LatestVersion" 1
    $Dependency.version = $LatestVersion
}
