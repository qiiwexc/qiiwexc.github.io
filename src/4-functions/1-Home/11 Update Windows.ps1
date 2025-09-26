function Update-Windows {
    Write-Log $INF 'Starting Windows Update...'

    try {
        if ($OS_VERSION -gt 7) {
            Start-Process 'UsoClient' 'StartInteractiveScan'
        } else {
            Start-Process 'wuauclt' '/detectnow /updatenow'
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to update Windows'
        return
    }

    Out-Success
}
