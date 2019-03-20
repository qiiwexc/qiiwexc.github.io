function CheckDrive {
    Write-Log $_INF 'Checking C: drive health'

    try {Start-Process -Wait -Verb RunAs -FilePath 'chkdsk' -ArgumentList '/scan'}
    catch [Exception] {
        Write-Log $_ERR "Failed to check drive health: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'C: drive health check completed successfully'
}


function CheckMemory {
    Write-Log $_INF 'Starting memory checking tool'

    try {Start-Process -Wait -FilePath 'mdsched'}
    catch [Exception] {
        Write-Log $_ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Memory checking tool was closed'
}


function StartSecurityScan ($Mode) {
    if (-not $Mode) {
        Write-Log $_WRN "Scan mode not specified, assuming 'quick'"
        $Mode = 'quick'
    }

    Write-Log $_INF 'Updating security signatures'

    try {Start-Process -Wait -FilePath $DefenderExe -ArgumentList '-SignatureUpdate'}
    catch [Exception] {
        Write-Log $_ERR "Security signature update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $_INF "Starting $Mode securtiy scan"

    try {Start-Process -FilePath $DefenderExe -ArgumentList "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})"}
    catch [Exception] {
        Write-Log $_ERR "Failed to perform a $Mode securtiy scan: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Securtiy scan started successfully'
}
