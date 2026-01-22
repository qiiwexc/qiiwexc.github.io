function Update-Windows {
    try {
        Write-LogInfo 'Starting Windows Update...'

        if ($OS_VERSION -gt 7) {
            Start-Process 'UsoClient' 'StartInteractiveScan' -ErrorAction Stop
        } else {
            Start-Process 'wuauclt' '/detectnow /updatenow' -ErrorAction Stop
        }

        Out-Success
    } catch {
        Out-Failure "Failed to update Windows: $_"
    }
}
