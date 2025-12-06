function Stop-ProcessIfRunning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ProcessName
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]3)

    if (Get-Process | Where-Object { $_.ProcessName -eq $ProcessName } ) {
        Write-LogInfo "Stopping process '$AppName'..." $LogIndentLevel
        Stop-Process -Name $ProcessName -Force
        Out-Success $LogIndentLevel
    }
}
