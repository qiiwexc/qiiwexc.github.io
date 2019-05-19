Function Start-DiskCheck {
    Param([Switch][Parameter(Position = 0)]$FullScan)

    Add-Log $INF 'Starting (C:) disk health check...'

    Set-Variable Parameters $(if ($FullScan) { "'/B'" } elseif ($OS_VERSION -gt 7) { "'/scan /perf'" }) -Option Constant

    try { Start-Process 'PowerShell' "-Command `"(Get-Host).UI.RawUI.WindowTitle = 'Disk check running...'; Start-Process 'chkdsk' $Parameters -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to check (C:) disk health: $($_.Exception.Message)"; Return }

    Out-Success
}
