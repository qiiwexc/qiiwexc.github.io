function New-UnattendedBase {
    param(
        [String][Parameter(Position = 0, Mandatory)]$TemplatesPath,
        [String][Parameter(Position = 1, Mandatory)]$BaseFile,
        [Switch][Parameter(Position = 2, Mandatory)]$FullBuild
    )

    Set-Variable -Option Constant TemplateFile ([String]"$TemplatesPath\autounattend.xml")

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
            @{OldValue = 'C:\Windows\Setup\Scripts\'; NewValue = 'C:\Windows\Setup\' },
            @{OldValue = 'HideOnlineAccountScreens>false</HideOnlineAccountScreens'; NewValue = 'HideOnlineAccountScreens>true</HideOnlineAccountScreens' }
        )
    )

    Set-Variable -Option Constant RegexReplacementMap ([Collections.Generic.List[Hashtable]]@(
            @{Regex = 'RemoveFeatures\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemoveFeatures.ps1`">`n`$selectors = @({FEATURE_REMOVAL_LIST});" },
            @{Regex = 'RemoveCapabilities\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemoveCapabilities.ps1`">`n`$selectors = @({CAPABILITY_REMOVAL_LIST});" },
            @{Regex = 'RemovePackages\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'; NewValue = "RemovePackages.ps1`">`n`$selectors = @({APP_REMOVAL_LIST});" }
        )
    )

    Set-Variable -Option Constant DevRegexReplacementMap ([Collections.Generic.List[Hashtable]]@(
            @{Regex = '\s*<File path="C:\\Windows\\Setup\\VBoxGuestAdditions\.ps1">([\s\S]*?)<\/File>'; NewValue = '' },
            @{Regex = "\s*{\s*&amp; 'C:\\Windows\\Setup\\VBoxGuestAdditions\.ps1';\s*};"; NewValue = '' },
            @{Regex = '\s*<ImageInstall>([\s\S]*?)<\/ImageInstall>'; NewValue = '' },
            @{Regex = '\s*<UserAccounts>([\s\S]*?)<\/UserAccounts>'; NewValue = '' },
            @{Regex = '\s*<AutoLogon>([\s\S]*?)<\/AutoLogon>'; NewValue = '' },
            @{Regex = '\s*<RunSynchronousCommand wcm:action="add">(?:[\s\S](?!<RunSynchronousCommand))*?diskpart[\s\S]*?<\/RunSynchronousCommand>'; NewValue = '' },
            @{Regex = '(?s)\s*\{[^{}]*?AutoLogonCount[^{}]*?\}\s*;'; NewValue = '' }
        )
    )

    [String]$Content = Get-Content $TemplateFile -Raw -Encoding UTF8

    foreach ($Item in $StringReplacementMap) {
        $Content = $Content.Replace($Item.OldValue, $Item.NewValue)
    }

    foreach ($Item in $RegexReplacementMap) {
        $Content = $Content -replace $Item.Regex, $Item.NewValue
    }

    if ($FullBuild) {
        foreach ($Item in $DevRegexReplacementMap) {
            $Content = $Content -replace $Item.Regex, $Item.NewValue
        }
    }

    $Content = "<!-- Version: {VERSION} -->`n" + $Content

    Write-File $BaseFile $Content
}
