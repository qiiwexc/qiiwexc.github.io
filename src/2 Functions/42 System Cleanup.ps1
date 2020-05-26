Function Start-DiskCleanup {
    Add-Log $INF 'Starting disk cleanup utility...'

    try { Start-Process -Verb RunAs 'cleanmgr' '/lowdisk' }
    catch [Exception] { Add-Log $ERR "Failed to start disk cleanup utility: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-CCleaner {
    if (-not $CCleanerWarningShown) {
        Add-Log $WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Add-Log $WRN 'Click the button again to continue'
        Set-Variable -Option Constant -Scope Script CCleanerWarningShown $True
        Return
    }

    Add-Log $INF 'Starting CCleaner background task...'

    try { Start-Process $CCleanerExe '/auto' }
    catch [Exception] { Add-Log $ERR "Failed to start CCleaner: $($_.Exception.Message)"; Return }

    Out-Success
}
