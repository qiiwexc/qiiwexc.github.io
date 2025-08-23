Write-Host 'Initializing...'

Set-Variable -Option Constant OLD_WINDOW_TITLE $($HOST.UI.RawUI.WindowTitle)
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"

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


Set-Variable -Option Constant PS_VERSION $($PSVersionTable.PSVersion.Major)

Set-Variable -Option Constant SHELL $(New-Object -com Shell.Application)

Set-Variable -Option Constant OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version)
Set-Variable -Option Constant OS_NAME $OperatingSystem.Caption
Set-Variable -Option Constant OS_BUILD $OperatingSystem.Version
Set-Variable -Option Constant OS_64_BIT $(if ($env:PROCESSOR_ARCHITECTURE -Like '*64') { $True })
Set-Variable -Option Constant OS_VERSION $(Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } })

Set-Variable -Option Constant WordRegPath (Get-ItemProperty "$(New-PSDrive HKCR Registry HKEY_CLASSES_ROOT):\Word.Application\CurVer" -ErrorAction SilentlyContinue)
Set-Variable -Option Constant OFFICE_VERSION $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' })
Set-Variable -Option Constant PathOfficeC2RClientExe "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if ($OFFICE_VERSION) { if (Test-Path $PathOfficeC2RClientExe) { 'C2R' } else { 'MSI' } })
