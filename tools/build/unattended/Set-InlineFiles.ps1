function Set-InlineFiles {
    param(
        [String][Parameter(Position = 0, Mandatory)][ValidateSet('English', 'Russian')]$Locale,
        [String][Parameter(Position = 1, Mandatory)]$ConfigsPath,
        [Collections.Generic.List[String]][Parameter(Position = 2, Mandatory)][AllowEmptyString()]$TemplateContent
    )

    $KEY_FILE_MAP | ForEach-Object {
        [String]$FileName = $_.File.Replace('{LOCALE}', $Locale)

        [String]$FileContent = (Get-Content "$ConfigsPath\$FileName" -Raw -Encoding UTF8).Trim()

        [Collections.Generic.List[String]]$FullContent = @()

        if ($FileName -match '.reg$') {
            $FullContent = "Windows Registry Editor Version 5.00`n"
            $FullContent += $FileContent.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\DefaultUser')
        } elseif ($FileName -match '.xml$') {
            $FullContent += $FileContent.Replace(' _resistant="true"', '')
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
    [Collections.Generic.List[Hashtable]]@(
        @{Key = 'CONFIG_7ZIP'; File = 'Apps\7zip.reg' },
        @{Key = 'CONFIG_APP_ASSOCIATIONS'; File = 'Windows\App associations.xml' },
        @{Key = 'CONFIG_ANYDESK'; File = 'Apps\AnyDesk.conf' },
        @{Key = 'CONFIG_MICROSOFT_OFFICE'; File = 'Apps\Microsoft Office.reg' },
        @{Key = 'CONFIG_QBITTORRENT_LOCALIZED'; File = 'Apps\qBittorrent {LOCALE}.ini' },
        @{Key = 'CONFIG_QBITTORRENT'; File = 'Apps\qBittorrent base.ini' },
        @{Key = 'CONFIG_VLC'; File = 'Apps\VLC.ini' },
        @{Key = 'CONFIG_WINDOWS_HKEY_CLASSES_ROOT'; File = 'Windows\Base\Windows HKEY_CLASSES_ROOT.reg' },
        @{Key = 'CONFIG_WINDOWS_HKEY_CURRENT_USER'; File = 'Windows\Base\Windows HKEY_CURRENT_USER.reg' },
        @{Key = 'CONFIG_WINDOWS_HKEY_LOCAL_MACHINE'; File = 'Windows\Base\Windows HKEY_LOCAL_MACHINE.reg' },
        @{Key = 'CONFIG_WINDOWS_HKEY_USERS'; File = 'Windows\Base\Windows HKEY_USERS.reg' },
        @{Key = 'CONFIG_WINDOWS_LOCALISED'; File = 'Windows\Base\Windows {LOCALE}.reg' },
        @{Key = 'CONFIG_WINDOWS_PERSONALISATION_HKEY_CLASSES_ROOT'; File = 'Windows\Personalisation\Windows personalisation HKEY_CLASSES_ROOT.reg' },
        @{Key = 'CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER'; File = 'Windows\Personalisation\Windows personalisation HKEY_CURRENT_USER.reg' },
        @{Key = 'CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE'; File = 'Windows\Personalisation\Windows personalisation HKEY_LOCAL_MACHINE.reg' }
    )
)
