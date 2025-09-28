function Write-ConfigurationFile {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Content,
        [String][Parameter(Position = 2, Mandatory = $True)]$Path,
        [String][Parameter(Position = 3)]$ProcessName = $AppName
    )

    Stop-ProcessIfRunning $ProcessName

    Write-LogInfo "Writing $AppName configuration to '$Path'..."

    New-Item -Force -ItemType Directory (Split-Path -Parent $Path) | Out-Null

    $Content | Out-File $Path

    Out-Success
}
