function Set-7zipConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        Import-RegistryConfiguration $AppName (Add-SysPrepConfig $CONFIG_7ZIP)
        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
