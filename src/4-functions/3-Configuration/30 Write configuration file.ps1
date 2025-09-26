function Write-ConfigurationFile {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Content,
        [String][Parameter(Position = 2, Mandatory = $True)]$Path,
        [String][Parameter(Position = 3)]$ProcessName = $AppName
    )

    Write-Log $INF "Writing $AppName configuration to '$Path'..."

    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue

    New-Item -ItemType Directory (Split-Path -Parent $Path) -ErrorAction SilentlyContinue
    $Content | Out-File $Path

    Out-Success
}
