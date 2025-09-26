function Install-MicrosoftOffice {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute
    )

    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_APP_DIR } else { $PATH_CURRENT_DIR })
    Set-Variable -Option Constant Config $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_OFFICE_INSTALLER -replace 'en-GB', 'ru-RU' } else { $CONFIG_OFFICE_INSTALLER })

    $Config | Out-File "$TargetPath\Office Installer+.ini" -Encoding UTF8

    Start-DownloadUnzipAndRun -AVWarning -Execute:$Execute '{URL_OFFICE_INSTALLER}'
}
