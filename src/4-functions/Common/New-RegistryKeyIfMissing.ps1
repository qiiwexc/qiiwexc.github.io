function New-RegistryKeyIfMissing {
    param(
        [String][Parameter(Position = 0, Mandatory)]$RegistryPath
    )

    if (-not (Test-Path $RegistryPath)) {
        Write-LogDebug "Creating registry key '$RegistryPath'"
        New-Item $RegistryPath
    }
}
