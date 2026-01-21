function Open-InBrowser {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Url
    )

    Write-LogInfo "Opening URL in the default browser: $Url"

    try {
        Start-Process $Url -ErrorAction Stop
    } catch {
        Out-Failure "Could not open the URL: $_"
    }
}
