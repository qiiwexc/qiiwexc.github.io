function Find-RunningProcess {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ProcessName
    )

    return Get-Process -ErrorAction Stop | Where-Object { $_.ProcessName -eq $ProcessName }
}
