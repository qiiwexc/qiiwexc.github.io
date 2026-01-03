function Start-OoShutUp10 {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory)]$Silent
    )

    Write-LogInfo 'Starting OOShutUp10++ utility...'

    Set-Variable -Option Constant NoConnection ([String](Test-NetworkConnection))
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    if ($Execute) {
        Set-Variable -Option Constant TargetPath ([String]$PATH_OOSHUTUP10)
    } else {
        Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
    }

    Set-Variable -Option Constant ConfigFile ([String]"$TargetPath\ooshutup10.cfg")

    New-Item -Force -ItemType Directory $TargetPath | Out-Null

    $CONFIG_OOSHUTUP10 | Set-Content $ConfigFile -NoNewline

    if ($Silent) {
        Start-DownloadUnzipAndRun '{URL_OOSHUTUP10}' -Execute:$Execute -Params $ConfigFile
    } else {
        Start-DownloadUnzipAndRun '{URL_OOSHUTUP10}' -Execute:$Execute
    }
}
