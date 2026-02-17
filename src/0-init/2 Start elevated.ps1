if (-not (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host 'Restarting elevated...'

    try {
        Set-Variable -Option Constant EncodedCommand ([String][Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($MyInvocation.Line)))
        Start-Process PowerShell -Verb RunAs "-ExecutionPolicy Bypass -EncodedCommand $EncodedCommand"
    } catch {
        Write-Error "Failed to restart elevated: $_"
        Start-Sleep -Seconds 5
    }

    exit
}
