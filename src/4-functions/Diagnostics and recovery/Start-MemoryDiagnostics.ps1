function Start-MemoryDiagnostics {
    try {
        Write-LogInfo 'Starting Windows Memory Diagnostic...'

        Start-Process 'mdsched.exe' -ErrorAction Stop

        Out-Success
    } catch {
        Out-Failure "Failed to start Windows Memory Diagnostic: $_"
    }
}
