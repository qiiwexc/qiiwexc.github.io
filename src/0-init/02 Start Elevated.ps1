if (!(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Set-Variable -Option Constant Arguments ("& '" + $MyInvocation.MyCommand.Definition + "'")
    Start-Process PowerShell -Verb RunAs -ArgumentList $Arguments
    Break
}
