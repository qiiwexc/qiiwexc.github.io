function New-UnattendedBase {
    param(
        [String][Parameter(Position = 0, Mandatory)]$TemplatesPath,
        [String][Parameter(Position = 1, Mandatory)]$BaseFile
    )

    Set-Variable -Option Constant TemplateFile ([String]"$TemplatesPath\autounattend.xml")

    Set-Variable -Option Constant ConfigFiles ([String]'</ExtractScript>
    <File path="C:\Windows\Setup\AppAssociations.xml">
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

    Set-Variable -Option Constant StringReplacementMap ([Hashtable]@{
            "`t"                                                       = '  '
            "Windows Registry Editor Version 5.00`r`n`r`n"             = ''
            '</ExtractScript>'                                         = $ConfigFiles
            'C:\Windows\Setup\Scripts\'                                = 'C:\Windows\Setup\'
            'HideOnlineAccountScreens>false</HideOnlineAccountScreens' = 'HideOnlineAccountScreens>true</HideOnlineAccountScreens'
        }
    )

    Set-Variable -Option Constant RegexReplacementMap ([Hashtable]@{
            'RemoveFeatures\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'     = "RemoveFeatures.ps1`">`n`$selectors = @({FEATURE_REMOVAL_LIST});"
            'RemoveCapabilities\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);' = "RemoveCapabilities.ps1`">`n`$selectors = @({CAPABILITY_REMOVAL_LIST});"
            'RemovePackages\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);'     = "RemovePackages.ps1`">`n`$selectors = @({APP_REMOVAL_LIST});"
        }
    )

    [String]$Content = Get-Content $TemplateFile -Raw -Encoding UTF8

    $StringReplacementMap.GetEnumerator() | ForEach-Object {
        $Content = $Content.Replace($_.Key, $_.Value)
    }

    $RegexReplacementMap.GetEnumerator() | ForEach-Object {
        $Content = $Content -replace $_.Key, $_.Value
    }

    $Content = "<!-- Version: {VERSION} -->`n" + $Content

    Write-File $BaseFile $Content
}
