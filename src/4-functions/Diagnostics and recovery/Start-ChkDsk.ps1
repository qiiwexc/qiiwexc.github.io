function Start-ChkDsk {
    try {
        Write-LogInfo 'Starting Check Disk...'

        Start-Process 'chkdsk' 'C:' -ErrorAction Stop

        Out-Success
    } catch {
        Out-Failure "Failed to start Check Disk: $_"
    }
}
