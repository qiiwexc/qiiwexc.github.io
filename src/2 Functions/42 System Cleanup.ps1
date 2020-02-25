Function Remove-Trash {
    Add-Log $INF 'Emptying Recycle Bin...'

    try {
        if ($PS_VERSION -ge 5) { Clear-RecycleBin -Force }
        else {
            Set-Variable -Option Constant Command '(New-Object -ComObject Shell.Application).Namespace(0xA).Items() | ForEach-Object { Remove-Item -Force -Recurse $_.Path }'
            Start-ExternalProcess -Elevated $Command 'Emptying Recycle Bin...'
        }
    }
    catch [Exception] { Add-Log $ERR "Failed to empty Recycle Bin: $($_.Exception.Message)"; Return }

    Out-Success
}


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


Function Start-WindowsCleanup {
    Add-Log $INF 'Starting Windows update cleanup...'

    try { Start-ExternalProcess -Elevated -Title:'Cleaning Windows...' "Start-Process 'DISM' '/Online /Cleanup-Image /StartComponentCleanup' -NoNewWindow" }
    catch [Exception] { Add-Log $ERR "Failed to cleanup Windows updates: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Remove-RestorePoints {
    Add-Log $INF 'Deleting all restore points...'

    try { Start-ExternalProcess -Elevated -Title:'Deleting restore points...' "Start-Process 'vssadmin' 'delete shadows /all /quiet' -NoNewWindow" }
    catch [Exception] { Add-Log $ERR "Failed to delete all restore points: $($_.Exception.Message)"; Return }

    Out-Success
}
