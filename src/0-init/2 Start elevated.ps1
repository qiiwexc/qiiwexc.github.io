if (-not (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host 'Restarting elevated...'

    try {
        [String[]]$ElevationArgs = @('-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-WorkingDirectory', $WorkingDirectory)
        if ($DevMode) { $ElevationArgs += '-DevMode' }
        Start-Process PowerShell -Verb RunAs -ArgumentList $ElevationArgs
    } catch {
        Write-Error "Failed to restart elevated: $_"
        Start-Sleep -Seconds 5
    }

    exit
}
