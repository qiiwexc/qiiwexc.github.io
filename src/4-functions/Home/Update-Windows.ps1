function Update-Windows {
    Write-LogInfo 'Starting Windows Update...'

    try {
        if ($OS_VERSION -gt 7) {
            Start-Process 'UsoClient' 'StartInteractiveScan'
        } else {
            Start-Process 'wuauclt' '/detectnow /updatenow'
        }
    } catch [Exception] {
        Write-LogException $_ 'Failed to update Windows'
        return
    }

    Out-Success
}
