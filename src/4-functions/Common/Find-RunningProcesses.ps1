function Find-RunningProcesses {
    param(
        [Parameter(Position = 0, Mandatory)][String[]]$ProcessNames
    )

    return Get-Process -Name $ProcessNames -ErrorAction SilentlyContinue
}
