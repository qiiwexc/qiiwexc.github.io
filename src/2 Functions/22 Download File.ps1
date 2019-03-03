function DownloadFile ($URL, $FileName) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $DownloadURL = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    $SavePath = if ($FileName) {$FileName} else {$DownloadURL | Split-Path -Leaf}

    Write-Log $_INF "Downloading from $DownloadURL"

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)

        if (Test-Path "$SavePath") {Write-Log $_WRN 'Download complete'}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {Write-Log $_ERR "Download failed: $($_.Exception.Message)"}
}
