function Get-ElevationArguments {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ScriptPath,
        [Parameter(Position = 1, Mandatory)][ValidatePattern('^[0-9A-Fa-f]{64}$')][String]$Sha256,
        [Parameter(Position = 2)][String]$WorkingDirectory,
        [Switch]$DevMode
    )

    # The script waits in the user's temp folder while the elevation prompt is open, where anything that runs
    # as that user can replace it. So the elevated process runs a copy in the system's temp folder, which a
    # standard user can neither change nor find by name, and only if it is the file hashed before asking.
    # The command reaches PowerShell as one argument in double quotes and has none of its own: the paths are
    # single-quoted literals, in which only the apostrophes PowerShell takes for quotes (C:\Users\O'Brien, and
    # the typographic ones) need escaping. A trailing backslash (a drive root such as 'E:\') is dropped, as the
    # launcher drops it
    Set-Variable -Option Constant Source ([String][Management.Automation.Language.CodeGeneration]::EscapeSingleQuotedStringContent($ScriptPath))
    Set-Variable -Option Constant Directory ([String][Management.Automation.Language.CodeGeneration]::EscapeSingleQuotedStringContent($WorkingDirectory.TrimEnd('\')))

    [String]$Run = "& `$Copy -WorkingDirectory '$Directory'"
    if ($DevMode) {
        $Run += ' -DevMode'
    }

    Set-Variable -Option Constant Command (
        [String](
            "`$Copy = Join-Path `$env:SystemRoot ('Temp\qiiwexc_' + [Guid]::NewGuid() + '.ps1'); " +
            'try { ' +
            "Copy-Item -LiteralPath '$Source' -Destination `$Copy -ErrorAction Stop; " +
            "if ((Get-FileHash -LiteralPath `$Copy -Algorithm SHA256).Hash -ne '$Sha256') { throw 'The script was changed while it waited for elevation' }; " +
            "$Run " +
            '} catch { Write-Host $_; Start-Sleep -Seconds 5; exit 1 } ' +
            'finally { Remove-Item -LiteralPath $Copy -Force -ErrorAction SilentlyContinue }'
        )
    )

    return @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', "`"$Command`"")
}

if (-not (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host 'Restarting elevated...'

    try {
        Set-Variable -Option Constant ScriptHash ([String](Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256 -ErrorAction Stop).Hash)
        # By its full path: a bare name is looked up in the current directory too, which is the user's own
        Set-Variable -Option Constant PowerShellPath ([String]"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe")
        Start-Process $PowerShellPath -Verb RunAs -ArgumentList (Get-ElevationArguments -ScriptPath $PSCommandPath -Sha256 $ScriptHash -WorkingDirectory $WorkingDirectory -DevMode:$DevMode)
    } catch {
        Write-Error "Failed to restart elevated: $_"
        Start-Sleep -Seconds 5
    }

    exit
}
