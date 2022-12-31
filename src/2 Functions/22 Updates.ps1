Function Start-Updates {
    if ($OS_VERSION -gt 7) {
        Add-Log $INF 'Starting Microsoft Office update...'

        try { Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user' }
        catch [Exception] { Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"; Return }

        Out-Success
    }
    Add-Log $INF 'Starting Windows Update...'

    try { if ($OS_VERSION -gt 7) { Start-Process 'UsoClient' 'StartInteractiveScan' } else { Start-Process 'wuauclt' '/detectnow /updatenow' } }
    catch [Exception] { Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"; Return }

    Out-Success
}
