function Import-RegistryConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)]$Content
    )

    Set-Variable -Option Constant LogIndentLevel 2

    Write-LogInfo "Importing $AppName configuration into registry..." $LogIndentLevel

    try {
        Set-Variable -Option Constant RegFilePath ([String]"$PATH_APP_DIR\$AppName.reg")

        Initialize-AppDirectory

        "Windows Registry Editor Version 5.00`n`n" + (-join $Content) | Set-Content $RegFilePath -NoNewline -ErrorAction Stop

        Start-Process -Verb RunAs -Wait 'regedit' "/s `"$RegFilePath`"" -ErrorAction Stop

        Out-Success $LogIndentLevel
    } catch {
        Write-LogWarning "Failed to import file into registry: $_" $LogIndentLevel
        throw $_
    }
}
