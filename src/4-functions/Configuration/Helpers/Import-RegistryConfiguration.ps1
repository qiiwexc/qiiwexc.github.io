function Import-RegistryConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName,
        [Parameter(Position = 1, Mandatory)][String[]]$Content
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    # A failure is thrown for the caller to report, once
    Write-LogInfo "Importing $AppName configuration into registry..." $LogIndentLevel

    Set-Variable -Option Constant RegFilePath ([String]"$PATH_APP_DIR\$AppName.reg")
    Set-Variable -Option Constant AllKeys ([String](-join $Content))

    Initialize-AppDirectory

    # The keys Add-SysPrepConfig copied for new accounts go into the default user profile, loaded only for the import.
    # When it cannot be loaded they are left out, as reg.exe could not write them, and the rest is imported
    Set-Variable -Option Constant DefaultUserSection ([String]'^\[-?HKEY_USERS\\DefaultUser\\')
    Set-Variable -Option Constant ForNewUsers ([Bool]($AllKeys -match "(?m)$DefaultUserSection"))
    Set-Variable -Option Constant DefaultUserMounted ([Bool]($ForNewUsers -and (Mount-DefaultUserHive)))

    if ($ForNewUsers -and -not $DefaultUserMounted) {
        Set-Variable -Option Constant Keys ([String](-join @([Regex]::Split($AllKeys, '(?m)^(?=\[)') | Where-Object { $_ -notmatch $DefaultUserSection })))
    } else {
        Set-Variable -Option Constant Keys ([String]$AllKeys)
    }

    try {
        # UTF-16, the encoding of a "Version 5.00" file, which reg.exe reads whatever the code page. A file in the ANSI
        # code page reaches the registry intact only as far as it holds ASCII
        "Windows Registry Editor Version 5.00`n`n$Keys" | Set-Content $RegFilePath -NoNewline -Encoding Unicode -ErrorAction Stop

        Set-Variable -Option Constant ExitCode ([Int](Invoke-RegistryImport $RegFilePath))

        if ($ExitCode -ne 0) {
            Set-Variable -Option Constant RefusedKeys ([String[]]@(Get-RefusedRegistryKey $Keys "$PATH_APP_DIR\$AppName (one key).reg"))
            if ($RefusedKeys.Count -gt 0) {
                throw "Could not write $($RefusedKeys -join ', '), every other key was written"
            }

            Write-LogDebug "Registry import failed with exit code $ExitCode, but every key was written when imported on its own" $LogIndentLevel
        }
    } finally {
        if ($DefaultUserMounted) {
            Dismount-DefaultUserHive
        }
    }

    Out-Success $LogIndentLevel
}
