Function Start-Download {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No download URL specified"),
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )
    if (-not $URL) { Return }

    Set-Variable -Option Constant DownloadURL $(if ($URL -like 'http*') { $URL } else { 'https://' + $URL })
    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { $DownloadURL.Split('/') | Select-Object -Last 1 })
    Set-Variable -Option Constant BaseDir $(if ($Temp) { $TEMP_DIR } else { $CURRENT_DIR })
    Set-Variable -Option Constant SavePath "$BaseDir\$FileName"

    if (-not (Test-Path $BaseDir)) {
        Add-Log $WRN "Download path $BaseDir does not exist. Creating it."
        New-Item $BaseDir -ItemType Directory -Force | Out-Null
    }

    Add-Log $INF "Downloading from $DownloadURL"

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) { Add-Log $ERR "Download failed: $IsNotConnected"; Return }

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)
        if (Test-Path $SavePath) { Out-Success }
        else { Throw 'Possibly computer is offline or disk is full' }
    }
    catch [Exception] { Add-Log $ERR "Download failed: $($_.Exception.Message)"; Return }

    Return $SavePath
}
