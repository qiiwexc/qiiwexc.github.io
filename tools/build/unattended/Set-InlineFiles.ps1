function Set-InlineFiles {
    param(
        [Parameter(Position = 0, Mandatory)][String][ValidateSet('English', 'Russian')]$Locale,
        [Parameter(Position = 1, Mandatory)][String]$ConfigsPath,
        [Parameter(Position = 2, Mandatory)][String]$ResourcesPath,
        [Parameter(Position = 3, Mandatory)][String]$TemplateContent
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
            'CONFIG_TASK_MANAGER_LOCALIZED' = "$ConfigsPath\Windows\Task Manager {LOCALE}.json"
            'CONFIG_WINDOWS_LOCALIZED'      = "$ConfigsPath\Windows\Baseline {LOCALE}.reg"
            'CONFIG_ANNOYANCES'             = "$ConfigsPath\Windows\Annoyances.reg"
            'CONFIG_PRIVACY'                = "$ConfigsPath\Windows\Privacy.reg"
            'CONFIG_PERSONALIZATION'        = "$ConfigsPath\Windows\Personalization.reg"
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
