function Start-WinUtil {
    Write-LogInfo 'Starting WinUtil utility...'

    try {
        if (-not (Test-NetworkConnection)) {
            return
        }

        Invoke-CustomCommand '& ([ScriptBlock]::Create((irm "https://christitus.com/win")))'

        Out-Success
    } catch {
        Out-Failure "Failed to start WinUtil utility: $_"
    }
}
