function Set-InlineFiles {
    param(
        [String][Parameter(Position = 0, Mandatory)][ValidateSet('English', 'Russian')]$Locale,
        [String][Parameter(Position = 1, Mandatory)]$ConfigsPath,
        [Collections.Generic.List[String]][Parameter(Position = 2, Mandatory)]$TemplateContent
    )

    $KEY_FILE_MAP.GetEnumerator() | ForEach-Object {
        [String]$FileName = $_.Value.Replace('{LOCALE}', $Locale)

        [String]$FileContent = (Get-Content "$ConfigsPath\$FileName" -Raw -Encoding UTF8).Trim()

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

Set-Variable -Option Constant KEY_FILE_MAP (
    [Hashtable]@{
        'CONFIG_7ZIP'                                       = 'Apps\7zip.reg'
        'CONFIG_APP_ASSOCIATIONS'                           = 'Windows\App associations.xml'
        'CONFIG_ANYDESK'                                    = 'Apps\AnyDesk.conf'
        'CONFIG_MICROSOFT_OFFICE'                           = 'Apps\Microsoft Office.reg'
        'CONFIG_QBITTORRENT_LOCALIZED'                      = 'Apps\qBittorrent {LOCALE}.ini'
        'CONFIG_QBITTORRENT'                                = 'Apps\qBittorrent base.ini'
        'CONFIG_VLC'                                        = 'Apps\VLC.ini'
        'CONFIG_WINDOWS_HKEY_CURRENT_USER'                  = 'Windows\Base\Windows HKEY_CURRENT_USER.reg'
        'CONFIG_WINDOWS_HKEY_LOCAL_MACHINE'                 = 'Windows\Base\Windows HKEY_LOCAL_MACHINE.reg'
        'CONFIG_WINDOWS_HKEY_USERS'                         = 'Windows\Base\Windows HKEY_USERS.reg'
        'CONFIG_WINDOWS_LOCALISED'                          = 'Windows\Base\Windows {LOCALE}.reg'
        'CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER'  = 'Windows\Personalisation\Windows personalisation HKEY_CURRENT_USER.reg'
        'CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE' = 'Windows\Personalisation\Windows personalisation HKEY_LOCAL_MACHINE.reg'
    }
)
