function Import-RegistryConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName,
        [Parameter(Position = 1, Mandatory)][String[]]$Content
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    try {
        Write-LogInfo "Importing $AppName configuration into registry..." $LogIndentLevel

        Set-Variable -Option Constant RegFilePath ([String]"$PATH_APP_DIR\$AppName.reg")
        Set-Variable -Option Constant Keys ([String](-join $Content))

        Initialize-AppDirectory

        "Windows Registry Editor Version 5.00`n`n$Keys" | Set-Content $RegFilePath -NoNewline -ErrorAction Stop

        if ($PSCmdlet.ShouldProcess($AppName, 'Import registry configuration')) {
            Set-Variable -Option Constant ExitCode ([Int](Invoke-RegistryImport $RegFilePath))

            if ($ExitCode -ne 0) {
                Set-Variable -Option Constant RefusedKeys ([String[]]@(Get-RefusedRegistryKey $Keys "$PATH_APP_DIR\$AppName (one key).reg"))
                if ($RefusedKeys.Count -gt 0) {
                    throw "Could not write $($RefusedKeys -join ', '), every other key was written"
                }

                Write-LogDebug "Registry import failed with exit code $ExitCode, but every key was written when imported on its own" $LogIndentLevel
            }
        }

        Out-Success $LogIndentLevel
    } catch {
        Write-LogWarning "Failed to import file into registry: $_" $LogIndentLevel
        throw $_
    }
}
