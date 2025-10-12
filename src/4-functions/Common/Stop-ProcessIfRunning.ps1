function Stop-ProcessIfRunning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ProcessName
    )

    Set-Variable -Option Constant LogIndentLevel 3

    if (Get-Process | Where-Object { $_.ProcessName -eq $ProcessName } ) {
        Write-LogInfo "Stopping process '$AppName'..." $LogIndentLevel
        Stop-Process -Name $ProcessName
        Out-Success $LogIndentLevel
    }
}
