function Add-SysPrepConfig {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Config
    )

    Set-Variable -Option Constant SysprepConfig ([String]($Config.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')))

    return "$SysprepConfig`n$Config"
}
