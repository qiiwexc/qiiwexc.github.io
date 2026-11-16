function Set-GoogleChromeConfiguration {
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName
    )

    try {
        Set-Variable -Option Constant ProcessName ([String]'chrome')

        if (-not (Get-AppExecutablePath "$ProcessName.exe")) {
            Write-LogWarning "'$AppName' is not installed, skipping its configuration"
            return
        }

        Update-BrowserConfiguration $AppName $ProcessName -Content $CONFIG_CHROME_LOCAL_STATE -Path "$env:LocalAppData\Google\Chrome\User Data\Local State"
        Update-BrowserConfiguration $AppName $ProcessName -Content $CONFIG_CHROME_PREFERENCES -Path "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"

        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
