function OpenInBrowser ($URL) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    Write-Log $_INF "Openning URL in the default browser: $UrlToOpen"
    try {[System.Diagnostics.Process]::Start($UrlToOpen)}
    catch [Exception] {Write-Log $_ERR "Could not open the URL: $($_.Exception.Message)"}
}
