Write-Host 'Initializing...'

Set-Variable -Option Constant OLD_WINDOW_TITLE ($HOST.UI.RawUI.WindowTitle)
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION"

if ($HideConsole) {
    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

try {
    Add-Type -AssemblyName System.Windows.Forms
} catch {
    Throw 'System not supported'
}

[System.Windows.Forms.Application]::EnableVisualStyles()


Set-Variable -Option Constant PS_VERSION $PSVersionTable.PSVersion.Major

Set-Variable -Option Constant OPERATING_SYSTEM (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version)
Set-Variable -Option Constant IsWindows11 ($OPERATING_SYSTEM.Caption -Match "Windows 11")
Set-Variable -Option Constant OS_VERSION $(if ($IsWindows11) { 11 } else { Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } } })

New-Item -Force -ItemType Directory $PATH_TEMP_DIR | Out-Null
