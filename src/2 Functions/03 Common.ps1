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


function Get-NetworkAdapter { return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }


function Get-ConnectionStatus { if (-not (Get-NetworkAdapter)) { return 'Computer is not connected to the Internet' } }
