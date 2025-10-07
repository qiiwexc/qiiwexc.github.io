function Set-7zipConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    [String]$ConfigLines = $CONFIG_7ZIP.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
    $ConfigLines += "`n"
    $ConfigLines += $CONFIG_7ZIP

    Import-RegistryConfiguration $AppName $ConfigLines
}
