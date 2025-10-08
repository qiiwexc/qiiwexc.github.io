function Start-Download {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )

    Write-ActivityProgress -PercentComplete 5 -Task "Downloading from $URL"

    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $URL })
    Set-Variable -Option Constant TempPath "$PATH_APP_DIR\$FileName"
    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$PATH_WORKING_DIR\$FileName" })

    Initialize-AppDirectory

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Download failed: $NoConnection"

        if (Test-Path $SavePath) {
            Write-LogWarning 'Previous download found, returning it'
            return $SavePath
        } else {
            return
        }
    }

    try {
        Start-BitsTransfer -Source $URL -Destination $TempPath -Dynamic

        if (-not $Temp) {
            Move-Item -Force $TempPath $SavePath
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
