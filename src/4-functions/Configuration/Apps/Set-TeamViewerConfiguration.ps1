function Set-TeamViewerConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    Write-ActivityProgress -PercentComplete 40 -Task "Configuring $AppName..."

    [String]$ConfigLines = $CONFIG_TEAMVIEWER.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
    $ConfigLines += "`n"
    $ConfigLines += $CONFIG_TEAMVIEWER

    Import-RegistryConfiguration $AppName $ConfigLines
}
