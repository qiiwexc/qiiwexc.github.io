function Set-InlineFiles {
    param(
        [String][Parameter(Position = 0, Mandatory)][ValidateSet('English', 'Russian')]$Locale,
        [String][Parameter(Position = 1, Mandatory)]$ConfigsPath,
        [String][Parameter(Position = 2, Mandatory)]$ResourcesPath,
        [Collections.Generic.List[String]][Parameter(Position = 3, Mandatory)]$TemplateContent
    )

    Set-Variable -Option Constant KEY_FILE_MAP (
        [Hashtable]@{
            'CONFIG_APP_ASSOCIATIONS'       = "$ResourcesPath\App associations.xml"
            'CONFIG_7ZIP'                   = "$ConfigsPath\Apps\7zip.reg"
            'CONFIG_ANYDESK'                = "$ConfigsPath\Apps\AnyDesk.conf"
            'CONFIG_MICROSOFT_OFFICE'       = "$ConfigsPath\Apps\Microsoft Office.reg"
            'CONFIG_QBITTORRENT_LOCALIZED'  = "$ConfigsPath\Apps\qBittorrent {LOCALE}.ini"
            'CONFIG_QBITTORRENT'            = "$ConfigsPath\Apps\qBittorrent base.ini"
            'CONFIG_VLC'                    = "$ConfigsPath\Apps\VLC.ini"
            'CONFIG_SECURITY'               = "$ConfigsPath\Windows\Security.reg"
            'CONFIG_PERFORMANCE'            = "$ConfigsPath\Windows\Performance.reg"
            'CONFIG_BASELINE'               = "$ConfigsPath\Windows\Baseline.reg"
            'CONFIG_TASK_MANAGER_LOCALISED' = "$ConfigsPath\Windows\Task Manager {LOCALE}.json"
            'CONFIG_WINDOWS_LOCALISED'      = "$ConfigsPath\Windows\Baseline {LOCALE}.reg"
            'CONFIG_ANNOYANCES'             = "$ConfigsPath\Windows\Annoyances.reg"
            'CONFIG_PRIVACY'                = "$ConfigsPath\Windows\Privacy.reg"
            'CONFIG_PERSONALISATION'        = "$ConfigsPath\Windows\Personalisation.reg"
        }
    )

    $KEY_FILE_MAP.GetEnumerator() | ForEach-Object {
        [String]$FileName = $_.Value.Replace('{LOCALE}', $Locale)
        [String]$FileContent = (Read-TextFile $FileName).Trim()

        if ($FileName -match '.reg$') {
            [String]$FullContent = $FileContent.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\DefaultUser')
        } else {
            [String]$FullContent = $FileContent
        }

        [String]$Placeholder = "{$($_.Key)}"
        [String]$EscapedContent = [Security.SecurityElement]::Escape($FullContent)

        $TemplateContent = $TemplateContent.Replace($Placeholder, $EscapedContent)
    }

    return $TemplateContent
}
