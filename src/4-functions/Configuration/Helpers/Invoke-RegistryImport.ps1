function Invoke-RegistryImport {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path
    )

    # Unlike 'regedit /s', reg.exe reports a failed import through its exit code. '/reg:64' keeps the 64-bit view
    # regedit writes to, even from a 32-bit PowerShell on a 64-bit system
    [String[]]$Arguments = @('import', "`"$Path`"")
    if ($OS_64_BIT) {
        $Arguments += '/reg:64'
    }

    # Waited for through the process: Start-Process -Wait takes a second or more even for one as quick as reg.exe. Not
    # a constant, as Set-Variable turns its value into a string, which an exited process fails
    [Object]$Process = Start-Process 'reg' $Arguments -PassThru -WindowStyle Hidden -ErrorAction Stop
    try {
        $Process.WaitForExit()
        return [Int]$Process.ExitCode
    } finally {
        $Process.Dispose()
    }
}
