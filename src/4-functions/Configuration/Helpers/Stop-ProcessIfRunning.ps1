function Stop-ProcessIfRunning {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ProcessName
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]2)

    # The app would write its own settings back over the new ones as it closes, so it is not asked to close but stopped
    if (Find-RunningProcesses $ProcessName) {
        Write-LogWarning "Closing '$ProcessName', which loses anything unsaved in it..." $LogIndentLevel
        Stop-Process -Name $ProcessName -Force -ErrorAction Stop
        Out-Success $LogIndentLevel
    }
}
