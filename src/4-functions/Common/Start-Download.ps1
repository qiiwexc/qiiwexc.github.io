function Start-Download {
    param(
        [String][Parameter(Position = 0, Mandatory)]$URL,
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )

    Write-ActivityProgress 10 "Downloading from $URL"

    Set-Variable -Option Constant MaxRetries ([Int]3)

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

    if (Test-Path $SavePath) {
        Write-LogWarning 'Previous download found, returning it'
        return $SavePath
    }

    if (-not (Test-NetworkConnection)) {
        throw 'No network connection detected'
    }

    Initialize-AppDirectory

    Write-ActivityProgress 20

    [Int]$RetryCount = 0
    [Bool]$DownloadSuccess = $False

    while (-not $DownloadSuccess -and $RetryCount -lt $MaxRetries) {
        try {
            $RetryCount++
            if ($RetryCount -gt 1) {
                Write-LogWarning "Download attempt $RetryCount of $MaxRetries"
                Start-Sleep -Seconds 2
            }

            Start-BitsTransfer -Source $URL -Destination $TempPath -Dynamic -ErrorAction Stop
            $DownloadSuccess = $True
        } catch {
            if ($RetryCount -ge $MaxRetries) {
                throw "Download failed after $MaxRetries attempts: $_"
            }
            Write-LogWarning "Download attempt $RetryCount failed: $_"
        }
    }

    if (-not $Temp) {
        Move-Item -Force $TempPath $SavePath -ErrorAction Stop
    }

    if (Test-Path $SavePath) {
        Out-Success
        return $SavePath
    } else {
        throw 'Possibly computer is offline or disk is full'
    }
}
