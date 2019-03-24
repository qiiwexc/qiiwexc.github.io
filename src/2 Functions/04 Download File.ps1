function Start-Download ($Url, $SaveAs) {
    if ($Url.length -lt 1) {
        Add-Log $ERR 'Download failed: No download URL specified'
        return
    }

    $DownloadURL = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    $FileName = if ($SaveAs) {$SaveAs} else {$DownloadURL | Split-Path -Leaf}
    $SavePath = "$CURRENT_DIR\$FileName"

    Add-Log $INF "Downloading from $DownloadURL"

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        return
    }

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)
        if (Test-Path $SavePath) {Out-Success}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Add-Log $ERR "Download failed: $($_.Exception.Message)"
        return
    }

    return $FileName
}
