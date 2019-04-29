function Open-InBrowser {
    Param([String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"))
    if (-not $URL) { Return }

    Set-Variable UrlToOpen $(if ($URL -like 'http*') { $URL } else { 'https://' + $URL }) -Option Constant
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
        Set-Variable DownloadedFile (Start-Download $URL $FileName) -Option Constant

        if ($DownloadedFile) {
            Set-Variable IsZip ($DownloadedFile.Substring($DownloadedFile.Length - 4) -eq '.zip') -Option Constant
            Set-Variable Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -MF:$MultiFile } else { $DownloadedFile }) -Option Constant
            if ($Execute) { Start-File $Executable }
        }
    }
}


function Get-FreeDiskSpace { Return ($SystemPartition.FreeSpace / $SystemPartition.Size) }

function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }

function Get-ConnectionStatus { if (-not (Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

function Reset-CmdWindow { $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

function Exit-Script { Reset-CmdWindow; $FORM.Close() }
