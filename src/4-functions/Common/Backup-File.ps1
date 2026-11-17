# Keeps a file the app is about to overwrite as '<name>.bak' beside it, so that the last run can be undone by hand. Fails
# by throwing, so that nothing is overwritten without its copy
function Backup-File {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path,
        [Parameter(Position = 1)][Int]$Level = 1
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return
    }

    Set-Variable -Option Constant BackupPath ([String]"$Path.bak")

    Copy-Item -LiteralPath $Path -Destination $BackupPath -Force -ErrorAction Stop
    Write-LogInfo "Kept the previous version as '$BackupPath'" $Level
}
