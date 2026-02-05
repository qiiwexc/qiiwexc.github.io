function Start-SnappyDriverInstaller {
    param(
        [Switch]$Execute
    )

    Write-LogInfo 'Starting Snappy Driver Installer...'

    Start-DownloadUnzipAndRun '{URL_SDI}' -Execute:$Execute -ConfigFile 'sdi.cfg' -Configuration $CONFIG_SDI
}
