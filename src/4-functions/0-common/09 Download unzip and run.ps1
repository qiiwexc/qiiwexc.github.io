function Start-DownloadUnzipAndRun {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$FileName,
        [String][Parameter(Position = 2)]$Params,
        [Switch]$AVWarning,
        [Switch]$Execute,
        [Switch]$Silent
    )

    if ($AVWarning -and -not $AV_WARNING_SHOWN) {
        Write-Log $WRN 'This file may trigger anti-virus false positive!'
        Write-Log $WRN 'It is recommended to disable anti-virus software for download and subsequent use of this file!'
        Write-Log $WRN 'Click the button again to continue'
        Set-Variable -Option Constant -Scope Script AV_WARNING_SHOWN $True
        return
    }

    Set-Variable -Option Constant UrlEnding $URL.Substring($URL.Length - 4)
    Set-Variable -Option Constant IsZip ($UrlEnding -eq '.zip')
    Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp:$($Execute -or $IsZip))

    if ($DownloadedFile) {
        Set-Variable -Option Constant Executable $(if ($IsZip) { Expand-Zip $DownloadedFile -Execute:$Execute } else { $DownloadedFile })

        if ($Execute) {
            Start-Executable $Executable $Params -Silent:$Silent
        }
    }
}
