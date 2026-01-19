function Start-Download {
    param(
        [String][Parameter(Position = 0, Mandatory)]$URL,
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )

    Write-ActivityProgress 10 "Downloading from $URL"

    if ($SaveAs) {
        Set-Variable -Option Constant FileName ([String]$SaveAs)
    } else {
        Set-Variable -Option Constant FileName ([String](Split-Path -Leaf $URL -ErrorAction Stop))
    }

    Set-Variable -Option Constant TempPath ([String]"$PATH_APP_DIR\$FileName")

    if ($Temp) {
        Set-Variable -Option Constant SavePath ([String]$TempPath)
    } else {
        Set-Variable -Option Constant SavePath ([String]"$PATH_WORKING_DIR\$FileName")
    }

    Initialize-AppDirectory

    Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
    if (-not $IsConnected) {
        if (Test-Path $SavePath) {
            Write-LogWarning 'Previous download found, returning it'
            return $SavePath
        } else {
            return
        }
    }

    try {
        Start-BitsTransfer -Source $URL -Destination $TempPath -Dynamic -ErrorAction Stop

        if (-not $Temp) {
            Move-Item -Force $TempPath $SavePath -ErrorAction Stop
        }

        if (Test-Path $SavePath) {
            Out-Success
        } else {
            throw 'Possibly computer is offline or disk is full'
        }
    } catch {
        Write-LogError "Download failed: $_"
        return
    }

    return $SavePath
}
