# Runs reg.exe, which reports a failure through its exit code, and returns that
function Invoke-RegCommand {
    param(
        [Parameter(Position = 0, Mandatory)][String[]]$Arguments
    )

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
