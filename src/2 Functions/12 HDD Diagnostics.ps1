Function Start-DiskCheck {
    Add-Log $INF 'Starting (C:) disk health check...'

    Set-Variable -Option Constant Command "Start-Process 'chkdsk' $(if ($OS_VERSION -gt 7) { "'/scan /perf'" }) -NoNewWindow"
    try { Start-ExternalProcess -Elevated $Command 'Disk check running...' }
    catch [Exception] { Add-Log $ERR "Failed to check (C:) disk health: $($_.Exception.Message)"; Return }

    Out-Success
}
