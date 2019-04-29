function Start-SecurityScan {
    Param([String][Parameter(Position = 0)][ValidateSet('quick', 'full')]$Mode = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No scan mode specified"))
    if (-not $Mode) { Return }

    if ($OS_VERSION -gt 7) {
        Add-Log $INF 'Updating security signatures...'

        try { Start-Process $DefenderExe '-SignatureUpdate' -Wait }
        catch [Exception] { Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"; Return }

        Out-Success
    }

    Add-Log $INF "Starting $Mode security scan..."

    try { Start-Process $DefenderExe "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})" }
    catch [Exception] { Add-Log $ERR "Failed to perform a $Mode security scan: $($_.Exception.Message)"; Return }

    Out-Success
}
