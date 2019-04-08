function Start-DriveCheck {
    Add-Log $INF 'Starting (C:) drive health check...'

    try { Start-Process 'chkdsk' '/scan' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to check (C:) drive health: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-MemoryCheckTool {
    Add-Log $INF 'Starting memory checking tool...'

    try { Start-Process 'mdsched' }
    catch [Exception] {
        Add-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        return
    }

    Out-Success
}
