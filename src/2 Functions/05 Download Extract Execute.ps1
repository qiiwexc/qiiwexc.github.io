Function Start-DownloadExtractExecute {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$FileName,
        [String][Parameter(Position = 2)]$Params,
        [Switch]$AVWarning,
        [Switch]$Execute,
        [Switch]$SilentInstall
    )

    if ($AVWarning -and -not $AVWarningShown) {
        Add-Log $WRN $TXT_AV_WARNING
        Add-Log $WRN 'Click the button again to continue'
        Set-Variable -Option Constant -Scope Script AVWarningShown $True
        Return
    }

    if ($PS_VERSION -le 2 -and ($URL -Match '*github.com/*' -or $URL -Match '*github.io/*')) { Open-InBrowser $URL }
    else {
        Set-Variable -Option Constant UrlEnding $URL.Substring($URL.Length - 4)
        Set-Variable -Option Constant IsZip ($UrlEnding -eq '.zip')
        Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp:$($Execute -or $IsZip))

        if ($DownloadedFile) {
            Set-Variable -Option Constant Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -Execute:$Execute } else { $DownloadedFile })
            if ($Execute) { Start-File $Executable $Params -SilentInstall:$SilentInstall }
        }
    }
}
