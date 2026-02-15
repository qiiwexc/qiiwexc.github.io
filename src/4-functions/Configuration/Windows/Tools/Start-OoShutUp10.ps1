function Start-OoShutUp10 {
    param(
        [Switch]$Execute,
        [Switch]$Silent
    )

    Write-LogInfo 'Starting OOShutUp10++ utility...'

    if (Test-WindowsDebloatIsRunning) {
        Write-LogWarning 'Windows debloat utility is running, which may interfere with the OOShutUp10++ utility'
        Write-LogWarning 'Repeat the attempt after Windows debloat utility has finished running'
        return
    }

    [String]$Params = ''

    try {
        if ($Execute) {
            Set-Variable -Option Constant TargetPath ([String]$PATH_OOSHUTUP10)
        } else {
            Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
        }

        Set-Variable -Option Constant ConfigFile ([String]"$TargetPath\ooshutup10.cfg")

        New-Directory $TargetPath

        Set-Content $ConfigFile $CONFIG_OOSHUTUP10 -NoNewline -ErrorAction Stop

        if ($Execute -and $Silent) {
            $Params = $ConfigFile
        }
    } catch {
        Write-LogWarning "Failed to initialize OOShutUp10++ configuration: $_"
    }

    Start-DownloadUnzipAndRun '{URL_OOSHUTUP10}' -Execute:$Execute -Params $Params
}
