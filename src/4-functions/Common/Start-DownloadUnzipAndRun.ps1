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

    Set-Variable -Option Constant UrlEnding ([String]$URL.Split('.')[-1].ToLower())
    Set-Variable -Option Constant IsZip ([Bool]($UrlEnding -eq 'zip' -or $UrlEnding -eq '7z'))
    Set-Variable -Option Constant DownloadedFile ([String](Start-Download $URL $FileName -Temp:($Execute -or $IsZip)))

    if ($DownloadedFile) {
        if ($IsZip) {
            Set-Variable -Option Constant Executable ([String](Expand-Zip $DownloadedFile -Temp:$Execute))
        } else {
            Set-Variable -Option Constant Executable ([String]$DownloadedFile)
        }

        if ($Configuration) {
            Set-Variable -Option Constant ParentPath ([String](Split-Path -Parent $Executable -ErrorAction Stop))
            $Configuration | Set-Content "$ParentPath\$ConfigFile" -NoNewline -ErrorAction Stop
        }

        if ($Execute) {
            Start-Executable $Executable $Params -Silent:$Silent
        }
    }

    Write-ActivityCompleted
}
