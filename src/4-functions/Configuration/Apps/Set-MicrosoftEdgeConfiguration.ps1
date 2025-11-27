function Set-MicrosoftEdgeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    Write-ActivityProgress -PercentComplete 55 -Task "Configuring $AppName..."

    Set-Variable -Option Constant ProcessName ([String]'msedge')

    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$env:LocalAppData\Microsoft\Edge\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$env:LocalAppData\Microsoft\Edge\User Data\Default\Preferences"
}
