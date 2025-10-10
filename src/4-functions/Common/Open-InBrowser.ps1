function Open-InBrowser {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL
    )

    Write-LogInfo "Opening URL in the default browser: $URL"

    try {
        [System.Diagnostics.Process]::Start($URL)
    } catch [Exception] {
        Write-LogException $_ 'Could not open the URL'
    }
}
