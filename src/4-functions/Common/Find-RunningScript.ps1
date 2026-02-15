function Find-RunningScript {
    param(
        [Parameter(Position = 0, Mandatory)][String]$CommandLinePart
    )

    return Get-CimInstance -ClassName Win32_Process -Filter "name='powershell.exe' OR name='pwsh.exe'" | Where-Object { $_.CommandLine -like "*$CommandLinePart*" }
}
