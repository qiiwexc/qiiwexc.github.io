function Install-MicrosoftOffice {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$Execute
    )

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

    $Config | Set-Content "$TargetPath\Office Installer+.ini" -NoNewline

    if ($Execute -and $AV_WARNING_SHOWN) {
        Import-RegistryConfiguration 'Microsoft Office' $CONFIG_MICROSOFT_OFFICE
    }

    Start-DownloadUnzipAndRun '{URL_OFFICE_INSTALLER}' -AVWarning -Execute:$Execute
}
