Function Start-Updates {
    Add-Log $INF 'Starting Windows Update...'

    try { if ($OS_VERSION -gt 7) { Start-Process 'UsoClient' 'StartInteractiveScan' } else { Start-Process 'wuauclt' '/detectnow /updatenow' } }
    catch [Exception] { Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"; Return }

    Out-Success
}
