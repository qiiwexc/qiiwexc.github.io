function Set-7zipConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    Write-ActivityProgress -PercentComplete 25 -Task "Configuring $AppName..."

    [Collections.Generic.List[String]]$ConfigLines = $CONFIG_7ZIP.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
    $ConfigLines.Add("`n")
    $ConfigLines.Add($CONFIG_7ZIP)

    Import-RegistryConfiguration $AppName $ConfigLines
}
