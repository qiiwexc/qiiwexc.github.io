function New-RegistryKeyIfMissing {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$RegistryPath
    )

    if (-not (Test-Path $RegistryPath)) {
        New-Item $RegistryPath
    }
}
