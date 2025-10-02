function Start-OoShutUp10 {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
    )

    Write-LogInfo 'Starting OOShutUp10++ utility...'

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_OOSHUTUP10 } else { $PATH_WORKING_DIR })
    Set-Variable -Option Constant ConfigFile "$TargetPath\OOShutUp10.cfg"

    New-Item -Force -ItemType Directory $TargetPath | Out-Null

    $CONFIG_SHUTUP10 | Out-File $ConfigFile -Encoding UTF8

    if ($Silent) {
        Start-DownloadUnzipAndRun -Execute:$Execute '{URL_OOSHUTUP10}' -Params $ConfigFile
    } else {
        Start-DownloadUnzipAndRun -Execute:$Execute '{URL_OOSHUTUP10}'
    }
}
