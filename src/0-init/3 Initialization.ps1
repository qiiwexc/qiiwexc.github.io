Write-Host 'Initializing...'

Set-Variable -Option Constant ORIGINAL_WINDOW_TITLE ([String]$HOST.UI.RawUI.WindowTitle)
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION"

try {
    Add-Type -AssemblyName System.Windows.Forms
} catch {
    throw "System not supported: Failed to load 'System.Windows.Forms' module: $_"
}

Set-Variable -Option Constant OPERATING_SYSTEM ([PSObject](Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture))
Set-Variable -Option Constant WindowsBuild ([String]$OPERATING_SYSTEM.Version)

Set-Variable -Option Constant OS_64_BIT ([Bool]($env:PROCESSOR_ARCHITECTURE -like '*64'))

if ($OPERATING_SYSTEM.Caption -match 'Windows 11') {
    Set-Variable -Option Constant OS_VERSION ([Int]11)
} elseif ($WindowsBuild -match '10.0.*') {
    Set-Variable -Option Constant OS_VERSION ([Int]10)
} else {
    Write-Error "Unsupported Operating System: $($OPERATING_SYSTEM.Caption) (Build $WindowsBuild)"
    Start-Sleep -Seconds 5
    break
}

if (-not $DevMode) {
    Add-Type -Namespace Console -Name Window -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

[Windows.Forms.Application]::EnableVisualStyles()

Set-Variable -Option Constant PATH_WORKING_DIR ([String]$WorkingDirectory)
Set-Variable -Option Constant PATH_TEMP_DIR ([IO.Path]::GetTempPath())
Set-Variable -Option Constant PATH_SYSTEM_32 ("$env:SystemRoot\System32")
Set-Variable -Option Constant PATH_APP_DIR ([String]"$($PATH_TEMP_DIR)qiiwexc")
Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE ([String]"$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe")
Set-Variable -Option Constant PATH_7ZIP_EXE ([String]"$env:ProgramFiles\7-Zip\7z.exe")
Set-Variable -Option Constant PATH_OOSHUTUP10 ([String]"$env:ProgramData\OOShutUp10++")


Set-Variable -Option Constant IS_LAPTOP ([Bool]((Get-CimInstance -Class Win32_ComputerSystem -Property PCSystemType).PCSystemType -eq 2))
Set-Variable -Option Constant SYSTEM_LANGUAGE ([String](Get-SystemLanguage))
