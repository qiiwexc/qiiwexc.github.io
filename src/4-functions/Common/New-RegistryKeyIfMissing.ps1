function New-RegistryKeyIfMissing {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$RegistryPath
    )

    if (-not (Test-Path $RegistryPath)) {
        Write-LogInfo "Creating registry key '$RegistryPath'"
        New-Item $RegistryPath
    }
}
