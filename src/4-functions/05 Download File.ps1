function Start-Download {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )

    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $URL })
    Set-Variable -Option Constant TempPath "$PATH_APP_DIR\$FileName"
    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$PATH_CURRENT_DIR\$FileName" })

    New-Item -Force -ItemType Directory $PATH_APP_DIR | Out-Null

    Write-Log $INF "Downloading from $URL"

    Set-Variable -Option Constant IsNotConnected (Test-NetworkConnection)
    if ($IsNotConnected) {
        Write-Log $ERR "Download failed: $IsNotConnected"

        if (Test-Path $SavePath) {
            Write-Log $WRN 'Previous download found, returning it'
            return $SavePath
        } else {
            return
        }
    }

    try {
        Remove-Item -Force -ErrorAction SilentlyContinue $SavePath
        (New-Object System.Net.WebClient).DownloadFile($URL, $TempPath)

        if (!$Temp) {
            Move-Item -Force -ErrorAction SilentlyContinue $TempPath $SavePath
        }

        if (Test-Path $SavePath) {
            Out-Success
        } else {
            throw 'Possibly computer is offline or disk is full'
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Download failed'
        return
    }

    return $SavePath
}
