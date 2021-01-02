Function Start-DiskCheck {
    Param([Switch][Parameter(Position = 0)]$FullScan)

    Add-Log $INF 'Starting (C:) disk health check...'

    Set-Variable -Option Constant Command "Start-Process 'chkdsk' $(if ($FullScan) { "'/B'" } elseif ($OS_VERSION -gt 7) { "'/scan /perf'" }) -NoNewWindow"
    try { Start-ExternalProcess -Elevated $Command 'Disk check running...' }
    catch [Exception] { Add-Log $ERR "Failed to check (C:) disk health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-MemoryCheckTool {
    Add-Log $INF 'Starting memory checking tool...'

    try { Start-Process 'mdsched' }
    catch [Exception] { Add-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"; Return }

    Out-Success
}
