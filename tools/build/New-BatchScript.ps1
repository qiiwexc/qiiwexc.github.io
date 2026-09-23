function New-BatchScript {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ProjectName,
        [Parameter(Position = 1, Mandatory)][String]$Ps1File,
        [Parameter(Position = 2, Mandatory)][String]$BatchFile,
        [Parameter(Position = 3, Mandatory)][String]$VmPath
    )

    New-Activity 'Building batch script'

    Set-Variable -Option Constant PowerShellLines ([String](Read-TextFile $Ps1File))

    # Paths reach PowerShell through environment variables rather than being pasted into the command
    # text, where an apostrophe (C:\Users\O'Brien) or a parenthesis would break the quoting.
    # The working directory is the folder of this file, not the current directory, which is
    # C:\Windows\System32 when the file is started with "Run as administrator".
    Set-Variable -Option Constant BatchLines (
        [String]("@echo off

set `"psfile=%temp%\$ProjectName.ps1`"
set `"batfile=%~f0`"
set `"workdir=%~dp0`"

powershell -NoProfile -ExecutionPolicy Bypass -Command `"Get-Content -LiteralPath `$env:batfile -Encoding UTF8 | Where-Object { `$_.StartsWith('::') } | ForEach-Object { `$_.Substring(2) } | Set-Content -LiteralPath `$env:psfile -Encoding UTF8`"

if `"%~1`"==`"Debug`" (
    powershell -ExecutionPolicy Bypass -Command `"& `$env:psfile -WorkingDirectory `$env:workdir.TrimEnd('\') -DevMode`"
) else (
    powershell -ExecutionPolicy Bypass -Command `"& `$env:psfile -WorkingDirectory `$env:workdir.TrimEnd('\')`"
)

::$($PowerShellLines.Replace("`n", "`n::"))"
        )
    )

    Write-LogInfo "Writing batch file $BatchFile"
    Write-TextFile $BatchFile $BatchLines -Normalize
    Copy-Item $BatchFile "$VmPath\$ProjectName.bat"

    Write-ActivityCompleted
}
