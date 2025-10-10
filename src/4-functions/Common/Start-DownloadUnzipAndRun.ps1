function Start-DownloadUnzipAndRun {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$FileName,
        [String][Parameter(Position = 2)]$Params,
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
        Set-Variable -Option Constant -Scope Script AV_WARNING_SHOWN $True
        return
    }

    New-Activity 'Download and run'

    Set-Variable -Option Constant UrlEnding $URL.Substring($URL.Length - 4)
    Set-Variable -Option Constant IsZip ($UrlEnding -eq '.zip')
    Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp $($Execute -or $IsZip))

    if ($DownloadedFile) {
        Set-Variable -Option Constant Executable $(if ($IsZip) { Expand-Zip $DownloadedFile -Temp $Execute } else { $DownloadedFile })

        if ($Execute) {
            Start-Executable $Executable $Params -Silent $Silent
        }
    }

    Write-ActivityCompleted
}
