function Add-SysPrepConfig {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Config
    )

    Set-Variable -Option Constant SysprepConfig ([String]($Config.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')))

    return "$SysprepConfig`n$Config"
}
