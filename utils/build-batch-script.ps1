function New-BatchScript {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory = $True)]$BatchFile
    )

    Write-LogInfo 'Building batch script...'

    [String[]]$PowerShellStrings = Get-Content $Ps1File

    [String[]]$BatchStrings = "@echo off`n"
    $BatchStrings += "if `"%~1`"==`"Debug`" set debug=true`n"
    $BatchStrings += "set `"psfile=%temp%\$ProjectName.ps1`"`n"
    $BatchStrings += '> "%psfile%" ('
    $BatchStrings += "  for /f `"delims=`" %%A in ('findstr `"^::`" `"%~f0`"') do ("
    $BatchStrings += '    set "line=%%A"'
    $BatchStrings += '    setlocal enabledelayedexpansion'
    $BatchStrings += '    echo(!line:~2!'
    $BatchStrings += '    endlocal'
    $BatchStrings += '  )'
    $BatchStrings += ")`n"
    $BatchStrings += 'if "%debug%"=="true" ('
    $BatchStrings += '  powershell -ExecutionPolicy Bypass "%psfile%" -CallerPath "%cd%"'
    $BatchStrings += ') else ('
    $BatchStrings += '  powershell -ExecutionPolicy Bypass "%psfile%" -CallerPath "%cd%" -HideConsole'
    $BatchStrings += ")`n"

    foreach ($String in $PowerShellStrings) {
        $BatchStrings += "::$($String.Replace("`n", "`n::"))"
    }

    Write-LogInfo "Writing batch file $BatchFile"
    $BatchStrings | Out-File $BatchFile -Encoding ASCII

    Out-Success
}
