function New-BatchScript {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory)]$BatchFile
    )

    Write-LogInfo 'Building batch script...'

    [Collections.Generic.List[String]]$PowerShellLines = Get-Content $Ps1File

    [Collections.Generic.List[String]]$BatchLines = "@echo off`n"
    $BatchLines.Add("if `"%~1`"==`"Debug`" set debug=true`n")
    $BatchLines.Add("set `"psfile=%temp%\$ProjectName.ps1`"`n")
    $BatchLines.Add('> "%psfile%" (')
    $BatchLines.Add("  for /f `"delims=`" %%A in ('findstr `"^::`" `"%~f0`"') do (")
    $BatchLines.Add('    set "line=%%A"')
    $BatchLines.Add('    setlocal enabledelayedexpansion')
    $BatchLines.Add('    echo(!line:~2!')
    $BatchLines.Add('    endlocal')
    $BatchLines.Add('  )')
    $BatchLines.Add(")`n")
    $BatchLines.Add('if "%debug%"=="true" (')
    $BatchLines.Add("  powershell -ExecutionPolicy Bypass -Command `"& '%psfile%' -WorkingDirectory '%cd%' -DevMode`"")
    $BatchLines.Add(') else (')
    $BatchLines.Add("  powershell -ExecutionPolicy Bypass -Command `"& '%psfile%' -WorkingDirectory '%cd%'`"")
    $BatchLines.Add(")`n")

    foreach ($Line in $PowerShellLines) {
        $BatchLines.Add("::$($Line.Replace("`n", "`n::"))")
    }

    Write-LogInfo "Writing batch file $BatchFile"
    $BatchLines | Out-File $BatchFile -Encoding ASCII

    Out-Success
}
