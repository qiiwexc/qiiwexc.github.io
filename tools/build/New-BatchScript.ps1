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

set `"psfile=%temp%\$ProjectName.ps1`"

powershell -NoProfile -ExecutionPolicy Bypass -Command `"Get-Content -LiteralPath '%~f0' -Encoding UTF8 | Where-Object { `$_.StartsWith('::') } | ForEach-Object { `$_.Substring(2) } | Set-Content -LiteralPath '%psfile%' -Encoding UTF8`"

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
