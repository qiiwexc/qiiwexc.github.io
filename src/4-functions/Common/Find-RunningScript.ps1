function Find-RunningScript {
    param(
        [String][Parameter(Position = 0, Mandatory)]$CommandLinePart
    )

    return Get-CimInstance -ClassName Win32_Process -Filter "name='powershell.exe'" | Where-Object { $_.CommandLine -like "*$CommandLinePart*" }
}
