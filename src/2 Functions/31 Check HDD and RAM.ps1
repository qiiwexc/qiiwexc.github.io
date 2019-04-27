function Start-DriveCheck {
    Param([Switch][Parameter(Position = 0)]$FullScan)

    Add-Log $INF 'Starting (C:) drive health check...'

    try {
        if ($FullScan) { Start-Process 'chkdsk' '/B' -Verb RunAs } else {
            if ($OS_VERSION -gt 7) { Start-Process 'chkdsk' '/scan /perf' -Verb RunAs } else { Start-Process 'chkdsk' -Verb RunAs }
        }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to check (C:) drive health: $($_.Exception.Message)"
        Return
    }

    Out-Success
}


function Start-MemoryCheckTool {
    Add-Log $INF 'Starting memory checking tool...'

    try { Start-Process 'mdsched' }
    catch [Exception] {
        Add-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        Return
    }

    Out-Success
}
