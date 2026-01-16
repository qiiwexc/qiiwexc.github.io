if (-not (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host 'Restarting elevated...'

    try {
        Start-Process PowerShell -Verb RunAs "-ExecutionPolicy Bypass -Command `"$($MyInvocation.Line)`""
    } catch {
        Write-Error $_
        Start-Sleep -Seconds 5
    }

    break
}
