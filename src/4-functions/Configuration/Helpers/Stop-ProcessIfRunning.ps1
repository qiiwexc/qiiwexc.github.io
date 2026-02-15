function Stop-ProcessIfRunning {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ProcessName
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]2)

    if (Find-RunningProcesses $ProcessName) {
        Write-LogInfo "Stopping process '$ProcessName'..." $LogIndentLevel
        Stop-Process -Name $ProcessName -Force -ErrorAction Stop
        Out-Success $LogIndentLevel
    }
}
