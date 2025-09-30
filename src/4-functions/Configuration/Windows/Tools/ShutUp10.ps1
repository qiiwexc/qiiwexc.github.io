function Start-ShutUp10 {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
    )

    Write-LogInfo 'Starting ShutUp10++ utility...'

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if ($NoConnection) {
        Write-LogError "Failed to start: $NoConnection"
        return
    }

    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_APP_DIR } else { $PATH_WORKING_DIR })
    Set-Variable -Option Constant ConfigFile "$TargetPath\ooshutup10.cfg"

    Initialize-AppDirectory

    $CONFIG_SHUTUP10 | Out-File $ConfigFile

    if ($Silent) {
        Start-DownloadUnzipAndRun -Execute:$Execute '{URL_SHUTUP10}' -Params $ConfigFile
    } else {
        Start-DownloadUnzipAndRun -Execute:$Execute '{URL_SHUTUP10}'
    }
}
