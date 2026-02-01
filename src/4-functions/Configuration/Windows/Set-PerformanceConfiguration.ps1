function Set-PerformanceConfiguration {
    try {
        Import-RegistryConfiguration 'Windows Performance Config' (Add-SysPrepConfig $CONFIG_PERFORMANCE) -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows performance configuration: $_"
    }
}
