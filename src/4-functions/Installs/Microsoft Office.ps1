function Install-MicrosoftOffice {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute
    )

    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_APP_DIR } else { $PATH_WORKING_DIR })
    Set-Variable -Option Constant Config $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_OFFICE_INSTALLER.Replace('en-GB', 'ru-RU') } else { $CONFIG_OFFICE_INSTALLER })

    Initialize-AppDirectory

    $Config | Out-File "$TargetPath\Office Installer+.ini" -Encoding UTF8

    if ($Execute -and $AV_WARNING_SHOWN) {
        Import-RegistryConfiguration 'Microsoft Office' $CONFIG_MICROSOFT_OFFICE
    }

    Start-DownloadUnzipAndRun -AVWarning -Execute:$Execute '{URL_OFFICE_INSTALLER}'
}
