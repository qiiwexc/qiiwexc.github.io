# Fails by throwing, for the caller to report once
function Write-ConfigurationFile {
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName,
        [Parameter(Position = 1, Mandatory)][String]$Content,
        [Parameter(Position = 2, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Stop-ProcessIfRunning $AppName

    Write-LogInfo "Writing $AppName configuration to '$Path'..." $LogIndentLevel

    New-Directory (Split-Path -Parent $Path -ErrorAction Stop)

    # The file is replaced as a whole, settings of the user's own included
    Backup-File $Path ($LogIndentLevel + 1)

    # The apps read UTF-8, which a merged file can hold beyond the ASCII of the app's own configs, such as a
    # path under a user name in Cyrillic
    Write-Utf8File $Path $Content

    Out-Success $LogIndentLevel
}
