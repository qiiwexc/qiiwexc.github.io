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
