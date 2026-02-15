function Write-ConfigurationFile {
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName,
        [Parameter(Position = 1, Mandatory)][String]$Content,
        [Parameter(Position = 2, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    try {
        Stop-ProcessIfRunning $AppName

        Write-LogInfo "Writing $AppName configuration to '$Path'..." $LogIndentLevel

        New-Directory (Split-Path -Parent $Path -ErrorAction Stop)

        Set-Content $Path $Content -NoNewline -ErrorAction Stop

        Out-Success $LogIndentLevel
    } catch {
        Write-LogWarning "Failed to write configuration file '$Path': $_" $LogIndentLevel
        throw $_
    }
}
