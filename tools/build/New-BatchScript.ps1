function New-BatchScript {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ProjectName,
        [String][Parameter(Position = 1, Mandatory)]$Ps1File,
        [String][Parameter(Position = 2, Mandatory)]$BatchFile,
        [String][Parameter(Position = 3, Mandatory)]$VmPath
    )

    New-Activity 'Building batch script'

    Set-Variable -Option Constant PowerShellLines ([String](Get-Content $Ps1File -Raw -Encoding UTF8))

    Set-Variable -Option Constant BatchLines (
        [String]("@echo off

set `"psfile=%temp%\$ProjectName.ps1`"

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
    Write-File $BatchFile $BatchLines
    Copy-Item $BatchFile "$VmPath\$ProjectName.bat"

    Write-ActivityCompleted
}
