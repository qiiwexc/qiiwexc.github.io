function Clear-RecycleBin {
    Add-Log $INF 'Emptying Recycle Bin...'

    try {(New-Object -ComObject Shell.Application).Namespace(0xA).Items() | ForEach-Object {Remove-Item $_.Path -Recurse -Confirm:$False}}
    catch [Exception] {
        Add-Log $ERR "Failed to empty Recycle Bin: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-DiskCleanup {
    Add-Log $INF 'Starting disk cleanup utility...'

    try {Start-Process 'cleanmgr' '/lowdisk' -Verb RunAs}
    catch [Exception] {
        Add-Log $ERR "Failed to start disk cleanup utility: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-CCleaner {
    if (-not $CCleanerWarningShown) {
        Add-Log $WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Add-Log $WRN 'Click the button again to contunue'
        $script:CCleanerWarningShown = $True
        return
    }

    Add-Log $INF 'Starting CCleaner background task...'

    try {Start-Process $CCleanerExe '/auto'}
    catch [Exception] {
        Add-Log $ERR "Failed to start CCleaner: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-WindowsCleanup {
    Add-Log $INF 'Starting Windows update cleanup...'

    try {Start-Process 'DISM' '/Online /Cleanup-Image /StartComponentCleanup' -Verb RunAs}
    catch [Exception] {
        Add-Log $ERR "Failed to cleanup Windows updates: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Remove-RestorePoints {
    Add-Log $INF 'Deleting all restore points...'

    try {Start-Process 'vssadmin' 'delete shadows /all' -Verb RunAs -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to delete all restore points: $($_.Exception.Message)"
        return
    }

    Out-Success
}