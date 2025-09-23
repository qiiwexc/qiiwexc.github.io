Function Start-WindowsDebloat {
    Write-Log $INF "Starting Windows 10/11 debloat utility..."

    Start-Script -Elevated -HideWindow "irm https://debloat.raphi.re/ | iex"

    Out-Success
}


Function Start-ShutUp10 {
    Param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
    )

    Write-Log $INF "Starting ShutUp10++ utility..."

    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
    Set-Variable -Option Constant ConfigFile "$TargetPath\ooshutup10.cfg"

    $CONFIG_SHUTUP10 | Out-File $ConfigFile

    if ($Silent) {
        Start-DownloadExtractExecute -Execute:$Execute '{URL_SHUTUP10}' -Params $ConfigFile
    } else {
        Start-DownloadExtractExecute -Execute:$Execute '{URL_SHUTUP10}'
    }
}
