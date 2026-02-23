function New-BatchScript {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ProjectName,
        [Parameter(Position = 1, Mandatory)][String]$Ps1File,
        [Parameter(Position = 2, Mandatory)][String]$BatchFile,
        [Parameter(Position = 3, Mandatory)][String]$VmPath
    )

    New-Activity 'Building batch script'

    Set-Variable -Option Constant PowerShellLines ([String](Read-TextFile $Ps1File))

    Set-Variable -Option Constant BatchLines (
        [String]("@echo off

set `"appdir=%LOCALAPPDATA%\$ProjectName`"
if not exist `"%appdir%`" mkdir `"%appdir%`"
set `"psfile=%appdir%\$ProjectName.ps1`"

> `"%psfile%`" (
    for /f `"delims=`" %%A in ('findstr `"^::`" `"%~f0`"') do (
        set `"line=%%A`"
        setlocal enabledelayedexpansion
        echo(!line:~2!
        endlocal
    )
)

if `"%~1`"==`"Debug`" (
    powershell -ExecutionPolicy Bypass -Command `"& '%psfile%' -WorkingDirectory '%cd%' -DevMode`"
) else (
    powershell -ExecutionPolicy Bypass -Command `"& '%psfile%' -WorkingDirectory '%cd%'`"
)

::$($PowerShellLines.Replace("`n", "`n::"))"
        )
    )

    Write-LogInfo "Writing batch file $BatchFile"
    Write-TextFile $BatchFile $BatchLines -Normalize
    Copy-Item $BatchFile "$VmPath\$ProjectName.bat"

    Write-ActivityCompleted
}
