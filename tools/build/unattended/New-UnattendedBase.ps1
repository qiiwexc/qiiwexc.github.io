function New-UnattendedBase {
    param(
        [Parameter(Position = 0, Mandatory)][String]$TemplatesPath,
        [Parameter(Position = 1, Mandatory)][String]$BaseFile
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
    <File path="C:\Users\Default\AppData\Local\Microsoft\Windows\TaskManager\settings.json">
{CONFIG_TASK_MANAGER_LOCALIZED}
    </File>
    <File path="C:\Users\Default\AppData\Roaming\qBittorrent\qBittorrent.ini">
{CONFIG_QBITTORRENT}
{CONFIG_QBITTORRENT_LOCALIZED}
    </File>'
    )

    Set-Variable -Option Constant StringReplacementMap ([ordered]@{
            "`t"                                                       = '  '
            '</ExtractScript>'                                         = $ConfigFiles
            'C:\Windows\Setup\Scripts\'                                = 'C:\Windows\Setup\'
            'HideOnlineAccountScreens>false</HideOnlineAccountScreens' = 'HideOnlineAccountScreens>true</HideOnlineAccountScreens'
        }
    )

    Set-Variable -Option Constant RegexReplacementMap ([ordered]@{
            'RemovePackages\.ps1">\s*\$selectors\s*=\s*@\(\s*([\s\S]*?)\s*\);' = "RemovePackages.ps1`">`n`$selectors = @({APP_REMOVAL_LIST});"
        }
    )

    [String]$Content = Read-TextFile $TemplateFile

    $StringReplacementMap.GetEnumerator() | ForEach-Object {
        $Content = $Content.Replace($_.Key, $_.Value)
    }

    $RegexReplacementMap.GetEnumerator() | ForEach-Object {
        $Content = $Content -replace $_.Key, $_.Value
    }

    # The XML declaration must be the very first thing in the document, so the version comment follows it
    Set-Variable -Option Constant VersionComment ([String]'<!-- Version: {VERSION} -->')
    if ($Content -match '^<\?xml[^>]*\?>') {
        $Content = $Content.Insert($Matches[0].Length, "`n$VersionComment")
    } else {
        $Content = "$VersionComment`n$Content"
    }

    Write-TextFile $BaseFile $Content -Normalize
}
