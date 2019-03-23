function Start-DriveCheck {
    Add-Log $INF 'Starting C: drive health check...'

    try {Start-Process 'chkdsk' '/scan' -Verb RunAs}
    catch [Exception] {
        Add-Log $ERR "Failed to check drive health: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-MemoryCheckTool {
    Add-Log $INF 'Starting memory checking tool...'

    try {Start-Process 'mdsched'}
    catch [Exception] {
        Add-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-SecurityScan ($Mode) {
    if (-not $Mode) {
        Add-Log $WRN "Scan mode not specified, assuming 'quick'"
        $Mode = 'quick'
    }

    Add-Log $INF 'Updating security signatures...'

    try {Start-Process $DefenderExe '-SignatureUpdate' -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"
        return
    }

    Set-Success
    Add-Log $INF "Starting $Mode securtiy scan..."

    try {Start-Process $DefenderExe "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})"}
    catch [Exception] {
        Add-Log $ERR "Failed to perform a $Mode securtiy scan: $($_.Exception.Message)"
        return
    }

    Set-Success
}
