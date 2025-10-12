function Import-RegistryConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)]$Content
    )

    Set-Variable -Option Constant LogIndentLevel 2

    Write-LogInfo "Importing $AppName configuration into registry..." $LogIndentLevel

    Set-Variable -Option Constant RegFilePath "$PATH_APP_DIR\$AppName.reg"

    Initialize-AppDirectory

    "Windows Registry Editor Version 5.00`n`n" + (-join $Content) | Out-File $RegFilePath

    try {
        Start-Process -Verb RunAs -Wait 'regedit' "/s `"$RegFilePath`""
    } catch [Exception] {
        Write-LogException $_ 'Failed to import file into registry' $LogIndentLevel
        return
    }

    Out-Success $LogIndentLevel
}
