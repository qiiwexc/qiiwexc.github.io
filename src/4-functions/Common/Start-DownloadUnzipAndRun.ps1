Set-Variable -Scope Script -Name AV_WARNINGS_SHOWN -Value ([Collections.Generic.HashSet[String]]::new())

function Start-DownloadUnzipAndRun {
    param(
        [Parameter(Position = 0, Mandatory)][String]$URL,
        [Parameter(Position = 1)][String]$FileName,
        [Parameter(Position = 2)][String]$Params,
        [String]$ConfigFile,
        [String]$Configuration,
        [Switch]$Execute,
        [Switch]$Silent,
        [Switch]$NoBits,
        [Switch]$AVWarning
    )

    New-Activity 'Download and run'

    if ($AVWarning -and (Test-AntivirusEnabled)) {
        if (-not $script:AV_WARNINGS_SHOWN.Contains($URL)) {
            [void]$script:AV_WARNINGS_SHOWN.Add($URL)
            Write-LogWarning 'Antivirus software is enabled. This download may cause false-positive detections. Please temporarily disable your antivirus and try again.'
            Write-ActivityCompleted
            return
        }
    }

    try {
        Set-Variable -Option Constant UrlEnding ([String]$URL.Split('.')[-1].ToLower())
        Set-Variable -Option Constant IsArchive ([Bool]($UrlEnding -eq 'zip' -or $UrlEnding -eq '7z'))
        Set-Variable -Option Constant DownloadedFile ([String](Start-Download $URL $FileName -Temp:($Execute -or $IsArchive) -NoBits:$NoBits))
    } catch {
        Out-Failure "Download failed: $_"
        Write-ActivityCompleted $False
        return
    }

    if ($DownloadedFile) {
        if ($IsArchive) {
            try {
                Set-Variable -Option Constant Executable ([String](Expand-Zip $DownloadedFile -Temp:$Execute))
            } catch {
                Out-Failure "Failed to extract '$DownloadedFile': $_"
                Write-ActivityCompleted $False
                return
            }
        } else {
            Set-Variable -Option Constant Executable ([String]$DownloadedFile)
        }

        if ($Configuration) {
            Set-Variable -Option Constant ParentPath ([String](Split-Path -Parent $Executable))
            Set-Content "$ParentPath\$ConfigFile" $Configuration -NoNewline
        }

        if ($Execute) {
            try {
                Start-Executable $Executable $Params -Silent:$Silent
            } catch {
                Out-Failure "Failed to run '$Executable': $_"
                Write-ActivityCompleted $False
                return
            }
        }
    }

    Write-ActivityCompleted
}
