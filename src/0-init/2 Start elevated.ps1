if (-not (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host 'Restarting elevated...'

    try {
        # Quote path arguments explicitly: Start-Process joins the argument array with
        # spaces without quoting, so paths containing spaces would be split apart
        [String[]]$ElevationArgs = @('-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-WorkingDirectory', "`"$WorkingDirectory`"")
        if ($DevMode) { $ElevationArgs += '-DevMode' }
        Start-Process PowerShell -Verb RunAs -ArgumentList $ElevationArgs
    } catch {
        Write-Error "Failed to restart elevated: $_"
        Start-Sleep -Seconds 5
    }

    exit
}
