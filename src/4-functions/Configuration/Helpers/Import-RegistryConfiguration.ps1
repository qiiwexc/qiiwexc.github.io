function Import-RegistryConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName,
        [Parameter(Position = 1, Mandatory)][String[]]$Content
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    try {
        Write-LogInfo "Importing $AppName configuration into registry..." $LogIndentLevel

        Set-Variable -Option Constant RegFilePath ([String]"$PATH_APP_DIR\$AppName.reg")

        Initialize-AppDirectory

        "Windows Registry Editor Version 5.00`n`n" + (-join $Content) | Set-Content $RegFilePath -NoNewline -ErrorAction Stop

        if ($PSCmdlet.ShouldProcess($AppName, 'Import registry configuration')) {
            Start-Process -Verb RunAs -Wait 'regedit' "/s `"$RegFilePath`"" -ErrorAction Stop
        }

        Out-Success $LogIndentLevel
    } catch {
        Write-LogWarning "Failed to import file into registry: $_" $LogIndentLevel
        throw $_
    }
}
