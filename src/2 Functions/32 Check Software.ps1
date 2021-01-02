Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    Set-Variable -Option Constant ComponentCleanup $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /StartComponentCleanup'" })
    Set-Variable -Option Constant ScanHealth "Start-Process -NoNewWindow 'DISM' '/Online /Cleanup-Image /StartComponentCleanup'"

    try { Start-ExternalProcess -Elevated -Title:'Checking Windows health...' @($ComponentCleanup, $ScanHealth) }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-Windows {
    Add-Log $INF 'Starting Windows repair...'

    try { Start-ExternalProcess -Elevated -Title:'Repairing Windows...' "Start-Process -NoNewWindow 'DISM' '/Online /Cleanup-Image /RestoreHealth'" }
    catch [Exception] { Add-Log $ERR "Failed to repair Windows: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-SystemFiles {
    Add-Log $INF 'Starting system file integrity check...'

    try { Start-ExternalProcess -Elevated -Title:'Checking system files...' "Start-Process -NoNewWindow 'sfc' '/scannow'" }
    catch [Exception] { Add-Log $ERR "Failed to check system file integrity: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-SecurityScan {
    if ($OS_VERSION -gt 7) {
        Add-Log $INF 'Updating security signatures...'

        try { Start-ExternalProcess -Wait -Title:'Updating security signatures...' "Start-Process '$DefenderExe' '-SignatureUpdate' -NoNewWindow" }
        catch [Exception] { Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"; Return }

        Out-Success
    }

    Add-Log $INF "Performing a security scan..."

    try { Start-ExternalProcess -Title:'Security scan is running...' "Start-Process '$DefenderExe' '-Scan -ScanType 2' -NoNewWindow" }
    catch [Exception] { Add-Log $ERR "Failed to perform a security scan: $($_.Exception.Message)"; Return }

    Out-Success
}
