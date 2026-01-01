function Start-DownloadUnzipAndRun {
    param(
        [String][Parameter(Position = 0, Mandatory)]$URL,
        [String][Parameter(Position = 1)]$FileName,
        [String][Parameter(Position = 2)]$Params,
        [String]$ConfigFile,
        [String]$Configuration,
        [Switch]$AVWarning,
        [Switch]$Execute,
        [Switch]$Silent
    )

    if ($AVWarning -and (Get-MicrosoftSecurityStatus)) {
        Write-LogWarning 'Microsoft Security is enabled'
    }

    if ($AVWarning -and -not $AV_WARNING_SHOWN) {
        Write-LogWarning 'This file may trigger anti-virus false positive!'
        Write-LogWarning 'It is recommended to disable anti-virus software for download and subsequent use of this file!'
        Write-LogWarning 'Click the button again to continue'
        Set-Variable -Option Constant -Scope Script AV_WARNING_SHOWN ([Bool]$True)
        return
    }

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
            Set-Variable -Option Constant ParentPath ([String](Split-Path -Parent $Executable))
            $Configuration | Out-File "$ParentPath\$ConfigFile" -Encoding UTF8
        }

        if ($Execute) {
            Start-Executable $Executable $Params -Silent:$Silent
        }
    }

    Write-ActivityCompleted
}
