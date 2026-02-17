function Start-Download {
    param(
        [Parameter(Position = 0, Mandatory)][String]$URL,
        [Parameter(Position = 1)][String]$SaveAs,
        [Switch]$Temp,
        [Switch]$NoBits
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

    Write-ActivityProgress 10

    [Int]$RetryCount = 0
    [Bool]$DownloadSuccess = $False

    while (-not $DownloadSuccess -and $RetryCount -lt $MaxRetries) {
        try {
            $RetryCount++
            if ($RetryCount -gt 1) {
                Write-LogWarning "Download attempt $RetryCount of $MaxRetries"
                Start-Sleep -Seconds 2
            }

            if ($NoBits) {
                Invoke-WebRequest -Uri $URL -OutFile $TempPath -UseBasicParsing -ErrorAction Stop
            } else {
                $BitsJob = Start-BitsTransfer -Source $URL -Destination $TempPath -Asynchronous -ErrorAction Stop

                while ($BitsJob.JobState -eq 'Transferring' -or $BitsJob.JobState -eq 'Connecting' -or $BitsJob.JobState -eq 'Queued') {
                    if ($BitsJob.BytesTotal -gt 0) {
                        $DownloadPercent = [Math]::Round(($BitsJob.BytesTransferred / $BitsJob.BytesTotal) * 45 + 10)
                        Write-ActivityProgress $DownloadPercent
                    }
                    Start-Sleep -Milliseconds 200
                }

                if ($BitsJob.JobState -eq 'Error') {
                    $ErrorMessage = $BitsJob.ErrorDescription
                    Remove-BitsTransfer $BitsJob -ErrorAction SilentlyContinue
                    if (Test-Path $TempPath) { Remove-Item $TempPath -Force -ErrorAction SilentlyContinue }
                    throw "BITS transfer error: $ErrorMessage"
                }

                Complete-BitsTransfer $BitsJob -ErrorAction Stop

                if (-not (Test-Path $TempPath) -or (Get-Item $TempPath).Length -eq 0) {
                    if (Test-Path $TempPath) { Remove-Item $TempPath -Force -ErrorAction SilentlyContinue }
                    Write-LogWarning 'BITS transfer returned empty file, retrying with WebRequest'
                    Invoke-WebRequest -Uri $URL -OutFile $TempPath -UseBasicParsing -ErrorAction Stop
                }
            }

            $DownloadSuccess = $True
        } catch {
            if ($RetryCount -ge $MaxRetries) {
                throw "Download failed after $MaxRetries attempts: $_"
            }
            Write-LogWarning "Download attempt $RetryCount failed: $_"
        }
    }

    Write-ActivityProgress 55

    if (-not $Temp) {
        Move-Item -Force $TempPath $SavePath -ErrorAction Stop
    }

    Write-ActivityProgress 60

    if (Test-Path $SavePath) {
        [Long]$FileSize = (Get-Item $SavePath).Length
        if ($FileSize -lt 1KB) {
            Write-LogWarning "Downloaded file is suspiciously small ($FileSize bytes): $SavePath"
        }
        Out-Success
        return $SavePath
    } else {
        throw 'Possibly computer is offline or disk is full'
    }
}
