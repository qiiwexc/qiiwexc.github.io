function Stop-ProcessIfRunning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ProcessName
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]2)

    if (Find-RunningProcess $ProcessName) {
        Write-LogInfo "Stopping process '$AppName'..." $LogIndentLevel
        Stop-Process -Name $ProcessName -Force -ErrorAction Stop
        Out-Success $LogIndentLevel
    }
}
