function Set-RegistryConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('English', 'Russian')]$Locale,
        [String][Parameter(Position = 1, Mandatory = $True)]$ConfigsPath,
        [Parameter(Position = 2, Mandatory = $True)]$TemplateContent
    )

    $KEY_FILE_MAP | ForEach-Object {
        [String]$FileName = $_.File.Replace('{LOCALE}', $Locale)

        [Collections.Generic.List[String]]$FileContent = Get-Content "$ConfigsPath\$FileName"

        [Collections.Generic.List[String]]$FullContent = "Windows Registry Editor Version 5.00`n"

        $FullContent += $FileContent.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\DefaultUser')

        $TemplateContent = $TemplateContent.Replace("{$($_.Key)}", ($FullContent -join "`n"))
    }

    return $TemplateContent
}

Set-Variable -Option Constant KEY_FILE_MAP @(
    @{Key = 'REGISTRY_7ZIP'; File = 'Apps\7zip.reg' },
    @{Key = 'REGISTRY_MICROSOFT_OFFICE'; File = 'Apps\Microsoft Office.reg' },
    @{Key = 'REGISTRY_TEAMVIEWER'; File = 'Apps\TeamViewer.reg' },
    @{Key = 'REGISTRY_WINDOWS_HKEY_CLASSES_ROOT'; File = 'Windows\Base\Windows HKEY_CLASSES_ROOT.reg' },
    @{Key = 'REGISTRY_WINDOWS_HKEY_CURRENT_USER'; File = 'Windows\Base\Windows HKEY_CURRENT_USER.reg' },
    @{Key = 'REGISTRY_WINDOWS_HKEY_LOCAL_MACHINE'; File = 'Windows\Base\Windows HKEY_LOCAL_MACHINE.reg' },
    @{Key = 'REGISTRY_WINDOWS_HKEY_USERS'; File = 'Windows\Base\Windows HKEY_USERS.reg' },
    @{Key = 'REGISTRY_WINDOWS_LOCALISED'; File = 'Windows\Base\Windows {LOCALE}.reg' },
    @{Key = 'REGISTRY_WINDOWS_PERSONALISATION_HKEY_CLASSES_ROOT'; File = 'Windows\Personalisation\Windows personalisation HKEY_CLASSES_ROOT.reg' },
    @{Key = 'REGISTRY_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER'; File = 'Windows\Personalisation\Windows personalisation HKEY_CURRENT_USER.reg' },
    @{Key = 'REGISTRY_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE'; File = 'Windows\Personalisation\Windows personalisation HKEY_LOCAL_MACHINE.reg' }
)
