function Open-InBrowser {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Url
    )

    try {
        Write-LogInfo "Opening in the default browser: $Url"
        # A browser started by this process would run elevated, whatever site it then goes on to load
        Start-FromShell $Url
    } catch {
        Out-Failure "Could not open the URL: $_"
    }
}
