function Open-InBrowser {
    Param([String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"))
    if (-not $URL) { Return }

    $UrlToOpen = if ($URL -like 'http*') { $URL } else { 'https://' + $URL }
    Add-Log $INF "Opening URL in the default browser: $UrlToOpen"

    try { [System.Diagnostics.Process]::Start($UrlToOpen) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


function Start-DownloadExtractExecute {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"),
        [String][Parameter(Position = 1)]$FileName,
        [Switch]$AVWarning, [Switch]$MultiFile, [Switch]$Execute
    )
    if (-not $URL) { Return }

    if ($AVWarning) { Add-Log $WRN $TXT_AV_WARNING }

    if ($PS_VERSION -le 2 -and ($URL -Match 'github.com/*' -or $URL -Match 'github.io/*')) { Open-InBrowser $URL }
    else {
        $DownloadedFile = Start-Download $URL $FileName

        if ($DownloadedFile) {
            $Executable = if ($DownloadedFile.Substring($DownloadedFile.Length - 4) -eq '.zip') { Start-Extraction $DownloadedFile -MF:$MultiFile } else { $DownloadedFile }
            if ($Execute) { Start-File $Executable }
        }
    }
}


function Get-FreeDiskSpace { Return ($SystemPartition.FreeSpaceGB / $SystemPartition.SizeGB) }

function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }


function Get-ConnectionStatus { if (-not (Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }


function Exit-Script { $FORM.Close() }
