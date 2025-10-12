function New-BatchScript {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory)]$BatchFile
    )

    Write-LogInfo 'Building batch script...'

    [Collections.Generic.List[String]]$PowerShellStrings = Get-Content $Ps1File

    [Collections.Generic.List[String]]$BatchStrings = "@echo off`n"
    $BatchStrings.Add("if `"%~1`"==`"Debug`" set debug=true`n")
    $BatchStrings.Add("set `"psfile=%temp%\$ProjectName.ps1`"`n")
    $BatchStrings.Add('> "%psfile%" (')
    $BatchStrings.Add("  for /f `"delims=`" %%A in ('findstr `"^::`" `"%~f0`"') do (")
    $BatchStrings.Add('    set "line=%%A"')
    $BatchStrings.Add('    setlocal enabledelayedexpansion')
    $BatchStrings.Add('    echo(!line:~2!')
    $BatchStrings.Add('    endlocal')
    $BatchStrings.Add('  )')
    $BatchStrings.Add(")`n")
    $BatchStrings.Add('if "%debug%"=="true" (')
    $BatchStrings.Add("  powershell -ExecutionPolicy Bypass -Command `"& '%psfile%' -WorkingDirectory '%cd%' -DevMode`"")
    $BatchStrings.Add(') else (')
    $BatchStrings.Add("  powershell -ExecutionPolicy Bypass -Command `"& '%psfile%' -WorkingDirectory '%cd%'`"")
    $BatchStrings.Add(")`n")

    foreach ($String in $PowerShellStrings) {
        $BatchStrings.Add("::$($String.Replace("`n", "`n::"))")
    }

    Write-LogInfo "Writing batch file $BatchFile"
    $BatchStrings | Out-File $BatchFile -Encoding ASCII

    Out-Success
}
