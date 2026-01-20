function Set-InlineFiles {
    param(
        [String][Parameter(Position = 0, Mandatory)][ValidateSet('English', 'Russian')]$Locale,
        [String][Parameter(Position = 1, Mandatory)]$ConfigsPath,
        [String][Parameter(Position = 2, Mandatory)]$UnattendedPath,
        [Collections.Generic.List[String]][Parameter(Position = 3, Mandatory)]$TemplateContent
    )

    Set-Variable -Option Constant KEY_FILE_MAP (
        [Hashtable]@{
            'CONFIG_APP_ASSOCIATIONS'                           = "$UnattendedPath\App associations.xml"
            'CONFIG_7ZIP'                                       = "$ConfigsPath\Apps\7zip.reg"
            'CONFIG_ANYDESK'                                    = "$ConfigsPath\Apps\AnyDesk.conf"
            'CONFIG_MICROSOFT_OFFICE'                           = "$ConfigsPath\Apps\Microsoft Office.reg"
            'CONFIG_QBITTORRENT_LOCALIZED'                      = "$ConfigsPath\Apps\qBittorrent {LOCALE}.ini"
            'CONFIG_QBITTORRENT'                                = "$ConfigsPath\Apps\qBittorrent base.ini"
            'CONFIG_VLC'                                        = "$ConfigsPath\Apps\VLC.ini"
            'CONFIG_WINDOWS_HKEY_CURRENT_USER'                  = "$ConfigsPath\Windows\Base\Windows HKEY_CURRENT_USER.reg"
            'CONFIG_WINDOWS_HKEY_LOCAL_MACHINE'                 = "$ConfigsPath\Windows\Base\Windows HKEY_LOCAL_MACHINE.reg"
            'CONFIG_WINDOWS_HKEY_USERS'                         = "$ConfigsPath\Windows\Base\Windows HKEY_USERS.reg"
            'CONFIG_WINDOWS_LOCALISED'                          = "$ConfigsPath\Windows\Base\Windows {LOCALE}.reg"
            'CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER'  = "$ConfigsPath\Windows\Personalisation\Windows personalisation HKEY_CURRENT_USER.reg"
            'CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE' = "$ConfigsPath\Windows\Personalisation\Windows personalisation HKEY_LOCAL_MACHINE.reg"
        }
    )

    $KEY_FILE_MAP.GetEnumerator() | ForEach-Object {
        [String]$FileName = $_.Value.Replace('{LOCALE}', $Locale)

        [String]$FileContent = (Get-Content $FileName -Raw -Encoding UTF8).Trim()

        [Collections.Generic.List[String]]$FullContent = @()

        if ($FileName -match '.reg$') {
            $FullContent.Add("Windows Registry Editor Version 5.00`n")
            $FullContent.Add($FileContent.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\DefaultUser'))
        } else {
            $FullContent = $FileContent
        }

        [Collections.Generic.List[String]]$EscapedContent = @()
        foreach ($Line in $FullContent) {
            $EscapedContent.Add([Security.SecurityElement]::Escape($Line))
        }

        [String]$Placeholder = "{$($_.Key)}"
        $TemplateContent = $TemplateContent.Replace($Placeholder, ($EscapedContent -join "`n"))
    }

    return $TemplateContent
}
