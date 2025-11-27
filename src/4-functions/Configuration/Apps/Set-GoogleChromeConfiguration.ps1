function Set-GoogleChromeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    Write-ActivityProgress -PercentComplete 75 -Task "Configuring $AppName..."

    Set-Variable -Option Constant ProcessName ([String]'chrome')

    Update-JsonFile $AppName $ProcessName $CONFIG_CHROME_LOCAL_STATE "$env:LocalAppData\Google\Chrome\User Data\Local State"
    Update-JsonFile $AppName $ProcessName $CONFIG_CHROME_PREFERENCES "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"
}
