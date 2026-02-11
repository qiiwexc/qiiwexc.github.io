function Set-MicrosoftEdgeConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName
    )

    try {
        Set-Variable -Option Constant ProcessName ([String]'msedge')

        Update-BrowserConfiguration $AppName $ProcessName -Content $CONFIG_EDGE_LOCAL_STATE -Path "$env:LocalAppData\Microsoft\Edge\User Data\Local State"
        Update-BrowserConfiguration $AppName $ProcessName -Content $CONFIG_EDGE_PREFERENCES -Path "$env:LocalAppData\Microsoft\Edge\User Data\Default\Preferences"

        Out-Success
    } catch {
        Out-Failure "Failed to configure '$AppName': $_"
    }
}
