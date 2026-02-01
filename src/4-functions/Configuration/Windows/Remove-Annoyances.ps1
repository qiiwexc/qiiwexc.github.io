function Remove-Annoyances {
    try {
        Import-RegistryConfiguration 'Remove Windows Annoyances' (Add-SysPrepConfig $CONFIG_ANNOYANCES) -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to remove Windows annoyances: $_"
    }
}
