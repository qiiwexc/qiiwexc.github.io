function Start-Download {
    param(
        [String][Parameter(Position = 0, Mandatory)]$URL,
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )

    Set-Variable -Option Constant LogIndentLevel 1

    Write-ActivityProgress -PercentComplete 5 -Task "Downloading from $URL"

    if ($SaveAs) {
        Set-Variable -Option Constant FileName $SaveAs
    } else {
        Set-Variable -Option Constant FileName (Split-Path -Leaf $URL)
    }

    Set-Variable -Option Constant TempPath "$PATH_APP_DIR\$FileName"

    if ($Temp) {
        Set-Variable -Option Constant SavePath $TempPath
    } else {
        Set-Variable -Option Constant SavePath "$PATH_WORKING_DIR\$FileName"
    }

    Initialize-AppDirectory

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Download failed: $NoConnection" $LogIndentLevel

        if (Test-Path $SavePath) {
            Write-LogWarning 'Previous download found, returning it' $LogIndentLevel
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
            Out-Success $LogIndentLevel
        } else {
            throw 'Possibly computer is offline or disk is full'
        }
    } catch [Exception] {
        Write-LogException $_ 'Download failed' $LogIndentLevel
        return
    }

    return $SavePath
}
