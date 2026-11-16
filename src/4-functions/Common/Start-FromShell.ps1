function Start-FromShell {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Target
    )

    # Explorer started by this elevated process hands its argument to the shell that already runs in the
    # session and exits, so the target starts as the signed-in user, without elevation. Where no shell
    # runs, explorer.exe would become the shell itself, elevated, so the target is started directly
    Set-Variable -Option Constant SessionId ([Int][Diagnostics.Process]::GetCurrentProcess().SessionId)
    [Bool]$ViaShell = [Bool](Get-Process -Name 'explorer' -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $SessionId })

    # A local file belongs to the account the app runs as. When a standard user elevated the app with an
    # administrator's credentials that is not the signed-in user, who may not be able to read it (the app's
    # temp folder) and has a profile of their own (a browser started to create one)
    if ($ViaShell -and $Target -notmatch '^https?://') {
        $ViaShell = (Get-SignedInUser) -eq [Security.Principal.WindowsIdentity]::GetCurrent().Name
    }

    if ($ViaShell) {
        Start-Process "$env:SystemRoot\explorer.exe" "`"$Target`"" -ErrorAction Stop
    } else {
        Write-LogDebug "Starting '$Target' as the app's own account"
        Start-Process $Target -ErrorAction Stop
    }
}
