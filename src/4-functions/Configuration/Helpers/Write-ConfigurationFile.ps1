function Write-ConfigurationFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName,
        [String][Parameter(Position = 1, Mandatory)]$Content,
        [String][Parameter(Position = 2, Mandatory)]$Path,
        [String][Parameter(Position = 3)]$ProcessName = $AppName
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    try {
        Stop-ProcessIfRunning $ProcessName

        Write-LogInfo "Writing $AppName configuration to '$Path'..." $LogIndentLevel

        $Null = New-Item -Force -ItemType Directory -ErrorAction Stop (Split-Path -Parent $Path -ErrorAction Stop)

        $Content | Set-Content $Path -NoNewline -ErrorAction Stop

        Out-Success $LogIndentLevel
    } catch {
        Write-LogWarning "Failed to write configuration file '$Path': $_" $LogIndentLevel
        throw $_
    }
}
