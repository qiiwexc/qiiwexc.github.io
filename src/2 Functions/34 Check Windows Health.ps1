Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    try { Start-ExternalProcess -Elevated -Title:'Checking Windows health...' "Start-Process 'DISM' '/Online /Cleanup-Image /ScanHealth' -NoNewWindow" }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-Windows {
    Add-Log $INF 'Starting Windows repair...'

    try { Start-ExternalProcess -Elevated -Title:'Repairing Windows...' "Start-Process 'DISM' '/Online /Cleanup-Image /RestoreHealth' -NoNewWindow" }
    catch [Exception] { Add-Log $ERR "Failed to repair Windows: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-SystemFiles {
    Add-Log $INF 'Starting system file integrity check...'

    try { Start-ExternalProcess -Elevated -Title:'Checking system files...' "Start-Process 'sfc' '/scannow' -NoNewWindow" }
    catch [Exception] { Add-Log $ERR "Failed to check system file integrity: $($_.Exception.Message)"; Return }

    Out-Success
}
