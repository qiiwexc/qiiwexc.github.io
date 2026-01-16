function Update-Windows {
    Write-LogInfo 'Starting Windows Update...'

    try {
        if ($OS_VERSION -gt 7) {
            Start-Process 'UsoClient' 'StartInteractiveScan' -ErrorAction Stop
        } else {
            Start-Process 'wuauclt' '/detectnow /updatenow' -ErrorAction Stop
        }

        Out-Success
    } catch {
        Write-LogError "Failed to update Windows: $_"
    }
}
