function Test-FileChecksum {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path,
        [Parameter(Position = 1, Mandatory)][String]$Sha256
    )

    Set-Variable -Option Constant ActualHash ([String](Get-FileHash $Path -Algorithm SHA256 -ErrorAction Stop).Hash)

    if ($ActualHash -ne $Sha256.ToUpper()) {
        Remove-Item $Path -Force -ErrorAction SilentlyContinue
        throw "Checksum mismatch for '$Path': expected $($Sha256.ToUpper()), got $ActualHash"
    }
}


function Test-FileSignature {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path,
        [Parameter(Position = 1, Mandatory)][String]$Signer
    )

    Set-Variable -Option Constant Signature ([Object](Get-AuthenticodeSignature -LiteralPath $Path -ErrorAction Stop))

    # The certificate's common name rather than its thumbprint: the name is what the certificate authority
    # verified, and it stays the same when the publisher renews the certificate
    [String]$ActualSigner = ''
    if ($Signature.SignerCertificate) {
        $ActualSigner = $Signature.SignerCertificate.GetNameInfo([Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $False)
    }

    if ($Signature.Status -ne 'Valid' -or $ActualSigner -ne $Signer) {
        Remove-Item $Path -Force -ErrorAction SilentlyContinue
        throw "Signature check failed for '$Path': expected a valid signature of '$Signer', got status '$($Signature.Status)' from '$ActualSigner'"
    }
}


# A job left behind keeps transferring in the background: one that does not complete is removed, whether it failed, BITS
# gave up on it for now (TransientError, Suspended), or the operation was cancelled while it ran
function Invoke-BitsDownload {
    param(
        [Parameter(Position = 0, Mandatory)][String]$URL,
        [Parameter(Position = 1, Mandatory)][String]$Destination
    )

    $BitsJob = Start-BitsTransfer -Source $URL -Destination $Destination -Asynchronous -ErrorAction Stop

    [Bool]$Completed = $False
    try {
        while ($BitsJob.JobState -eq 'Transferring' -or $BitsJob.JobState -eq 'Connecting' -or $BitsJob.JobState -eq 'Queued') {
            if ($BitsJob.BytesTotal -gt 0) {
                Write-ActivityProgress ([Math]::Round(($BitsJob.BytesTransferred / $BitsJob.BytesTotal) * 45 + 10))
            }
            Start-Sleep -Milliseconds 200
        }

        if ($BitsJob.JobState -ne 'Transferred') {
            throw "BITS transfer error ($($BitsJob.JobState)): $($BitsJob.ErrorDescription)"
        }

        Complete-BitsTransfer $BitsJob -ErrorAction Stop
        $Completed = $True
    } finally {
        if (-not $Completed) {
            Remove-BitsTransfer $BitsJob -ErrorAction SilentlyContinue
            if (Test-Path $Destination) {
                Remove-Item $Destination -Force -ErrorAction SilentlyContinue
            }
        }
    }
}


function Start-Download {
    param(
        [Parameter(Position = 0, Mandatory)][String]$URL,
        [Parameter(Position = 1)][String]$SaveAs,
        [String]$Sha256,
        [String]$Signer,
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
        # A pinned download whose URL does not name the version keeps its file name when the pin moves
        # on, so a previous copy that no longer passes is replaced (the check deletes it) rather than refused
        [Bool]$IsCurrent = $True
        if ($Sha256 -or $Signer) {
            try {
                if ($Sha256) {
                    Test-FileChecksum $SavePath $Sha256
                }
                if ($Signer) {
                    Test-FileSignature $SavePath $Signer
                }
            } catch {
                $IsCurrent = $False
                Write-LogWarning 'Previous download does not pass verification, downloading it again'
            }
        }

        if ($IsCurrent) {
            Write-LogWarning 'Previous download found, returning it'
            return $SavePath
        }
    }

    if (-not (Test-NetworkConnection)) {
        throw 'No network connection detected'
    }

    Initialize-AppDirectory

    Write-ActivityProgress 10

    [Int]$RetryCount = 0
    [Bool]$DownloadSuccess = $False
    [Bool]$UseBits = -not $NoBits

    while (-not $DownloadSuccess -and $RetryCount -lt $MaxRetries) {
        try {
            $RetryCount++
            if ($RetryCount -gt 1) {
                Write-LogWarning "Download attempt $RetryCount of $MaxRetries"
                Start-Sleep -Seconds 2
            }

            if ($UseBits) {
                try {
                    Invoke-BitsDownload $URL $TempPath
                } catch {
                    # BITS refuses some accounts outright, such as an administrator's whose credentials a standard user
                    # elevated the app with, who is not signed in. A web request does not depend on the account, so it
                    # takes over for this attempt and every one after it
                    $UseBits = $False
                    Write-LogWarning "BITS transfer failed, downloading with a web request instead: $_"
                }
            }

            if (-not $UseBits) {
                Invoke-WebRequest -Uri $URL -OutFile $TempPath -UseBasicParsing -ErrorAction Stop
            } elseif (-not (Test-Path $TempPath) -or (Get-Item $TempPath).Length -eq 0) {
                if (Test-Path $TempPath) { Remove-Item $TempPath -Force -ErrorAction SilentlyContinue }
                Write-LogWarning 'BITS transfer returned empty file, retrying with WebRequest'
                Invoke-WebRequest -Uri $URL -OutFile $TempPath -UseBasicParsing -ErrorAction Stop
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
        if ($Sha256) {
            Test-FileChecksum $SavePath $Sha256
        }
        if ($Signer) {
            Test-FileSignature $SavePath $Signer
        }
        Out-Success
        return $SavePath
    } else {
        throw 'Possibly computer is offline or disk is full'
    }
}
