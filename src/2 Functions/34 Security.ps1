function Start-SecurityScan ($Mode) {
    if (-not $Mode) {
        Add-Log $WRN "Scan mode not specified, assuming 'quick'"
        $Mode = 'quick'
    }

    Add-Log $INF 'Updating security signatures...'

    try { Start-Process $DefenderExe '-SignatureUpdate' -Wait }
    catch [Exception] {
        Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"
        return
    }

    Out-Success
    Add-Log $INF "Starting $Mode security scan..."

    try { Start-Process $DefenderExe "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})" }
    catch [Exception] {
        Add-Log $ERR "Failed to perform a $Mode security scan: $($_.Exception.Message)"
        return
    }

    Out-Success
}
