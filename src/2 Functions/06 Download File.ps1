Function Start-Download {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )

    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $URL })
    Set-Variable -Option Constant TempPath "$PATH_TEMP_DIR\$FileName"
    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$PATH_CURRENT_DIR\$FileName" })

    New-Item -Force -ItemType Directory $PATH_TEMP_DIR | Out-Null

    Add-Log $INF "Downloading from $URL"

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"

        if (Test-Path $SavePath) {
            Add-Log $WRN "Previous download found, returning it"
            Return $SavePath
        } else {
            Return
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
            Throw 'Possibly computer is offline or disk is full'
        }
    } catch [Exception] {
        Add-Log $ERR "Download failed: $($_.Exception.Message)"
        Return
    }

    Return $SavePath
}
