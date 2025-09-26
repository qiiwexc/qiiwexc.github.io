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
    throw 'System not supported'
}

[System.Windows.Forms.Application]::EnableVisualStyles()


Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


Set-Variable -Option Constant PATH_CURRENT_DIR $CallerPath
Set-Variable -Option Constant PATH_TEMP_DIR ([System.IO.Path]::GetTempPath())
Set-Variable -Option Constant PATH_APP_DIR "$PATH_TEMP_DIR\qiiwexc"
Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"


Set-Variable -Option Constant SYSTEM_LANGUAGE (Get-SystemLanguage)

Set-Variable -Option Constant PS_VERSION $PSVersionTable.PSVersion.Major

Set-Variable -Option Constant OPERATING_SYSTEM (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version)
Set-Variable -Option Constant IsWindows11 ($OPERATING_SYSTEM.Caption -match 'Windows 11')
Set-Variable -Option Constant OS_VERSION $(if ($IsWindows11) { 11 } else { switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } } })

Set-Variable -Option Constant WordRegPath (Get-ItemProperty 'Registry::HKEY_CLASSES_ROOT\Word.Application\CurVer' -ErrorAction SilentlyContinue)
Set-Variable -Option Constant OFFICE_VERSION $(if ($WordRegPath) { ($WordRegPath.'(default)') -replace '\D+', '' })
Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if ($OFFICE_VERSION) { if (Test-Path $PATH_OFFICE_C2R_CLIENT_EXE) { 'C2R' } else { 'MSI' } })

New-Item -Force -ItemType Directory $PATH_APP_DIR | Out-Null
