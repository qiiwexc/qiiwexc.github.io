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

        Initialize-AppDirectory

        "Windows Registry Editor Version 5.00`n`n" + (-join $Content) | Set-Content $RegFilePath -NoNewline -ErrorAction Stop

        if ($PSCmdlet.ShouldProcess($AppName, 'Import registry configuration')) {
            # Unlike 'regedit /s', reg.exe reports a failed import through its exit code. '/reg:64' keeps
            # the 64-bit view regedit writes to, even from a 32-bit PowerShell on a 64-bit system
            [String[]]$Arguments = @('import', "`"$RegFilePath`"")
            if ($OS_64_BIT) {
                $Arguments += '/reg:64'
            }

            Set-Variable -Option Constant RegProcess ([PSObject](Start-Process 'reg' $Arguments -Wait -PassThru -WindowStyle Hidden -ErrorAction Stop))
            if ($RegProcess.ExitCode -ne 0) {
                throw "Registry import failed with exit code $($RegProcess.ExitCode)"
            }
        }

        Out-Success $LogIndentLevel
    } catch {
        Write-LogWarning "Failed to import file into registry: $_" $LogIndentLevel
        throw $_
    }
}
