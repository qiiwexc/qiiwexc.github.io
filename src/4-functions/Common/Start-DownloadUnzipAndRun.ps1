function Start-DownloadUnzipAndRun {
    param(
        [String][Parameter(Position = 0, Mandatory)]$URL,
        [String][Parameter(Position = 1)]$FileName,
        [String][Parameter(Position = 2)]$Params,
        [String]$ConfigFile,
        [String]$Configuration,
        [Switch]$Execute,
        [Switch]$Silent
    )

    New-Activity 'Download and run'

    try {
        Set-Variable -Option Constant UrlEnding ([String]$URL.Split('.')[-1].ToLower())
        Set-Variable -Option Constant IsArchive ([Bool]($UrlEnding -eq 'zip' -or $UrlEnding -eq '7z'))
        Set-Variable -Option Constant DownloadedFile ([String](Start-Download $URL $FileName -Temp:($Execute -or $IsArchive)))
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
