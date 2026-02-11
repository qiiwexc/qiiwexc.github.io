function Set-GoogleChromeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        Set-Variable -Option Constant ProcessName ([String]'chrome')

        Update-BrowserConfiguration $AppName $ProcessName -Content $CONFIG_CHROME_LOCAL_STATE -Path "$env:LocalAppData\Google\Chrome\User Data\Local State"
        Update-BrowserConfiguration $AppName $ProcessName -Content $CONFIG_CHROME_PREFERENCES -Path "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"

        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
