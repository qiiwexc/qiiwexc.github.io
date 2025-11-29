function New-UnattendedTemplate {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigPath,
        [String][Parameter(Position = 1, Mandatory)]$TemplateFile
    )

    Set-Variable -Option Constant BaseFile ([String]"$ConfigPath\autounattend.xml")

    Set-Variable -Option Constant InternationalWinPe ([String]'<component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <InputLocale>{KEYBOARD1}:0000{KEYBOARD1};{KEYBOARD2}:0000{KEYBOARD2};{KEYBOARD3}:0000{KEYBOARD3}</InputLocale>
      <SetupUILanguage>
        <UILanguage>{UI_LANGUAGE}</UILanguage>
      </SetupUILanguage>
      <SystemLocale>{LOCALE1}</SystemLocale>
      <UILanguage>{UI_LANGUAGE}</UILanguage>
      <UserLocale>{LOCALE1}</UserLocale>
    </component>'
    )

    Set-Variable -Option Constant InternationalCore ([String]'<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <InputLocale>{KEYBOARD1}:0000{KEYBOARD1};{KEYBOARD2}:0000{KEYBOARD2};{KEYBOARD3}:0000{KEYBOARD3}</InputLocale>
      <SystemLocale>{LOCALE1}</SystemLocale>
      <UILanguage>{UI_LANGUAGE}</UILanguage>
      <UILanguageFallback>{UI_LANGUAGE_FALLBACK}</UILanguageFallback>
      <UserLocale>{LOCALE1}</UserLocale>
    </component>'
    )

    Set-Variable -Option Constant ConfigFiles ([String]'</ExtractScript>
    <File path="C:\Windows\Setup\Scripts\AppAssociations.xml">
{CONFIG_APP_ASSOCIATIONS}
    </File>
    <File path="C:\Users\Default\AppData\Roaming\vlc\vlcrc">
{CONFIG_VLC}
    </File>
    <File path="C:\Users\Default\AppData\Roaming\qBittorrent\qBittorrent.ini">
{CONFIG_QBITTORRENT}
{CONFIG_QBITTORRENT_LOCALIZED}
    </File>'
    )

    Set-Variable -Option Constant StringReplacementMap ([Collections.Generic.List[hashtable]]@(
            @{OldValue = "`t"; NewValue = '  ' },
            @{OldValue = "Windows Registry Editor Version 5.00`r`n`r`n"; NewValue = '' },
            @{OldValue = '</ExtractScript>'; NewValue = $ConfigFiles }
        )
    )

    Set-Variable -Option Constant RegexReplacementMap ([Collections.Generic.List[hashtable]]@(
            @{Regex = 'RemoveFeatures\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemoveFeatures.ps1`">`n`$selectors = @({FEATURE_REMOVAL_LIST});" },
            @{Regex = 'RemoveCapabilities\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemoveCapabilities.ps1`">`n`$selectors = @({CAPABILITY_REMOVAL_LIST});" },
            @{Regex = 'RemovePackages\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemovePackages.ps1`">`n`$selectors = @({APP_REMOVAL_LIST});" }
            @{Regex = '<component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">\s*([\s\s*\S]*?)\s*</component>'; NewValue = $InternationalWinPe }
            @{Regex = '<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">\s*([\s\s*\S]*?)\s*</component>'; NewValue = $InternationalCore }
        )
    )

    [String]$Content = Get-Content -Raw -Path $BaseFile -Encoding UTF8

    foreach ($Item in $StringReplacementMap) {
        $Content = $Content.Replace($Item.OldValue, $Item.NewValue)
    }

    foreach ($Item in $RegexReplacementMap) {
        $Content = $Content -replace $Item.Regex, $Item.NewValue
    }

    Set-Content -Path $TemplateFile -Value $Content -Encoding UTF8
}
