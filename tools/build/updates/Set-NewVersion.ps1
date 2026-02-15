function Set-NewVersion {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][Dependency]$Dependency,
        [Parameter(Position = 1)][ValidateNotNullOrEmpty()][String]$LatestVersion
    )

    Write-LogInfo "New version available: $LatestVersion"
    $Dependency.version = $LatestVersion
}
