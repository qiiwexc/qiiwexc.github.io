function Write-ConfigurationFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName,
        [String][Parameter(Position = 1, Mandatory)]$Content,
        [String][Parameter(Position = 2, Mandatory)]$Path,
        [String][Parameter(Position = 3)]$ProcessName = $AppName
    )
    Set-Variable -Option Constant LogIndentLevel ([Int]2)

    Stop-ProcessIfRunning $ProcessName

    Write-LogInfo "Writing $AppName configuration to '$Path'..." $LogIndentLevel

    New-Item -Force -ItemType Directory (Split-Path -Parent $Path) | Out-Null

    $Content | Out-File $Path -Encoding UTF8

    Out-Success $LogIndentLevel
}
