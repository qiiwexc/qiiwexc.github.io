if (!(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host 'Restarting elevated...'
    Start-Process PowerShell -Verb RunAs "-ExecutionPolicy Bypass -Command `"$($MyInvocation.Line)`""
    Break
}
