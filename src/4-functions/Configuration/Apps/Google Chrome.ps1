function Set-GoogleChromeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
    )

    Set-Variable -Option Constant ProcessName 'chrome'

    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$env:LocalAppData\Google\Chrome\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"
}
