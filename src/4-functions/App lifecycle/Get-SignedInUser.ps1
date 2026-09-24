function Get-SignedInUser {
    # The shell of this session runs as whoever is signed in at the screen, which is not the account the
    # app runs as when a standard user elevated it with an administrator's credentials. Returns an empty
    # string when that cannot be told, such as when no Explorer runs in the session
    try {
        Set-Variable -Option Constant SessionId ([Int][Diagnostics.Process]::GetCurrentProcess().SessionId)
        Set-Variable -Option Constant Shell ([Object](Get-CimInstance -ClassName Win32_Process -Filter "Name='explorer.exe' AND SessionId=$SessionId" -ErrorAction Stop | Select-Object -First 1))

        if (-not $Shell) {
            return ''
        }

        Set-Variable -Option Constant Owner ([Object](Invoke-CimMethod -InputObject $Shell -MethodName GetOwner -ErrorAction Stop))

        if ($Owner.ReturnValue -ne 0) {
            return ''
        }

        return "$($Owner.Domain)\$($Owner.User)"
    } catch {
        Write-LogDebug "Failed to find the signed-in user: $_"
        return ''
    }
}
