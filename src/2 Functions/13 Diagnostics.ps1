function CheckDrive {
    Write-Log $INF 'Checking C: drive health'

    try {Start-Process -Wait -Verb RunAs -FilePath 'chkdsk' -ArgumentList '/scan'}
    catch [Exception] {
        Write-Log $ERR "Failed to check drive health: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'C: drive health check completed successfully'
}


function CheckMemory {
    Write-Log $INF 'Starting memory checking tool'

    try {Start-Process -Wait -FilePath 'mdsched'}
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

    Write-Log $INF 'Updating security signatures'

    try {Start-Process -Wait -FilePath $DefenderExe -ArgumentList '-SignatureUpdate'}
    catch [Exception] {
        Write-Log $ERR "Security signature update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $INF "Starting $Mode securtiy scan"

    try {Start-Process -FilePath $DefenderExe -ArgumentList "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})"}
    catch [Exception] {
        Write-Log $ERR "Failed to perform a $Mode securtiy scan: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Securtiy scan started successfully'
}
