function New-UnattendedTemplate {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigPath,
        [String][Parameter(Position = 1, Mandatory)]$TemplateFile,
        [Switch][Parameter(Position = 2, Mandatory)]$FullBuild
    )

    Set-Variable -Option Constant BaseFile ([String]"$ConfigPath\autounattend.xml")

    Set-Variable -Option Constant ConfigFiles ([String]'</ExtractScript>
    <File path="C:\Windows\Setup\Scripts\AppAssociations.xml">
{CONFIG_APP_ASSOCIATIONS}
    </File>
    <File path="C:\Users\Default\AppData\Roaming\AnyDesk\user.conf">
{CONFIG_ANYDESK}
    </File>
    <File path="C:\Users\Default\AppData\Roaming\vlc\vlcrc">
{CONFIG_VLC}
    </File>
    <File path="C:\Users\Default\AppData\Roaming\qBittorrent\qBittorrent.ini">
{CONFIG_QBITTORRENT}
{CONFIG_QBITTORRENT_LOCALIZED}
    </File>'
    )

    Set-Variable -Option Constant StringReplacementMap ([Collections.Generic.List[Hashtable]]@(
            @{OldValue = "`t"; NewValue = '  ' },
            @{OldValue = "Windows Registry Editor Version 5.00`r`n`r`n"; NewValue = '' },
            @{OldValue = '</ExtractScript>'; NewValue = $ConfigFiles },
            @{OldValue = 'C:\Windows\Setup\Scripts\'; NewValue = 'C:\Windows\Setup\' }
        )
    )

    Set-Variable -Option Constant RegexReplacementMap ([Collections.Generic.List[Hashtable]]@(
            @{Regex = 'RemoveFeatures\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemoveFeatures.ps1`">`n`$selectors = @({FEATURE_REMOVAL_LIST});" },
            @{Regex = 'RemoveCapabilities\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemoveCapabilities.ps1`">`n`$selectors = @({CAPABILITY_REMOVAL_LIST});" },
            @{Regex = 'RemovePackages\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemovePackages.ps1`">`n`$selectors = @({APP_REMOVAL_LIST});" }
        )
    )

    if ($FullBuild) {
        $RegexReplacementMap.Add(@{Regex = '\s*<File path="C:\\Windows\\Setup\\VBoxGuestAdditions\.ps1">([\s\S]*?)<\/File>'; NewValue = '' })
        $RegexReplacementMap.Add(@{Regex = "\s*{\s*&amp; 'C:\\Windows\\Setup\\VBoxGuestAdditions\.ps1';\s*}"; NewValue = '' })
    }

    [String]$Content = Get-Content -Raw -Path $BaseFile -Encoding UTF8

    foreach ($Item in $StringReplacementMap) {
        $Content = $Content.Replace($Item.OldValue, $Item.NewValue)
    }

    foreach ($Item in $RegexReplacementMap) {
        $Content = $Content -replace $Item.Regex, $Item.NewValue
    }

    $Content = "<!-- Version: {VERSION} -->`n" + $Content

    Set-Content -Path $TemplateFile -Value $Content -Encoding UTF8
}
