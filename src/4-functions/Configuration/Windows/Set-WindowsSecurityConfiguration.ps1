function Set-WindowsSecurityConfiguration {
    Set-MpPreference -CheckForSignaturesBefore $True
    Set-MpPreference -DisableBlockAtFirstSeen $False
    Set-MpPreference -DisableCatchupQuickScan $False
    Set-MpPreference -DisableEmailScanning $False
    Set-MpPreference -DisableRemovableDriveScanning $False
    Set-MpPreference -DisableRestorePoint $False
    Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $False
    Set-MpPreference -DisableScanningNetworkFiles $False
    Set-MpPreference -EnableFileHashComputation $True
    Set-MpPreference -EnableNetworkProtection Enabled
    Set-MpPreference -PUAProtection Enabled
    Set-MpPreference -AllowSwitchToAsyncInspection $True
    Set-MpPreference -MeteredConnectionUpdates $True
    Set-MpPreference -IntelTDTEnabled $True
    Set-MpPreference -BruteForceProtectionLocalNetworkBlocking $True
}
