function CheckDrive {
    Write-Log $INF 'Starting C: drive health check...'

    try {Start-Process 'chkdsk' '/scan' -Verb RunAs }
    catch [Exception] {
        Write-Log $ERR "Failed to check drive health: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'C: drive health check is running'
}


function CheckMemory {
    Write-Log $INF 'Starting memory checking tool...'

    try {Start-Process 'mdsched' -Wait}
    catch [Exception] {
        Write-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Memory checking tool was closed'
}


function StartSecurityScan ($Mode) {
    if (-not $Mode) {
        Write-Log $WRN "Scan mode not specified, assuming 'quick'"
        $Mode = 'quick'
    }

    Write-Log $INF 'Updating security signatures...'

    try {Start-Process $DefenderExe '-SignatureUpdate' -Wait}
    catch [Exception] {
        Write-Log $ERR "Security signature update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $INF "Starting $Mode securtiy scan..."

    try {Start-Process $DefenderExe "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})"}
    catch [Exception] {
        Write-Log $ERR "Failed to perform a $Mode securtiy scan: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Securtiy scan started successfully'
}
