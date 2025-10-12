function Open-InBrowser {
    param(
        [String][Parameter(Position = 0, Mandatory)]$URL
    )

    Write-LogInfo "Opening URL in the default browser: $URL"

    try {
        [Diagnostics.Process]::Start($URL)
    } catch [Exception] {
        Write-LogException $_ 'Could not open the URL'
    }
}
