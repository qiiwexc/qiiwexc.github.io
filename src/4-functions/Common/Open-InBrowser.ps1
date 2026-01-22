function Open-InBrowser {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Url
    )

    try {
        Write-LogInfo "Opening URL in the default browser: $Url"
        Start-Process $Url -ErrorAction Stop
    } catch {
        Out-Failure "Could not open the URL: $_"
    }
}
