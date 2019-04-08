function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    try { Start-Process 'DISM' '/Online /Cleanup-Image /ScanHealth' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Repair-Windows {
    Add-Log $INF 'Starting Windows repair...'

    try { Start-Process 'DISM' '/Online /Cleanup-Image /RestoreHealth' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to repair Windows: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Repair-SystemFiles {
    Add-Log $INF 'Starting system file integrity check...'

    try { Start-Process 'sfc' '/scannow' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to check system file integrity: $($_.Exception.Message)"
        return
    }

    Out-Success
}
