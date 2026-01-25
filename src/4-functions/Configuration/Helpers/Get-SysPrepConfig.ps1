function Get-SysPrepConfig {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Config
    )

    return $Config.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
}
