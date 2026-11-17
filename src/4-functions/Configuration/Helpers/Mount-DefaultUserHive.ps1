# Loads the profile that accounts are created from as HKEY_USERS\DefaultUser, where Add-SysPrepConfig puts the keys for
# them, and returns whether it did. A failure is only a warning: the current user's keys do not depend on it
function Mount-DefaultUserHive {
    Set-Variable -Option Constant LogIndentLevel ([Int]2)

    try {
        # Where Windows keeps it, rather than C:\Users\Default: the system drive is not always C:
        Set-Variable -Option Constant ProfilePath ([String](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -Name 'Default' -ErrorAction Stop).Default)

        Set-Variable -Option Constant ExitCode ([Int](Invoke-RegCommand @('load', 'HKU\DefaultUser', "`"$ProfilePath\NTUSER.DAT`"")))
        if ($ExitCode -ne 0) {
            throw "reg.exe exited with code $ExitCode"
        }

        Write-LogDebug "Loaded the default user profile from '$ProfilePath'" $LogIndentLevel
        return $True
    } catch {
        Write-LogWarning "Accounts created from now on will not get these settings, as the default user profile could not be loaded: $_" $LogIndentLevel
        return $False
    }
}
