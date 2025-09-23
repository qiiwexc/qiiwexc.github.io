Function Start-OfficeInstaller {
    Param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute
    )

    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
    Set-Variable -Option Constant Config $(if ($SYSTEM_LANGUAGE -Match 'ru') { $CONFIG_OFFICE_INSTALLER -Replace 'en-GB', 'ru-RU' } else { $CONFIG_OFFICE_INSTALLER })

    $Config | Out-File "$TargetPath\Office Installer+.ini" -Encoding UTF8

    Start-DownloadExtractExecute -AVWarning -Execute:$Execute '{URL_OFFICE_INSTALLER}'
}
