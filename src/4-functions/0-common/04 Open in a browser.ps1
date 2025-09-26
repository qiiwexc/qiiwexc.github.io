function Open-InBrowser {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL
    )

    Write-Log $INF "Opening URL in the default browser: $URL"

    try {
        [System.Diagnostics.Process]::Start($URL)
    } catch [Exception] {
        Write-ExceptionLog $_ 'Could not open the URL'
    }
}
