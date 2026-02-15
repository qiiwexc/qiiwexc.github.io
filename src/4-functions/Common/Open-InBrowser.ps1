function Open-InBrowser {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Url
    )

    try {
        Write-LogInfo "Opening in the default browser: $Url"
        Start-Process $Url -ErrorAction Stop
    } catch {
        Out-Failure "Could not open the URL: $_"
    }
}
