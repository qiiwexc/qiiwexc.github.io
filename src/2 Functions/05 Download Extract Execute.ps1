Function Start-DownloadExtractExecute {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"),
        [String][Parameter(Position = 1)]$FileName,
        [Switch]$AVWarning, [Switch]$MultiFile, [Switch]$Execute
    )
    if (-not $URL) { Return }

    if ($AVWarning) { Add-Log $WRN $TXT_AV_WARNING }

    if ($PS_VERSION -le 2 -and ($URL -Match 'github.com/*' -or $URL -Match 'github.io/*')) { Open-InBrowser $URL }
    else {
        Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp:$Execute)

        if ($DownloadedFile) {
            Set-Variable -Option Constant IsZip ($DownloadedFile.Substring($DownloadedFile.Length - 4) -eq '.zip')
            Set-Variable -Option Constant Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -MF:$MultiFile } else { $DownloadedFile })
            if ($Execute) { Start-File $Executable }
        }
    }
}
