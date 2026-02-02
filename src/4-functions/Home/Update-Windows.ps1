function Update-Windows {
    try {
        Write-LogInfo 'Starting Windows Update...'

        Start-Process 'UsoClient' 'StartInteractiveScan' -ErrorAction Stop

        Out-Success
    } catch {
        Out-Failure "Failed to update Windows: $_"
    }
}
