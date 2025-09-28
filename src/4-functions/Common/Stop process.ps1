function Stop-ProcessIfRunning {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ProcessName
    )

    if (Get-Process | Where-Object { $_.ProcessName -eq $ProcessName } ) {
        Write-LogInfo "Stopping process '$AppName'..."
        Stop-Process -Name $ProcessName
        Out-Success
    }
}
