# Copies the per-user keys for the accounts created from now on, into the default user's profile, which
# Import-RegistryConfiguration loads under this name for the import, as the answer files do. The machine keys are
# written once, as they are
function Add-SysPrepConfig {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Config
    )

    # Each section from its header to the next one, comments and blank lines included
    Set-Variable -Option Constant UserSections ([String[]]@([Regex]::Split($Config, '(?m)^(?=\[)') | Where-Object { $_ -match '^\[-?HKEY_CURRENT_USER\\' }))

    if ($UserSections.Count -eq 0) {
        return $Config
    }

    Set-Variable -Option Constant SysprepConfig ([String]((-join $UserSections).Replace('HKEY_CURRENT_USER', 'HKEY_USERS\DefaultUser')))

    return "$SysprepConfig`n$Config"
}
