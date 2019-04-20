function Open-InBrowser ($Url) {
    if ($Url.length -lt 1) {
        Add-Log $ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($Url -like 'http*') { $Url } else { 'https://' + $Url }
    Add-Log $INF "Opening URL in the default browser: $UrlToOpen"

    try { [System.Diagnostics.Process]::Start($UrlToOpen) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


function Get-ConnectionStatus {
    if ($PS_VERSION -gt 2) {
        return $(if (-not (Get-NetAdapter -Physical | Where-Object Status -eq 'Up')) { 'Computer is not connected to the Internet' })
    }
}
