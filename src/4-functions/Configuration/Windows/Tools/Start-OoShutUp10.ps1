function Start-OoShutUp10 {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory)]$Silent
    )

    Write-LogInfo 'Starting OOShutUp10++ utility...'

    try {
        if ($Execute) {
            Set-Variable -Option Constant TargetPath ([String]$PATH_OOSHUTUP10)
        } else {
            Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
        }

        Set-Variable -Option Constant ConfigFile ([String]"$TargetPath\ooshutup10.cfg")

        New-Directory $TargetPath

        Set-Content $ConfigFile $CONFIG_OOSHUTUP10 -NoNewline -ErrorAction Stop
    } catch {
        Write-LogWarning "Failed to initialize OOShutUp10++ configuration: $_"
    }

    if ($Execute -and $Silent) {
        Start-DownloadUnzipAndRun '{URL_OOSHUTUP10}' -Execute:$Execute -Params $ConfigFile
        Out-Success
    } else {
        Start-DownloadUnzipAndRun '{URL_OOSHUTUP10}' -Execute:$Execute
        Out-Success
    }
}
