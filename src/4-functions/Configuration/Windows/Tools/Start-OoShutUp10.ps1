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

        # O&O ShutUp10++ parses only CRLF line endings, while the embedded copy has whichever git checked
        # the file out with. Written the way the tool exports it: CRLF, UTF-8 without a byte order mark
        Set-Variable -Option Constant ConfigBytes ([Byte[]][Text.UTF8Encoding]::new($False).GetBytes(($CONFIG_OOSHUTUP10 -replace '\r?\n', "`r`n")))
        Set-Content $ConfigFile $ConfigBytes -Encoding Byte -ErrorAction Stop

        if ($Execute -and $Silent) {
            $Params = $ConfigFile
        }
    } catch {
        Write-LogWarning "Failed to initialize OOShutUp10++ configuration: $_"
    }

    Start-DownloadUnzipAndRun '{URL_OOSHUTUP10}' -Execute:$Execute -Params $Params
}
