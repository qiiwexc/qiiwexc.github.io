function Start-SnappyDriverInstaller {
    param(
        [Switch]$Execute
    )

    Write-LogInfo 'Starting Snappy Driver Installer...'

    # SDI starts from a batch file, whose name no running process carries, so the check that
    # Start-Executable makes for an executable is made here, against the processes the batch file starts
    if ($Execute -and (Test-SdiIsRunning)) {
        Write-LogWarning 'Snappy Driver Installer is already running'
        return
    }

    Start-DownloadUnzipAndRun '{URL_SDI}' -Execute:$Execute -ConfigFile 'sdi.cfg' -Configuration $CONFIG_SDI
}
