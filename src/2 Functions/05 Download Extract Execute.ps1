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
        Set-Variable DownloadedFile (Start-Download $URL $FileName -Temp:$Execute) -Option Constant

        if ($DownloadedFile) {
            Set-Variable IsZip ($DownloadedFile.Substring($DownloadedFile.Length - 4) -eq '.zip') -Option Constant
            Set-Variable Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -MF:$MultiFile } else { $DownloadedFile }) -Option Constant
            if ($Execute) { Start-File $Executable }
        }
    }
}
