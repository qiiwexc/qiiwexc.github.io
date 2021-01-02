Function Start-Download {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No download URL specified"),
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )
    if (-not $URL) { Return }

    Set-Variable -Option Constant DownloadURL $(if ($URL -Like 'http*') { $URL } else { 'https://' + $URL })
    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $DownloadURL })
    Set-Variable -Option Constant TempPath "$TEMP_DIR\$FileName"
    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$CURRENT_DIR\$FileName" })

    New-Item -Force -ItemType Directory $TEMP_DIR | Out-Null

    Add-Log $INF "Downloading from $DownloadURL"

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        if (Test-Path $SavePath) { Add-Log $WRN "Previous download found, returning it"; Return $SavePath } else { Return }
    }

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $TempPath)
        if (-not $Temp) { Move-Item -Force -ErrorAction SilentlyContinue $TempPath $SavePath }

        if (Test-Path $SavePath) { Out-Success }
        else { Throw 'Possibly computer is offline or disk is full' }
    }
    catch [Exception] { Add-Log $ERR "Download failed: $($_.Exception.Message)"; Return }

    Return $SavePath
}
