function Open-InBrowser {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Url
    )

    Write-LogInfo "Opening URL in the default browser: $Url"

    try {
        Start-Process $Url
    } catch [Exception] {
        Write-LogException $_ 'Could not open the URL'
    }
}
