function Set-WindowsSecurityConfiguration {
    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    try {
        Write-ActivityProgress 5 'Applying Windows security configuration...'

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

        Out-Success $LogIndentLevel
    } catch {
        Out-Failure "Failed to apply Windows Security configuration: $_" $LogIndentLevel
    }
}
