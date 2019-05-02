Write-Host 'Initializing...'

Set-Variable IS_ELEVATED $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) -Option Constant

Set-Variable OLD_WINDOW_TITLE $($HOST.UI.RawUI.WindowTitle) -Option Constant
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"

Set-Variable PSShellInvocationCommand $((Get-ItemProperty 'HKLM:\SOFTWARE\Classes\Microsoft.PowerShellScript.1\Shell\0\Command').'(default)') -Option Constant
Set-Variable StartedFromGUI $("`"$($MyInvocation.Line)`"" -eq $PSShellInvocationCommand.Split(' ', 3)[2].Replace('%1', $MyInvocation.MyCommand.Definition)) -Option Constant
Set-Variable HIDE_CONSOLE ($args[0] -eq '-HideConsole' -or $StartedFromGUI -or -not $MyInvocation.Line) -Option Constant

if ($HIDE_CONSOLE) {
    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

try { Add-Type -AssemblyName System.Windows.Forms } catch { Throw 'System not supported' }

[System.Windows.Forms.Application]::EnableVisualStyles()

Set-Variable PS_VERSION $($PSVersionTable.PSVersion.Major) -Option Constant
