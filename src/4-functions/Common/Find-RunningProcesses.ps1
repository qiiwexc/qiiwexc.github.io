function Find-RunningProcesses {
    param(
        [String[]][Parameter(Position = 0, Mandatory)]$ProcessNames
    )

    return Get-Process -ErrorAction Stop | Where-Object { $ProcessNames -contains $_.ProcessName }
}
