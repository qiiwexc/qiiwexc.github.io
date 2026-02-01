function Set-SecurityConfiguration {
    try {
        Import-RegistryConfiguration 'Windows Security Config' (Add-SysPrepConfig $CONFIG_SECURITY) -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows security configuration: $_"
    }
}
