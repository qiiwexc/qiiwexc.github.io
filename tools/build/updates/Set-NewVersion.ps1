function Set-NewVersion {
    param(
        [ValidateNotNull()][Dependency][Parameter(Position = 0, Mandatory)]$Dependency,
        [ValidateNotNullOrEmpty()][String][Parameter(Position = 1)]$LatestVersion
    )

    Write-LogInfo "New version available: $LatestVersion"
    $Dependency.version = $LatestVersion
}
