function Start-Download {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No download URL specified"),
        [String][Parameter(Position = 1)]$SaveAs
    )
    if (-not $URL) { Return }

    $DownloadURL = if ($URL -like 'http*') { $URL } else { 'https://' + $URL }
    $FileName = if ($SaveAs) { $SaveAs } else { $DownloadURL.Split('/') | Select-Object -Last 1 }
    $SavePath = "$CURRENT_DIR\$FileName"

    if (-not (Test-Path $CURRENT_DIR)) {
        Add-Log $WRN "Download path $CURRENT_DIR does not exist. Creating it."
        New-Item $CURRENT_DIR -ItemType Directory -Force | Out-Null
    }

    Add-Log $INF "Downloading from $DownloadURL"

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        Return
    }

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)
        if (Test-Path $SavePath) { Out-Success }
        else { Throw 'Possibly computer is offline or disk is full' }
    }
    catch [Exception] {
        Add-Log $ERR "Download failed: $($_.Exception.Message)"
        Return
    }

    Return $FileName
}
