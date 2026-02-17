function Start-Defragmentation {
    try {
        Write-LogInfo 'Starting Optimize Drives...'

        Start-Process 'dfrgui.exe' -ErrorAction Stop

        Out-Success
    } catch {
        Out-Failure "Failed to start Optimize Drives: $_"
    }
}
