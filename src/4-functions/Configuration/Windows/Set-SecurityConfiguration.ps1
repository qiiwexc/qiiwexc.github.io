function Set-SecurityConfiguration {
    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_SECURITY

    # Security.reg turns LSA protection on without its UEFI lock, which only Windows 11 22H2 and later read. The Windows
    # before it get the value they read, lock included: later in the file, it is the one written
    if ([Int]$OPERATING_SYSTEM.Version.Split('.')[2] -lt 22621) {
        $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA]`n")
        $ConfigLines.Add("`"RunAsPPL`"=dword:00000001`n")
    }

    try {
        Import-RegistryConfiguration 'Windows Security Config' $ConfigLines -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to apply Windows security configuration: $_"
    }
}
