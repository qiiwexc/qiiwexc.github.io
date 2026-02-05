function Install-MicrosoftOffice {
    param(
        [Switch]$Execute
    )

    Write-LogInfo 'Starting Microsoft Office installation...'

    try {
        if ($Execute) {
            Set-Variable -Option Constant TargetPath ([String]$PATH_APP_DIR)
        } else {
            Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
        }

        if ($SYSTEM_LANGUAGE -match 'ru') {
            Set-Variable -Option Constant Config ([String]$CONFIG_OFFICE_INSTALLER.Replace('en-GB', 'ru-RU'))
        } else {
            Set-Variable -Option Constant Config ([String]$CONFIG_OFFICE_INSTALLER)
        }

        Initialize-AppDirectory

        Set-Content "$TargetPath\Office Installer.ini" $Config -NoNewline -ErrorAction Stop
    } catch {
        Write-LogWarning "Failed to initialize Microsoft Office installer configuration: $_"
    }

    if ($Execute) {
        try {
            Import-RegistryConfiguration 'Microsoft Office' $CONFIG_MICROSOFT_OFFICE
        } catch {
            Write-LogWarning "Failed to import Microsoft Office registry configuration: $_"
        }
    }

    Start-DownloadUnzipAndRun '{URL_OFFICE_INSTALLER}' -Execute:$Execute
}
