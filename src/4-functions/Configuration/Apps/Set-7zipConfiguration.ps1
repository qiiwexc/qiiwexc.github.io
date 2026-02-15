function Set-7zipConfiguration {
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName
    )

    try {
        Import-RegistryConfiguration $AppName (Add-SysPrepConfig $CONFIG_7ZIP)
        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
