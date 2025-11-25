Write-Host 'Initializing...'

Set-Variable -Option Constant OLD_WINDOW_TITLE ($HOST.UI.RawUI.WindowTitle)
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION"

try {
    Add-Type -AssemblyName System.Windows.Forms
} catch {
    throw 'System not supported'
}

if (-not $DevMode) {
    Add-Type -Namespace Console -Name Window -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

[Windows.Forms.Application]::EnableVisualStyles()


Set-Variable -Option Constant PATH_WORKING_DIR $WorkingDirectory
Set-Variable -Option Constant PATH_TEMP_DIR ([IO.Path]::GetTempPath())
Set-Variable -Option Constant PATH_APP_DIR "$($PATH_TEMP_DIR)qiiwexc"
Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
Set-Variable -Option Constant PATH_WINUTIL "$env:ProgramData\WinUtil"
Set-Variable -Option Constant PATH_OOSHUTUP10 "$env:ProgramData\OOShutUp10++"


Set-Variable -Option Constant IS_LAPTOP ((Get-CimInstance -Class Win32_ComputerSystem -Property PCSystemType).PCSystemType -eq 2)

Set-Variable -Option Constant SYSTEM_LANGUAGE (Get-SystemLanguage)

Set-Variable -Option Constant PS_VERSION $PSVersionTable.PSVersion.Major

Set-Variable -Option Constant OPERATING_SYSTEM (Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture)
Set-Variable -Option Constant IsWindows11 ($OPERATING_SYSTEM.Caption -match 'Windows 11')
Set-Variable -Option Constant WindowsBuild $OPERATING_SYSTEM.Version

Set-Variable -Option Constant OS_64_BIT ($env:PROCESSOR_ARCHITECTURE -like '*64')

if ($IsWindows11) {
    Set-Variable -Option Constant OS_VERSION 11
} else {
    switch -Wildcard ($WindowsBuild) {
        '10.0.*' {
            Set-Variable -Option Constant OS_VERSION 10
        }
        '6.3.*' {
            Set-Variable -Option Constant OS_VERSION 8.1
        }
        '6.2.*' {
            Set-Variable -Option Constant OS_VERSION 8
        }
        '6.1.*' {
            Set-Variable -Option Constant OS_VERSION 7
        }
        Default {
            Set-Variable -Option Constant OS_VERSION 'Vista or less / Unknown'
        }
    }
}

Set-Variable -Option Constant WordRegPath 'Registry::HKEY_CLASSES_ROOT\Word.Application\CurVer'
if (Test-Path $WordRegPath) {
    Set-Variable -Option Constant WordPath (Get-ItemProperty $WordRegPath)
    Set-Variable -Option Constant OFFICE_VERSION ($WordPath.'(default)' -replace '\D+', '')

    if (Test-Path $PATH_OFFICE_C2R_CLIENT_EXE) {
        Set-Variable -Option Constant OFFICE_INSTALL_TYPE 'C2R'
    } else {
        Set-Variable -Option Constant OFFICE_INSTALL_TYPE 'MSI'
    }
}
