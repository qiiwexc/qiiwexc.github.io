@echo off

set "psfile=%temp%\qiiwexc.ps1"

> "%psfile%" (
    for /f "delims=" %%A in ('findstr "^::" "%~f0"') do (
        set "line=%%A"
        setlocal enabledelayedexpansion
        echo(!line:~2!
        endlocal
    )
)

if "%~1"=="Debug" (
    powershell -ExecutionPolicy Bypass -Command "& '%psfile%' -WorkingDirectory '%cd%' -DevMode"
) else (
    powershell -ExecutionPolicy Bypass -Command "& '%psfile%' -WorkingDirectory '%cd%'"
)

::#region init > Parameters
::
::#Requires -Version 5
::
::param(
::    [String][Parameter(Position = 0)]$WorkingDirectory,
::    [Switch]$DevMode
::)
::
::#endregion init > Parameters
::
::
::#region init > Version
::
::Set-Variable -Option Constant VERSION ([Version]'26.2.3')
::
::#endregion init > Version
::
::
::#region init > Start elevated
::
::if (-not (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
::    Write-Host 'Restarting elevated...'
::
::    try {
::        Start-Process PowerShell -Verb RunAs "-ExecutionPolicy Bypass -Command `"$($MyInvocation.Line)`""
::    } catch {
::        Write-Error "Failed to restart elevated: $_"
::        Start-Sleep -Seconds 5
::    }
::
::    break
::}
::
::#endregion init > Start elevated
::
::
::#region init > Initialization
::
::Write-Host 'Initializing...'
::
::Set-Variable -Option Constant ORIGINAL_WINDOW_TITLE ([String]$HOST.UI.RawUI.WindowTitle)
::$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION"
::
::try {
::    Add-Type -AssemblyName System.Windows.Forms
::} catch {
::    throw "System not supported: Failed to load 'System.Windows.Forms' module: $_"
::}
::
::Set-Variable -Option Constant OPERATING_SYSTEM ([PSObject](Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture))
::Set-Variable -Option Constant IsWindows11 ([Bool]($OPERATING_SYSTEM.Caption -match 'Windows 11'))
::Set-Variable -Option Constant WindowsBuild ([String]$OPERATING_SYSTEM.Version)
::
::Set-Variable -Option Constant OS_64_BIT ([Bool]($env:PROCESSOR_ARCHITECTURE -like '*64'))
::
::if ($IsWindows11) {
::    Set-Variable -Option Constant OS_VERSION ([Int]11)
::} else {
::    switch -Wildcard ($WindowsBuild) {
::        '10.0.*' {
::            Set-Variable -Option Constant OS_VERSION ([Int]10)
::        }
::        '6.3.*' {
::            Set-Variable -Option Constant OS_VERSION ([Int]8)
::        }
::        '6.2.*' {
::            Set-Variable -Option Constant OS_VERSION ([Int]8)
::        }
::        Default {
::            Set-Variable -Option Constant OS_VERSION ([Int]0)
::        }
::    }
::}
::
::if ($OS_VERSION -lt 10) {
::    Write-Error "Unsupported Operating System: $($OPERATING_SYSTEM.Caption) (Build $WindowsBuild)"
::    Start-Sleep -Seconds 5
::    break
::}
::
::if (-not $DevMode) {
::    Add-Type -Namespace Console -Name Window -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
::                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
::    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
::}
::
::[Windows.Forms.Application]::EnableVisualStyles()
::
::Set-Variable -Option Constant PATH_WORKING_DIR ([String]$WorkingDirectory)
::Set-Variable -Option Constant PATH_TEMP_DIR ([IO.Path]::GetTempPath())
::Set-Variable -Option Constant PATH_SYSTEM_32 ("$env:SystemRoot\System32")
::Set-Variable -Option Constant PATH_APP_DIR ([String]"$($PATH_TEMP_DIR)qiiwexc")
::Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE ([String]"$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe")
::Set-Variable -Option Constant PATH_WINUTIL ([String]"$env:ProgramData\WinUtil")
::Set-Variable -Option Constant PATH_OOSHUTUP10 ([String]"$env:ProgramData\OOShutUp10++")
::
::
::Set-Variable -Option Constant IS_LAPTOP ([Bool]((Get-CimInstance -Class Win32_ComputerSystem -Property PCSystemType).PCSystemType -eq 2))
::Set-Variable -Option Constant SYSTEM_LANGUAGE ([String](Get-SystemLanguage))
::
::
::Set-Variable -Option Constant WordRegPath ([String]'Registry::HKEY_CLASSES_ROOT\Word.Application\CurVer')
::if (Test-Path $WordRegPath) {
::    Set-Variable -Option Constant WordPath ([PSObject](Get-ItemProperty $WordRegPath))
::    Set-Variable -Option Constant OFFICE_VERSION ([String]($WordPath.'(default)' -replace '\D+', ''))
::
::    if (Test-Path $PATH_OFFICE_C2R_CLIENT_EXE) {
::        Set-Variable -Option Constant OFFICE_INSTALL_TYPE ([String]'C2R')
::    } else {
::        Set-Variable -Option Constant OFFICE_INSTALL_TYPE ([String]'MSI')
::    }
::}
::
::#endregion init > Initialization
::
::
::#region init > UI constants
::
::Set-Variable -Option Constant BUTTON_WIDTH ([Int]170)
::Set-Variable -Option Constant BUTTON_HEIGHT ([Int]30)
::
::Set-Variable -Option Constant CHECKBOX_HEIGHT ([Int]($BUTTON_HEIGHT - 10))
::
::
::Set-Variable -Option Constant INTERVAL_BUTTON ([Int]($BUTTON_HEIGHT + 15))
::
::Set-Variable -Option Constant INTERVAL_CHECKBOX ([Int]($CHECKBOX_HEIGHT + 5))
::
::
::Set-Variable -Option Constant GROUP_WIDTH ([Int](15 + $BUTTON_WIDTH + 15))
::
::Set-Variable -Option Constant FORM_WIDTH ([Int](($GROUP_WIDTH + 15) * 3 + 30))
::Set-Variable -Option Constant FORM_HEIGHT ([Int]590)
::
::Set-Variable -Option Constant INITIAL_LOCATION_BUTTON ([Drawing.Point]'15, 20')
::
::Set-Variable -Option Constant SHIFT_CHECKBOX ([Drawing.Point]"0, $INTERVAL_CHECKBOX")
::
::
::Set-Variable -Option Constant FONT_NAME ([String]'Microsoft Sans Serif')
::Set-Variable -Option Constant BUTTON_FONT ([Drawing.Font]"$FONT_NAME, 10")
::
::
::Set-Variable -Option Constant ICON_DEFAULT ([Drawing.Icon]::ExtractAssociatedIcon("$PATH_SYSTEM_32\cliconfg.exe"))
::Set-Variable -Option Constant ICON_CLEANUP ([Drawing.Icon]::ExtractAssociatedIcon("$PATH_SYSTEM_32\cleanmgr.exe"))
::Set-Variable -Option Constant ICON_DOWNLOAD ([Drawing.Icon]::ExtractAssociatedIcon("$PATH_SYSTEM_32\Dxpserver.exe"))
::
::#endregion init > UI constants
::
::
::#region components > Button
::
::function New-Button {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Text,
::        [ScriptBlock][Parameter(Position = 1)]$Function,
::        [Switch]$Disabled
::    )
::
::    Set-Variable -Option Constant Button ([Windows.Forms.Button](New-Object Windows.Forms.Button))
::
::    [Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [Drawing.Point]$Shift = '0, 0'
::
::    if ($PREVIOUS_LABEL_OR_CHECKBOX -or $PREVIOUS_RADIO) {
::        if ($PREVIOUS_LABEL_OR_CHECKBOX) {
::            Set-Variable -Option Constant PreviousLabelOrCheckboxY ([Int]$PREVIOUS_LABEL_OR_CHECKBOX.Location.Y)
::        } else {
::            Set-Variable -Option Constant PreviousLabelOrCheckboxY ([Int]0)
::        }
::
::        if ($PREVIOUS_RADIO) {
::            Set-Variable -Option Constant PreviousRadioY ([Int]$PREVIOUS_RADIO.Location.Y)
::        } else {
::            Set-Variable -Option Constant PreviousRadioY ([Int]0)
::        }
::
::        if ($PreviousLabelOrCheckboxY -gt $PreviousRadioY) {
::            Set-Variable -Option Constant PreviousMiscElement ([Int]$PreviousLabelOrCheckboxY)
::        } else {
::            Set-Variable -Option Constant PreviousMiscElement ([Int]$PreviousRadioY)
::        }
::
::        $InitialLocation.Y = $PreviousMiscElement
::        $Shift = '0, 30'
::    } elseif ($PREVIOUS_BUTTON) {
::        $InitialLocation = $PREVIOUS_BUTTON.Location
::        $Shift = "0, $INTERVAL_BUTTON"
::    }
::
::    [Drawing.Point]$Location = $InitialLocation + $Shift
::
::    $Button.Font = $BUTTON_FONT
::    $Button.Height = $BUTTON_HEIGHT
::    $Button.Width = $BUTTON_WIDTH
::    $Button.Enabled = -not $Disabled
::    $Button.Location = $Location
::
::    $Button.Text = $Text
::
::    if ($Function) {
::        $Button.Add_Click($Function)
::    }
::
::    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_BUTTON
::    $CURRENT_GROUP.Controls.Add($Button)
::
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
::    Set-Variable -Scope Script PREVIOUS_RADIO $Null
::    Set-Variable -Scope Script PREVIOUS_BUTTON ([Windows.Forms.Button]$Button)
::}
::
::#endregion components > Button
::
::
::#region components > ButtonBrowser
::
::function New-ButtonBrowser {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Text,
::        [ScriptBlock][Parameter(Position = 1, Mandatory)]$Function
::    )
::
::    New-Button $Text $Function
::
::    New-Label 'Open in a browser'
::}
::
::#endregion components > ButtonBrowser
::
::
::#region components > CheckBox
::
::function New-CheckBox {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Text,
::        [String][Parameter(Position = 1)]$Name,
::        [Switch]$Disabled,
::        [Switch]$Checked
::    )
::
::    Set-Variable -Option Constant CheckBox ([Windows.Forms.CheckBox](New-Object Windows.Forms.CheckBox))
::
::    [Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [Drawing.Point]$Shift = '0, 0'
::
::    if ($PREVIOUS_BUTTON) {
::        $InitialLocation = $PREVIOUS_BUTTON.Location
::        $Shift = "$INTERVAL_CHECKBOX, 30"
::    }
::
::    if ($PREVIOUS_LABEL_OR_CHECKBOX) {
::        $InitialLocation.Y = $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y
::
::        if ($PAD_CHECKBOXES) {
::            $Shift = "$INTERVAL_CHECKBOX, $CHECKBOX_HEIGHT"
::        } else {
::            $Shift = "0, $INTERVAL_CHECKBOX"
::        }
::    }
::
::    [Drawing.Point]$Location = $InitialLocation + $Shift
::
::    $CheckBox.Text = $Text
::    $CheckBox.Name = $Name
::    $CheckBox.Checked = $Checked
::    $CheckBox.Enabled = -not $Disabled
::    $CheckBox.Size = "175, $CHECKBOX_HEIGHT"
::    $CheckBox.Location = $Location
::
::    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
::    $CURRENT_GROUP.Controls.Add($CheckBox)
::
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX ([Windows.Forms.CheckBox]$CheckBox)
::
::    return $CheckBox
::}
::
::#endregion components > CheckBox
::
::
::#region components > CheckBoxRunAfterDownload
::
::function New-CheckBoxRunAfterDownload {
::    param(
::        [Switch]$Disabled,
::        [Switch]$Checked
::    )
::
::    return New-CheckBox 'Start after download' -Disabled:$Disabled -Checked:$Checked
::}
::
::#endregion components > CheckBoxRunAfterDownload
::
::
::#region components > GroupBox
::
::function New-GroupBox {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Text,
::        [Int][Parameter(Position = 1)]$IndexOverride
::    )
::
::    Set-Variable -Option Constant GroupBox ([Windows.Forms.GroupBox](New-Object Windows.Forms.GroupBox))
::
::    Set-Variable -Scope Script PREVIOUS_GROUP ([Windows.Forms.GroupBox]$CURRENT_GROUP)
::    Set-Variable -Scope Script PAD_CHECKBOXES ([Bool]$True)
::
::    [Int]$GroupIndex = 0
::
::    if ($IndexOverride) {
::        $GroupIndex = $IndexOverride
::    } else {
::        $CURRENT_TAB.Controls | ForEach-Object { $GroupIndex += $_.Count }
::    }
::
::    if ($GroupIndex -lt 3) {
::        if ($GroupIndex -eq 0) {
::            Set-Variable -Option Constant Location ([Drawing.Point]'15, 15')
::        } else {
::            Set-Variable -Option Constant Location ($PREVIOUS_GROUP.Location + [Drawing.Point]"$($GROUP_WIDTH + 15), 0")
::        }
::    } else {
::        Set-Variable -Option Constant PreviousGroup $CURRENT_TAB.Controls[$GroupIndex - 3]
::        Set-Variable -Option Constant Location ($PreviousGroup.Location + [Drawing.Point]"0, $($PreviousGroup.Height + 15)")
::    }
::
::    $GroupBox.Width = $GROUP_WIDTH
::    $GroupBox.Text = $Text
::    $GroupBox.Location = $Location
::
::    $CURRENT_TAB.Controls.Add($GroupBox)
::
::    Set-Variable -Scope Script PREVIOUS_BUTTON $Null
::    Set-Variable -Scope Script PREVIOUS_RADIO $Null
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
::
::    Set-Variable -Scope Script CURRENT_GROUP $GroupBox
::}
::
::#endregion components > GroupBox
::
::
::#region components > Label
::
::function New-Label {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Text
::    )
::
::    Set-Variable -Option Constant Label ([Windows.Forms.Label](New-Object Windows.Forms.Label))
::
::    Set-Variable -Option Constant Location ([Drawing.Point]$PREVIOUS_BUTTON.Location + [Drawing.Point]"40, $BUTTON_HEIGHT")
::
::    $Label.Size = "145, $CHECKBOX_HEIGHT"
::    $Label.Text = $Text
::    $Label.Location = $Location
::
::    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
::    $CURRENT_GROUP.Controls.Add($Label)
::
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX ([Windows.Forms.Label]$Label)
::}
::
::#endregion components > Label
::
::
::#region components > RadioButton
::
::function New-RadioButton {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Text,
::        [Switch]$Checked,
::        [Switch]$Disabled
::    )
::
::    Set-Variable -Option Constant RadioButton ([Windows.Forms.RadioButton](New-Object Windows.Forms.RadioButton))
::
::    [Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [Drawing.Point]$Shift = '0, 0'
::
::    if ($PREVIOUS_RADIO) {
::        $InitialLocation.X = $PREVIOUS_BUTTON.Location.X
::        $InitialLocation.Y = $PREVIOUS_RADIO.Location.Y
::        $Shift = '90, 0'
::    } elseif ($PREVIOUS_LABEL_OR_CHECKBOX) {
::        $InitialLocation = $PREVIOUS_LABEL_OR_CHECKBOX.Location
::        $Shift = '-15, 20'
::    } elseif ($PREVIOUS_BUTTON) {
::        $InitialLocation = $PREVIOUS_BUTTON.Location
::        $Shift = "10, $BUTTON_HEIGHT"
::    }
::
::    [Drawing.Point]$Location = $InitialLocation + $Shift
::
::    $RadioButton.Text = $Text
::    $RadioButton.Checked = $Checked
::    $RadioButton.Enabled = -not $Disabled
::    $RadioButton.Size = "80, $CHECKBOX_HEIGHT"
::    $RadioButton.Location = $Location
::
::    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
::    $CURRENT_GROUP.Controls.Add($RadioButton)
::
::    Set-Variable -Scope Script PREVIOUS_RADIO ([Windows.Forms.RadioButton]$RadioButton)
::
::    return $RadioButton
::}
::
::#endregion components > RadioButton
::
::
::#region components > TabPage
::
::function New-TabPage {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Text
::    )
::
::    Set-Variable -Option Constant TabPage ([Windows.Forms.TabPage](New-Object Windows.Forms.TabPage))
::
::    $TabPage.UseVisualStyleBackColor = $True
::    $TabPage.Text = $Text
::
::    $TAB_CONTROL.Controls.Add($TabPage)
::
::    Set-Variable -Scope Script PREVIOUS_GROUP $Null
::    Set-Variable -Scope Script CURRENT_TAB ([Windows.Forms.TabPage]$TabPage)
::}
::
::#endregion components > TabPage
::
::
::#region ui > Form
::
::Set-Variable -Option Constant FORM ([Windows.Forms.Form](New-Object Windows.Forms.Form))
::$FORM.Text = $HOST.UI.RawUI.WindowTitle
::$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
::$FORM.Icon = $ICON_DEFAULT
::$FORM.FormBorderStyle = 'Fixed3D'
::$FORM.StartPosition = 'CenterScreen'
::$FORM.MaximizeBox = $False
::$FORM.Top = $True
::$FORM.Add_Shown( { Initialize-App } )
::$FORM.Add_FormClosing( { Reset-State } )
::
::
::Set-Variable -Option Constant LOG ([Windows.Forms.RichTextBox](New-Object Windows.Forms.RichTextBox))
::$LOG.Height = 200
::$LOG.Width = $FORM_WIDTH - 10
::$LOG.Location = "5, $($FORM_HEIGHT - $LOG.Height - 5)"
::$LOG.Font = "$FONT_NAME, 9"
::$LOG.ReadOnly = $True
::$FORM.Controls.Add($LOG)
::
::
::Set-Variable -Option Constant TAB_CONTROL ([Windows.Forms.TabControl](New-Object Windows.Forms.TabControl))
::$TAB_CONTROL.Size = "$($LOG.Width + 1), $($FORM_HEIGHT - $LOG.Height - 1)"
::$TAB_CONTROL.Location = '5, 5'
::$FORM.Controls.Add($TAB_CONTROL)
::
::#endregion ui > Form
::
::
::#region ui > Home > Tab
::
::Set-Variable -Option Constant TAB_HOME ([Windows.Forms.TabPage](New-TabPage 'Home'))
::
::#endregion ui > Home > Tab
::
::
::#region ui > Home > Updates
::
::New-GroupBox 'Updates'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Update-Windows }
::New-Button 'Windows update' $BUTTON_FUNCTION
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Update-MicrosoftStoreApps }
::New-Button 'Microsoft Store updates' $BUTTON_FUNCTION
::
::
::[Switch]$BUTTON_DISABLED = $OFFICE_INSTALL_TYPE -ne 'C2R'
::[ScriptBlock]$BUTTON_FUNCTION = { Update-MicrosoftOffice }
::New-Button 'Microsoft Office updates' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
::
::#endregion ui > Home > Updates
::
::
::#region ui > Home > Activation
::
::New-GroupBox 'Activation'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-Activator -ActivateWindows:$CHECKBOX_ActivateWindows.Checked -ActivateOffice:$CHECKBOX_ActivateOffice.Checked }
::New-Button 'MAS Activator' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_ActivateWindows = New-CheckBox 'Activate Windows'
::
::[Windows.Forms.CheckBox]$CHECKBOX_ActivateOffice = New-CheckBox 'Activate Office'
::
::#endregion ui > Home > Activation
::
::
::#region ui > Home > Bootable USB tools
::
::New-GroupBox 'Bootable USB tools'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = {
::    Set-Variable -Option Constant FileName $((Split-Path -Leaf 'https://github.com/ventoy/Ventoy/releases/download/v1.1.10/ventoy-1.1.10-windows.zip').Replace('-windows', ''))
::    Start-DownloadUnzipAndRun 'https://github.com/ventoy/Ventoy/releases/download/v1.1.10/ventoy-1.1.10-windows.zip' $FileName -Execute:$CHECKBOX_StartVentoy.Checked
::}
::New-Button 'Ventoy' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Checked
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun 'https://github.com/pbatard/rufus/releases/download/v4.12/rufus-4.12p.exe' -Execute:$CHECKBOX_StartRufus.Checked -Params '-g' }
::New-Button 'Rufus' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Checked
::
::#endregion ui > Home > Bootable USB tools
::
::
::#region ui > Home > Cleanup
::
::New-GroupBox 'Cleanup'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-Cleanup }
::New-Button 'Run cleanup' $BUTTON_FUNCTION
::
::#endregion ui > Home > Cleanup
::
::
::#region ui > Home > Hardware info
::
::New-GroupBox 'Hardware info'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun 'https://download.cpuid.com/cpu-z/cpu-z_2.18-en.zip' -Execute:$CHECKBOX_StartCpuZ.Checked }
::New-Button 'CPU-Z' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartCpuZ = New-CheckBoxRunAfterDownload -Checked
::
::#endregion ui > Home > Hardware info
::
::
::#region ui > Installs > Tab
::
::Set-Variable -Option Constant TAB_INSTALLS ([Windows.Forms.TabPage](New-TabPage 'Installs'))
::
::#endregion ui > Installs > Tab
::
::
::#region ui > Installs > Ninite
::
::New-GroupBox 'Ninite'
::
::[Switch]$PAD_CHECKBOXES = $False
::
::
::[Windows.Forms.CheckBox]$CHECKBOX_Ninite_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
::[Windows.Forms.CheckBox]$CHECKBOX_Ninite_Firefox = New-CheckBox 'Mozilla Firefox' -Name 'firefox' -Checked
::[Windows.Forms.CheckBox]$CHECKBOX_Ninite_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
::[Windows.Forms.CheckBox]$CHECKBOX_Ninite_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
::[Windows.Forms.CheckBox]$CHECKBOX_Ninite_AnyDesk = New-CheckBox 'AnyDesk' -Name 'anydesk' -Checked
::[Windows.Forms.CheckBox]$CHECKBOX_Ninite_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
::[Windows.Forms.CheckBox]$CHECKBOX_Ninite_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Get-NiniteInstaller -OpenInBrowser:(-not $CHECKBOX_StartNinite.Enabled) -Execute:$CHECKBOX_StartNinite.Checked }
::New-Button 'Download selected' $BUTTON_FUNCTION
::
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked
::
::[ScriptBlock]$BUTTON_FUNCTION = { Get-NiniteInstaller -OpenInBrowser }
::New-ButtonBrowser 'View other' $BUTTON_FUNCTION
::
::
::Set-Variable -Option Constant NINITE_CHECKBOXES (
::    [Windows.Forms.CheckBox[]]@(
::        $CHECKBOX_Ninite_7zip,
::        $CHECKBOX_Ninite_VLC,
::        $CHECKBOX_Ninite_AnyDesk,
::        $CHECKBOX_Ninite_Chrome,
::        $CHECKBOX_Ninite_Firefox,
::        $CHECKBOX_Ninite_qBittorrent,
::        $CHECKBOX_Ninite_Malwarebytes
::    )
::)
::
::foreach ($Checkbox in $NINITE_CHECKBOXES) {
::    $Checkbox.Add_CheckStateChanged( { Set-NiniteButtonState } )
::}
::
::#endregion ui > Installs > Ninite
::
::
::#region ui > Installs > Essentials
::
::New-GroupBox 'Essentials'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun 'https://driveroff.net/drv/SDI_1.26.0.7z' -Execute:$CHECKBOX_StartSDI.Checked -ConfigFile 'sdi.cfg' -Configuration $CONFIG_SDI }
::New-Button 'Snappy Driver Installer' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Checked
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Install-MicrosoftOffice -Execute:$CHECKBOX_StartOfficeInstaller.Checked }
::New-Button 'Office Installer' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartOfficeInstaller = New-CheckBoxRunAfterDownload -Checked
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Install-Unchecky -Execute:$CHECKBOX_StartUnchecky.Checked -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked }
::New-Button 'Unchecky' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Checked
::$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
::        Set-CheckboxState -Control $CHECKBOX_StartUnchecky -Dependant $CHECKBOX_SilentlyInstallUnchecky
::    } )
::
::[Windows.Forms.CheckBox]$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Checked
::
::#endregion ui > Installs > Essentials
::
::
::#region ui > Installs > Windows images
::
::New-GroupBox 'Windows images'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser 'https://uztracker.net/viewtopic.php?t=40164' }
::New-ButtonBrowser 'Windows 11' $BUTTON_FUNCTION
::
::[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser 'https://w17.monkrus.ws/2022/11/windows-10-v22h2-rus-eng-x86-x64-32in1.html' }
::New-ButtonBrowser 'Windows 10' $BUTTON_FUNCTION
::
::[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser 'https://pb.wtf/t/398282' }
::New-ButtonBrowser 'Windows 7' $BUTTON_FUNCTION
::
::#endregion ui > Installs > Windows images
::
::
::#region ui > Configuration > Tab
::
::Set-Variable -Option Constant TAB_CONFIGURATION ([Windows.Forms.TabPage](New-TabPage 'Configuration'))
::
::#endregion ui > Configuration > Tab
::
::
::#region ui > Configuration > Apps configuration
::
::New-GroupBox 'Apps configuration'
::
::[Switch]$PAD_CHECKBOXES = $False
::
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_7zip = New-CheckBox '7-Zip' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_VLC = New-CheckBox 'VLC' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_AnyDesk = New-CheckBox 'AnyDesk' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_qBittorrent = New-CheckBox 'qBittorrent' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_Edge = New-CheckBox 'Microsoft Edge' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_Chrome = New-CheckBox 'Google Chrome' -Checked
::
::
::Set-Variable -Option Constant AppsConfigurationParameters (
::    [Hashtable]@{
::        '7zip'      = $CHECKBOX_Config_7zip
::        VLC         = $CHECKBOX_Config_VLC
::        AnyDesk     = $CHECKBOX_Config_AnyDesk
::        qBittorrent = $CHECKBOX_Config_qBittorrent
::        Edge        = $CHECKBOX_Config_Edge
::        Chrome      = $CHECKBOX_Config_Chrome
::    }
::)
::
::[ScriptBlock]$BUTTON_FUNCTION = { Set-AppsConfiguration @AppsConfigurationParameters }
::New-Button 'Apply configuration' $BUTTON_FUNCTION
::
::#endregion ui > Configuration > Apps configuration
::
::
::#region ui > Configuration > Windows configuration
::
::New-GroupBox 'Windows configuration'
::
::[Switch]$PAD_CHECKBOXES = $False
::
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsSecurity = New-CheckBox 'Improve security' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPerformance = New-CheckBox 'Improve performance' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsBaseline = New-CheckBox 'Baseline configuration' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsAnnoyances = New-CheckBox 'Remove ads and annoyances' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPrivacy = New-CheckBox 'Telemetry and privacy' -Checked
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsLocalisation = New-CheckBox 'Keyboard layout; location'
::
::[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'
::
::
::Set-Variable -Option Constant WindowsConfigurationParameters (
::    [Hashtable]@{
::        Security        = $CHECKBOX_Config_WindowsSecurity
::        Performance     = $CHECKBOX_Config_WindowsPerformance
::        Baseline        = $CHECKBOX_Config_WindowsBaseline
::        Annoyances      = $CHECKBOX_Config_WindowsAnnoyances
::        Privacy         = $CHECKBOX_Config_WindowsPrivacy
::        Localisation    = $CHECKBOX_Config_WindowsLocalisation
::        Personalisation = $CHECKBOX_Config_WindowsPersonalisation
::    }
::)
::
::[ScriptBlock]$BUTTON_FUNCTION = { Set-WindowsConfiguration @WindowsConfigurationParameters }
::New-Button 'Apply configuration' $BUTTON_FUNCTION
::
::#endregion ui > Configuration > Windows configuration
::
::
::#region ui > Configuration > Configure and debloat Windows
::
::New-GroupBox 'Configure and debloat Windows'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-WindowsDebloat -UsePreset:$CHECKBOX_UseDebloatPreset.Checked -Personalisation:$CHECKBOX_DebloatAndPersonalise.Checked -Silent:$CHECKBOX_SilentlyRunDebloat.Checked }
::New-Button 'Windows 10/11 debloat' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_UseDebloatPreset = New-CheckBox 'Use custom preset' -Checked
::$CHECKBOX_UseDebloatPreset.Add_CheckStateChanged( {
::        Set-CheckboxState -Control $CHECKBOX_UseDebloatPreset -Dependant $CHECKBOX_SilentlyRunDebloat
::        Set-CheckboxState -Control $CHECKBOX_UseDebloatPreset -Dependant $CHECKBOX_DebloatAndPersonalise
::    } )
::
::[Windows.Forms.CheckBox]$CHECKBOX_DebloatAndPersonalise = New-CheckBox '+ Personalisation settings'
::
::[Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunDebloat = New-CheckBox 'Silently apply tweaks'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-WinUtil -Personalisation:$CHECKBOX_WinUtilPersonalisation.Checked -AutomaticallyApply:$CHECKBOX_AutomaticallyRunWinUtil.Checked }
::New-Button 'WinUtil' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_WinUtilPersonalisation = New-CheckBox '+ Personalisation settings'
::
::[Windows.Forms.CheckBox]$CHECKBOX_AutomaticallyRunWinUtil = New-CheckBox 'Auto apply tweaks'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-OoShutUp10 -Execute:$CHECKBOX_StartOoShutUp10.Checked -Silent:($CHECKBOX_StartOoShutUp10.Checked -and $CHECKBOX_SilentlyRunOoShutUp10.Checked) }
::New-Button 'OOShutUp10++ privacy' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartOoShutUp10 = New-CheckBoxRunAfterDownload -Checked
::$CHECKBOX_StartOoShutUp10.Add_CheckStateChanged( {
::        Set-CheckboxState -Control $CHECKBOX_StartOoShutUp10 -Dependant $CHECKBOX_SilentlyRunOoShutUp10
::    } )
::
::[Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunOoShutUp10 = New-CheckBox 'Silently apply tweaks'
::
::#endregion ui > Configuration > Configure and debloat Windows
::
::
::#region ui > Configuration > Alternative DNS
::
::New-GroupBox 'Alternative DNS'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Set-CloudFlareDNS -MalwareProtection:$CHECKBOX_CloudFlareAntiMalware.Checked -FamilyFriendly:$CHECKBOX_CloudFlareFamilyFriendly.Checked }
::New-Button 'Setup CloudFlare DNS' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
::$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( {
::        Set-CheckboxState -Control $CHECKBOX_CloudFlareAntiMalware -Dependant $CHECKBOX_CloudFlareFamilyFriendly
::    } )
::
::[Windows.Forms.CheckBox]$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'
::
::#endregion ui > Configuration > Alternative DNS
::
::
::#region ui > Diagnostics and recovery > Tab
::
::Set-Variable -Option Constant TAB_DIAGNOSTICS ([Windows.Forms.TabPage](New-TabPage 'Diagnostics and recovery'))
::
::#endregion ui > Diagnostics and recovery > Tab
::
::
::#region ui > Diagnostics and recovery > HDD diagnostics
::
::New-GroupBox 'HDD diagnostics'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun 'https://hdd.by/Victoria/Victoria537.zip' -Execute:$CHECKBOX_StartVictoria.Checked }
::New-Button 'Victoria' $BUTTON_FUNCTION
::
::[Windows.Forms.CheckBox]$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Checked
::
::#endregion ui > Diagnostics and recovery > HDD diagnostics
::
::
::#region ui > Diagnostics and recovery > Battery report
::
::New-GroupBox 'Battery report'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Get-BatteryReport }
::New-Button 'Get battery report' $BUTTON_FUNCTION -Disabled:(-not $IS_LAPTOP)
::
::#endregion ui > Diagnostics and recovery > Battery report
::
::
::#region ui > Diagnostics and recovery > Windows disinfection
::
::New-GroupBox 'Windows disinfection'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser 'https://github.com/bmrf/tron/blob/master/README.md#use' }
::New-ButtonBrowser 'Download TronScript' $BUTTON_FUNCTION
::
::#endregion ui > Diagnostics and recovery > Windows disinfection
::
::
::#region configs > Apps > 7zip
::
::Set-Variable -Option Constant CONFIG_7ZIP ([String]('[HKEY_CURRENT_USER\Software\7-Zip\FM]
::"AlternativeSelection"=dword:00000001
::"Columns\RootFolder"=hex:01,00,00,00,00,00,00,00,01,00,00,00,04,00,00,00,01,00,00,00,A0,00,00,00
::"FlatViewArc0"=dword:00000000
::"FlatViewArc1"=dword:00000000
::"FolderShortcuts"=""
::"FullRow"=dword:00000001
::"ListMode"=dword:00000303
::"PanelPath0"=""
::"PanelPath1"=""
::"Panels"=hex:02,00,00,00,00,00,00,00,BE,03,00,00
::"Position"=hex:B6,00,00,00,B6,00,00,00,56,06,00,00,49,03,00,00,01,00,00,00
::"ShowDots"=dword:00000001
::"ShowGrid"=dword:00000001
::"ShowRealFileIcons"=dword:00000001
::"ShowSystemMenu"=dword:00000001
::"SingleClick"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\7-Zip\Options]
::"ContextMenu"=dword:00001367
::"MenuIcons"=dword:00000001
::"WriteZoneIdExtract"=dword:00000001
::'))
::
::#endregion configs > Apps > 7zip
::
::
::#region configs > Apps > AnyDesk
::
::Set-Variable -Option Constant CONFIG_ANYDESK ([String]('ad.discovery.show_tile=0
::ad.image.show_remote_cursor_option=1
::ad.telemetry.consent=0,29497,0,0
::ad.ui.main_win.height=0
::ad.ui.main_win.max=true
::ad.ui.main_win.width=0
::ad.ui.main_win.x=-8
::ad.ui.main_win.y=-8
::ad.ui.show_tile.telemetry=false
::'))
::
::#endregion configs > Apps > AnyDesk
::
::
::#region configs > Apps > Chrome local state
::
::Set-Variable -Option Constant CONFIG_CHROME_LOCAL_STATE ([String]('{
::  "background_mode": {
::    "enabled": false
::  },
::  "browser": {
::    "first_run_finished": true
::  },
::  "dns_over_https": {
::    "mode": "secure",
::    "templates": "https://chrome.cloudflare-dns.com/dns-query"
::  },
::  "hardware_acceleration_mode_previous": true,
::  "os_update_handler_enabled": true,
::  "performance_tuning": {
::    "battery_saver_mode": {
::      "state": 0
::    }
::  }
::}
::'))
::
::#endregion configs > Apps > Chrome local state
::
::
::#region configs > Apps > Chrome preferences
::
::Set-Variable -Option Constant CONFIG_CHROME_PREFERENCES ([String]('{
::  "browser": {
::    "enable_spellchecking": true,
::    "window_placement": {
::      "maximized": true,
::      "work_area_left": 0,
::      "work_area_top": 0
::    }
::  },
::  "default_search_provider_data": {
::    "mirrored_template_url_data": {
::      "preconnect_to_search_url": true,
::      "prefetch_likely_navigations": true
::    }
::  },
::  "enable_do_not_track": true,
::  "https_first_balanced_mode_enabled": false,
::  "https_only_mode_auto_enabled": false,
::  "https_only_mode_enabled": true,
::  "intl": {
::    "accept_languages": "lv,ru,en-GB",
::    "selected_languages": "lv,ru,en-GB"
::  },
::  "net": {
::    "network_prediction_options": 3
::  },
::  "privacy_sandbox": {
::    "m1": {
::      "ad_measurement_enabled": false,
::      "consent_decision_made": true,
::      "eea_notice_acknowledged": true,
::      "fledge_enabled": false,
::      "topics_enabled": true
::    }
::  },
::  "safebrowsing": {
::    "enabled": true,
::    "enhanced": true
::  },
::  "spellcheck": {
::    "dictionaries": ["lv", "ru", "en-GB"],
::    "use_spelling_service": true
::  }
::}
::'))
::
::#endregion configs > Apps > Chrome preferences
::
::
::#region configs > Apps > Edge local state
::
::Set-Variable -Option Constant CONFIG_EDGE_LOCAL_STATE ([String]('{
::  "background_mode": {
::    "enabled": false
::  },
::  "edge": {
::    "perf_center": {
::      "efficiency_mode_toggle": false,
::      "efficiency_mode_v2_is_active": false,
::      "perf_game_mode": false,
::      "perf_game_mode_default_changed": true,
::      "performance_mode": 3,
::      "performance_mode_is_on": false
::    }
::  },
::  "fre": {
::    "has_first_visible_browser_session_completed": true,
::    "has_user_committed_selection_to_import_during_fre": false,
::    "has_user_completed_fre": false,
::    "has_user_seen_fre": true,
::    "oem_bookmarks_set": true
::  },
::  "new_device_fre": {
::    "has_user_seen_new_fre": true
::  },
::  "smartscreen": {
::    "enabled": true,
::    "pua_protection_enabled": true
::  },
::  "startup_boost": {
::    "enabled": false
::  },
::  "user_experience_metrics": {
::    "reporting_enabled": false
::  }
::}
::'))
::
::#endregion configs > Apps > Edge local state
::
::
::#region configs > Apps > Edge preferences
::
::Set-Variable -Option Constant CONFIG_EDGE_PREFERENCES ([String]('{
::  "browser": {
::    "editor_proofing_languages": {
::      "en-GB": {
::        "Grammar": true,
::        "Spelling": true
::      },
::      "lv": {
::        "Grammar": true,
::        "Spelling": true
::      },
::      "ru": {
::        "Grammar": true,
::        "Spelling": true
::      }
::    },
::    "enable_editor_proofing": true,
::    "enable_text_prediction_v2": true,
::    "show_hub_apps_tower_pinned": false,
::    "show_hubapps_personalization": false,
::    "show_prompt_before_closing_tabs": true,
::    "show_sidebar_notification": false,
::    "window_placement": {
::      "maximized": true,
::      "work_area_left": 0,
::      "work_area_top": 0
::    }
::  },
::  "edge": {
::    "sleeping_tabs": {
::      "enabled": false,
::      "fade_tabs": false,
::      "threshold": 43200
::    },
::    "super_duper_secure_mode": {
::      "enabled": true,
::      "state": 1,
::      "strict_inprivate": true
::    }
::  },
::  "enhanced_tracking_prevention": {
::    "user_pref": 3
::  },
::  "https_only_mode_auto_enabled": false,
::  "https_only_mode_enabled": true,
::  "instrumentation": {
::    "ntp": {
::      "layout_mode": "updateLayout;3;1758293358211",
::      "news_feed_display": "updateFeeds;off;1758293358217"
::    }
::  },
::  "intl": {
::    "accept_languages": "lv,ru,en-GB",
::    "selected_languages": "lv,ru,en-GB"
::  },
::  "local_browser_data_share": {
::    "pin_recommendations_eligible": false
::  },
::  "ntp": {
::    "background_image": {
::      "provider": "NoBackground",
::      "userSelected": true
::    },
::    "background_image_type": "off",
::    "hide_default_top_sites": true,
::    "layout_mode": 3,
::    "news_feed_display": "off",
::    "next_site_suggestions_available": false,
::    "num_personal_suggestions": 0,
::    "quick_links_options": 0,
::    "record_user_choices": [
::      {
::        "setting": "layout_mode",
::        "source": "ntp",
::        "value": 3
::      },
::      {
::        "setting": "ntp.news_feed_display",
::        "source": "ntp",
::        "value": "off"
::      },
::      {
::        "setting": "tscollapsed",
::        "source": "updatePrefTSCollapsed",
::        "value": 0
::      },
::      {
::        "setting": "quick_links_options",
::        "source": "ntp",
::        "value": "off"
::      }
::    ],
::    "show_image_of_day": false
::  },
::  "personalization_data_consent": {
::    "personalization_in_context_consent_can_prompt": false
::  },
::  "profile": {
::    "has_seen_signin_fre": true
::  },
::  "shopping": {
::    "contextual_features_enabled": false
::  },
::  "spellcheck": {
::    "dictionaries": ["lv", "ru", "en-GB"]
::  },
::  "user_experience_metrics": {
::    "personalization_data_consent_enabled": false,
::    "personalization_data_consent_enabled_last_known_value": false
::  },
::  "video_enhancement": {
::    "enabled": true
::  }
::}
::'))
::
::#endregion configs > Apps > Edge preferences
::
::
::#region configs > Apps > Microsoft Office
::
::Set-Variable -Option Constant CONFIG_MICROSOFT_OFFICE ([String]('[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\General]
::"ShownFirstRunOptin"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\Licensing]
::"EulasSetAccepted"="0,49,"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\LinkedIn]
::"OfficeLinkedIn"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\Privacy\SettingsStore\Anonymous]
::"OptionalConnectedExperiencesNoticeVersion"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\Common]
::"LinkedIn"=dword:00000000
::"QMEnable"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\Common\Feedback]
::"Enabled"=dword:00000000
::"IncludeEmail"=dword:00000000
::"SurveyEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\osm]
::"EnableFileObfuscation"=dword:00000001
::"Enablelogging"=dword:00000000
::"EnableUpload"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\Common\ClientTelemetry]
::"DisableTelemetry"=dword:00000001
::"SendTelemetry"=dword:00000003
::'))
::
::#endregion configs > Apps > Microsoft Office
::
::
::#region configs > Apps > qBittorrent base
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_BASE ([String]('[Appearance]
::Style=Fusion
::
::[Application]
::GUI\Notifications\TorrentAdded=false
::
::[BitTorrent]
::MergeTrackersEnabled=true
::Session\AddExtensionToIncompleteFiles=true
::Session\GlobalMaxRatio=0
::Session\GlobalMaxSeedingMinutes=0
::Session\IDNSupportEnabled=true
::Session\IgnoreSlowTorrentsForQueueing=true
::Session\IncludeOverheadInLimits=true
::Session\MaxActiveDownloads=2
::Session\MaxActiveUploads=1
::Session\PerformanceWarning=true
::Session\PieceExtentAffinity=true
::Session\QueueingSystemEnabled=true
::Session\ReannounceWhenAddressChanged=true
::Session\RefreshInterval=1000
::Session\SaveResumeDataInterval=1
::Session\SaveStatisticsInterval=5
::Session\ShareLimitAction=Remove
::Session\SlowTorrentsDownloadRate=1024
::Session\StartPaused=false
::Session\SuggestMode=true
::Session\TorrentStopCondition=FilesChecked
::TrackerEnabled=true
::
::[Core]
::AutoDeleteAddedTorrentFile=Never
::
::[LegalNotice]
::Accepted=true
::
::[MainWindow]
::geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\xff\xff\xff\xf8\0\0\a\x7f\0\0\x3\x8a\0\0\x1\xf7\0\0\0\xbb\0\0\x5\x88\0\0\x2\xed\0\0\0\0\x2\0\0\0\a\x80\0\0\0\0\0\0\0\x17\0\0\a\x7f\0\0\x3\x8a)
::
::[Meta]
::MigrationVersion=8
::
::[OptionsDialog]
::HorizontalSplitterSizes=197, 1032
::LastViewedPage=0
::Size=@Size(1255 829)
::
::[SpeedWidget]
::graph_enable_2=true
::graph_enable_3=true
::graph_enable_4=true
::graph_enable_5=true
::graph_enable_6=true
::graph_enable_7=true
::graph_enable_8=true
::graph_enable_9=true
::period=0
::
::[TorrentProperties]
::CurrentTab=0
::SplitterSizes="71,719"
::Visible=true
::
::[Preferences]
::Advanced\RecheckOnCompletion=true
::Connection\ResolvePeerHostNames=true
::General\CloseToTray=false
::General\CloseToTrayNotified=true
::General\PreventFromSuspendWhenDownloading=true
::General\SpeedInTitleBar=true
::General\StatusbarExternalIPDisplayed=true
::General\SystrayEnabled=false
::'))
::
::#endregion configs > Apps > qBittorrent base
::
::
::#region configs > Apps > qBittorrent English
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_ENGLISH ([String]('General\Locale=en_GB
::
::[GUI]
::DownloadTrackerFavicon=true
::MainWindow\FiltersSidebarWidth=155
::Qt6\TorrentProperties\FilesListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x6\xd1\0\0\0\x6\x1\x1\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\x6\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0\x7f\0\0\0\x1\0\0\0\0\0\0\0U\0\0\0\x1\0\0\0\0\0\0\x5)\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0W\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TorrentProperties\PeerListState=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\xf\0@\0\0\0\x1\0\0\0\xe\0\0\0\x64\0\0\x4Y\0\0\0\xf\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\xf\0\0\0r\0\0\0\x1\0\0\0\0\0\0\0V\0\0\0\x1\0\0\0\0\0\0\0\x32\0\0\0\x1\0\0\0\0\0\0\0Y\0\0\0\x1\0\0\0\0\0\0\0\x35\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0g\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0\x61\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0`\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0T\0\0\0\x1\0\0\0\0\0\0\0\x32\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)
::Qt6\TorrentProperties\TrackerListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x3\xce\0\0\0\v\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\v\0\0\0\xa2\0\0\0\x1\0\0\0\0\0\0\0\x30\0\0\0\x1\0\0\0\0\0\0\0[\0\0\0\x1\0\0\0\0\0\0\0=\0\0\0\x1\0\0\0\0\0\0\0\x39\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0G\0\0\0\x1\0\0\0\0\0\0\0\x84\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0q\0\0\0\x1\0\0\0\0\0\0\0j\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TransferList\HeaderState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0%\0\xf8\x8f\x66\x1f\0\0\0\x13\0\0\0!\0\0\0\x64\0\0\0\x10\0\0\0\x64\0\0\0\v\0\0\0\x64\0\0\0$\0\0\0\x64\0\0\0\x11\0\0\0\x64\0\0\0\x1e\0\0\0\x64\0\0\0\x13\0\0\0\x64\0\0\0\"\0\0\0\x64\0\0\0\x19\0\0\0\x64\0\0\0\r\0\0\0\x64\0\0\0\x1d\0\0\0\x64\0\0\0\x1a\0\0\0\x64\0\0\0\xe\0\0\0\x64\0\0\0\x12\0\0\0\x64\0\0\0\x17\0\0\0\x64\0\0\0\f\0\0\0\x64\0\0\0\xf\0\0\0\x64\0\0\0#\0\0\0\x64\0\0\0 \0\0\0\x64\0\0\x5<\0\0\0%\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0%\0\0\0!\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0\x31\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0=\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0\x39\0\0\0\x1\0\0\0\0\0\0\0\x61\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0.\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0`\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0~\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0U\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0V\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::StartUpWindowState=Normal
::'))
::
::#endregion configs > Apps > qBittorrent English
::
::
::#region configs > Apps > qBittorrent Russian
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_RUSSIAN ([String]('General\Locale=ru
::
::[GUI]
::DownloadTrackerFavicon=true
::MainWindow\FiltersSidebarWidth=153
::Qt6\TorrentProperties\FilesListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x6\xd1\0\0\0\x6\x1\x1\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\x6\0\0\0\x33\0\0\0\x1\0\0\0\0\0\0\0r\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0\x8f\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\x4\xfe\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0P\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TorrentProperties\PeerListState=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\xf\0@\0\0\0\x1\0\0\0\xe\0\0\0\x64\0\0\x4:\0\0\0\xf\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\xf\0\0\0n\0\0\0\x1\0\0\0\0\0\0\0K\0\0\0\x1\0\0\0\0\0\0\0\x36\0\0\0\x1\0\0\0\0\0\0\0\x62\0\0\0\x1\0\0\0\0\0\0\0>\0\0\0\x1\0\0\0\0\0\0\0\x44\0\0\0\x1\0\0\0\0\0\0\0^\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0L\0\0\0\x1\0\0\0\0\0\0\0\x42\0\0\0\x1\0\0\0\0\0\0\0X\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0M\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)
::Qt6\TorrentProperties\TrackerListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x4\x19\0\0\0\v\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\v\0\0\0\xb9\0\0\0\x1\0\0\0\0\0\0\0K\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0<\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0q\0\0\0\x1\0\0\0\0\0\0\0^\0\0\0\x1\0\0\0\0\0\0\0]\0\0\0\x1\0\0\0\0\0\0\0~\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TransferList\HeaderState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0%\0\xf8\x8f\x66\x1f\0\0\0\x13\0\0\0\x11\0\0\0\x64\0\0\0\x12\0\0\0\x64\0\0\0\x10\0\0\0\x64\0\0\0\x1a\0\0\0\x64\0\0\0\x17\0\0\0\x64\0\0\0\v\0\0\0\x64\0\0\0\x1e\0\0\0\x64\0\0\0\x13\0\0\0\x64\0\0\0!\0\0\0\x64\0\0\0\x1d\0\0\0\x64\0\0\0 \0\0\0\x64\0\0\0\xf\0\0\0\x64\0\0\0$\0\0\0\x64\0\0\0\x19\0\0\0\x64\0\0\0\f\0\0\0\x64\0\0\0\"\0\0\0\x64\0\0\0\r\0\0\0\x64\0\0\0\xe\0\0\0\x64\0\0\0#\0\0\0\x64\0\0\x5\xfb\0\0\0%\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0%\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x33\0\0\0\x1\0\0\0\0\0\0\0\x44\0\0\0\x1\0\0\0\0\0\0\0\x65\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0<\0\0\0\x1\0\0\0\0\0\0\0L\0\0\0\x1\0\0\0\0\0\0\0\x42\0\0\0\x1\0\0\0\0\0\0\0_\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0X\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0\x8a\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0x\0\0\0\x1\0\0\0\0\0\0\0u\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::StartUpWindowState=Normal
::'))
::
::#endregion configs > Apps > qBittorrent Russian
::
::
::#region configs > Apps > VLC
::
::Set-Variable -Option Constant CONFIG_VLC ([String]('[qt]
::qt-system-tray=0
::qt-privacy-ask=0
::
::[core]
::video-title-show=0
::metadata-network-access=1
::'))
::
::#endregion configs > Apps > VLC
::
::
::#region configs > Installs > Office Installer
::
::Set-Variable -Option Constant CONFIG_OFFICE_INSTALLER ([String]('[Configurations]
::ArchR = 1
::CBBranch = 1
::DlndArch = 1
::langs = en-GB|lv-LV|
::NOSOUND = 1
::OnOff = 1
::PosR = 1
::ProofingTools = 0
::Access = 0
::Excel = 1
::Groove = 0
::Lync = 0
::OneDrive = 0
::OneNote = 0
::Outlook = 0
::PowerPoint = 1
::Project = 0
::ProjectMondo = 0
::ProjectPro = 0
::Publisher = 0
::Teams = 0
::Visio = 0
::VisioMondo = 0
::VisioPro = 0
::Word = 1
::'))
::
::#endregion configs > Installs > Office Installer
::
::
::#region configs > Windows > Annoyances
::
::Set-Variable -Option Constant CONFIG_ANNOYANCES ([String]('[HKEY_CURRENT_USER\Software\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64]
::@=""
::
::[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
::"ShowStartupPanel"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\General]
::"ShownFirstRunOptin"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\Licensing]
::"EulasSetAccepted"="0,49,"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\LinkedIn]
::"OfficeLinkedIn"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
::"ContentDeliveryAllowed"=dword:00000000
::"FeatureManagementEnabled"=dword:00000000
::"OemPreInstalledAppsEnabled"=dword:00000000
::"PreInstalledAppsEnabled"=dword:00000000
::"PreInstalledAppsEverEnabled"=dword:00000000
::"RotatingLockScreenEnabled"=dword:00000000
::"RotatingLockScreenOverlayEnabled"=dword:00000000 ; Get fun facts, tips and more from Windows and Cortana on your lock screen
::"RotatingLockScreenOverlayVisible"=dword:00000000
::"SilentInstalledAppsEnabled"=dword:00000000 ; Automatic Installation of Suggested Apps
::"SoftLandingEnabled"=dword:00000000 ; Get tips, tricks, and suggestions as you use Windows
::"SubscribedContent-202914Enabled"=dword:00000000
::"SubscribedContent-280815Enabled"=dword:00000000
::"SubscribedContent-310093Enabled"=dword:00000000 ; Show me the Windows welcome experience after updates and occasionally when I sign in to highlight what"s new and suggested
::"SubscribedContent-338387Enabled"=dword:00000000 ; Get fun facts, tips and more from Windows and Cortana on your lock screen
::"SubscribedContent-338388Enabled"=dword:00000000 ; Occasionally show suggestions in Start
::"SubscribedContent-338389Enabled"=dword:00000000 ; Get tips, tricks, and suggestions as you use Windows
::"SubscribedContent-338393Enabled"=dword:00000000
::"SubscribedContent-353694Enabled"=dword:00000000 ; Show me suggested content in the Settings app
::"SubscribedContent-353696Enabled"=dword:00000000 ; Show me suggested content in the Settings app
::"SubscribedContent-353698Enabled"=dword:00000000 ; Show me suggested content in the Settings app
::"SubscribedContent-88000045Enabled"=dword:00000000
::"SubscribedContent-88000161Enabled"=dword:00000000
::"SubscribedContent-88000163Enabled"=dword:00000000
::"SubscribedContent-88000165Enabled"=dword:00000000
::"SubscribedContentEnabled"=dword:00000000
::"SystemPaneSuggestionsEnabled"=dword:00000000 ; Occasionally show suggestions in Start
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack]
::"ShowedToastAtLevel"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
::"ShowRecommendations"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"ShowSyncProviderNotifications"=dword:00000000 ; Sync provider ads
::"Start_AccountNotifications"=dword:00000000 ; Disable Show account-related notifications
::"Start_IrisRecommendations"=dword:00000000 ; Show recommendations for tips, shortcuts, new apps, and more in start
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
::"{20D04FE0-3AEA-1069-A2D8-08002B30309D}"=dword:00000000
::"MSEdge"=dword:00000001
::
::; Disable Show me suggestions for using my mobile device with Windows (Phone Link suggestions)
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Mobility]
::"OptedIn"=dword:00000000
::
::; Disable Windows Backup reminder notifications
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackupReminder]
::"Enabled"=dword:00000000
::
::; Disable "Suggested" app notifications (Ads for MS services)
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested]
::"Enabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PenWorkspace]
::"PenWorkspaceAppSuggestionsEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
::"BingSearchEnabled"=dword:00000000 ; Disable Bing search
::"ConnectedSearchUseWeb"=dword:00000000
::"DisableWebSearch"=dword:00000001
::"SearchboxTaskbarMode"=dword:00000003 ; Show search icon and label
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
::"IsDynamicSearchBoxEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications]
::"EnableAccountNotifications"=dword:00000000
::
::; Suggest ways I can finish setting up my device to get the most out of Windows
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
::"ScOoBESystemSettingEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows Security Health\State]
::"AccountProtection_MicrosoftAccount_Disconnected"=dword:00000001
::"Hardware_DataEncryption_AddMsa"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\Common]
::"LinkedIn"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\Common\Feedback]
::"SurveyEnabled"=dword:00000000
::
::; Disable Bing in search
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
::"DisableSearchBoxSuggestions"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start]
::"HideRecommendedSection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
::"SecurityHealth"=hex:05,00,00,00,88,26,66,6D,84,2A,DC,01
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"AllowOnlineTips"=dword:00000000
::
::; Disable Windows Backup reminder notifications
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup]
::"DisableMonitoring"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\AU]
::"NoAutoRebootWithLoggedOnUsers"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection]
::"SummaryNotificationDisabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
::"AutoImportAtFirstRun"=dword:00000004
::"DefaultBrowserSettingEnabled"=dword:00000000
::"DefaultBrowserSettingsCampaignEnabled"=dword:00000000
::"HideFirstRunExperience"=dword:00000001
::"ShowPDFDefaultRecommendationsEnabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate]
::"CreateDesktopShortcutDefault"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent]
::"DisableConsumerAccountStateContent"=dword:00000001 ; Disable MS 365 Ads in Settings Home
::"DisableWindowsConsumerFeatures"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection]
::"DisableOneSettingsDownloads"=dword:00000001
::"DoNotShowFeedbackNotifications"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
::"HideRecommendedSection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate]
::"SetActiveHours"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services]
::"fAllowToGetHelp"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge]
::"AutoImportAtFirstRun"=dword:00000004
::"DefaultBrowserSettingEnabled"=dword:00000000
::"DefaultBrowserSettingsCampaignEnabled"=dword:00000000
::"HideFirstRunExperience"=dword:00000001
::"ShowPDFDefaultRecommendationsEnabled"=dword:00000000
::
::; Disable MS 365 Ads in Settings Home
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\CloudContent]
::"DisableConsumerAccountStateContent"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\DataCollection]
::"DisableOneSettingsDownloads"=dword:00000001
::"DoNotShowFeedbackNotifications"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Explorer]
::"HideRecommendedSection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows NT\Terminal Services]
::"fAllowToGetHelp"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance]
::"fAllowToGetHelp"=dword:00000000
::'))
::
::#endregion configs > Windows > Annoyances
::
::
::#region configs > Windows > Baseline English
::
::Set-Variable -Option Constant CONFIG_BASELINE_ENGLISH ([String]('[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\TaskManager]
::"Preferences"=hex:0d,00,00,00,60,00,00,00,60,00,00,00,9c,00,00,00,9c,00,00,00,\
::  17,02,00,00,10,02,00,00,00,00,00,00,00,00,00,80,00,00,00,80,d8,01,00,80,df,\
::  01,00,80,00,01,00,01,00,00,00,00,00,00,00,00,94,07,00,00,cf,03,00,00,f4,01,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,0f,00,00,00,01,00,00,00,00,00,00,\
::  00,20,34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,f0,01,00,00,\
::  1e,00,00,00,89,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,00,00,00,00,00,0d,\
::  00,00,00,00,00,00,00,60,34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,\
::  ff,ff,77,00,00,00,1e,00,00,00,8b,90,00,00,01,00,00,00,00,00,00,00,00,10,10,\
::  00,00,00,00,00,03,00,00,00,00,00,00,00,78,34,bf,43,f6,7f,00,00,00,00,00,00,\
::  00,00,00,00,ff,ff,ff,ff,5b,00,00,00,1e,00,00,00,8c,90,00,00,02,00,00,00,00,\
::  00,00,00,01,02,12,00,00,00,00,00,04,00,00,00,00,00,00,00,90,34,bf,43,f6,7f,\
::  00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,a4,00,00,00,1e,00,00,00,8d,90,00,\
::  00,03,00,00,00,00,00,00,00,00,01,10,00,00,00,00,00,02,00,00,00,00,00,00,00,\
::  b0,34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,24,00,00,00,1e,\
::  00,00,00,8a,90,00,00,04,00,00,00,00,00,00,00,00,08,20,00,00,00,00,00,05,00,\
::  00,00,00,00,00,00,c8,34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,\
::  ff,ab,00,00,00,1e,00,00,00,8e,90,00,00,05,00,00,00,00,00,00,00,00,01,10,00,\
::  00,00,00,00,06,00,00,00,00,00,00,00,f0,34,bf,43,f6,7f,00,00,00,00,00,00,00,\
::  00,00,00,ff,ff,ff,ff,ba,00,00,00,1e,00,00,00,8f,90,00,00,0e,00,00,00,00,00,\
::  00,00,00,01,10,00,00,00,00,00,07,00,00,00,00,00,00,00,18,35,bf,43,f6,7f,00,\
::  00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,90,90,00,00,\
::  06,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,08,00,00,00,00,00,00,00,48,\
::  34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,\
::  00,00,91,90,00,00,07,00,00,00,01,00,00,00,00,04,25,02,00,00,00,00,09,00,00,\
::  00,00,00,00,00,38,35,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,\
::  49,00,00,00,49,00,00,00,92,90,00,00,08,00,00,00,00,00,00,00,00,04,25,08,00,\
::  00,00,00,0a,00,00,00,00,00,00,00,50,35,bf,43,f6,7f,00,00,00,00,00,00,00,00,\
::  00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,93,90,00,00,09,00,00,00,00,00,00,\
::  00,00,04,25,08,00,00,00,00,0b,00,00,00,00,00,00,00,70,35,bf,43,f6,7f,00,00,\
::  00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,39,a0,00,00,0a,\
::  00,00,00,00,00,00,00,00,04,25,08,00,00,00,00,1c,00,00,00,00,00,00,00,90,35,\
::  bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,4c,00,00,00,49,00,00,\
::  00,3a,a0,00,00,0b,00,00,00,00,00,00,00,00,01,10,08,00,00,00,00,1d,00,00,00,\
::  00,00,00,00,b8,35,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,53,\
::  00,00,00,49,00,00,00,4c,a0,00,00,0c,00,00,00,00,00,00,00,00,02,15,08,00,00,\
::  00,00,1e,00,00,00,00,00,00,00,d8,35,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,\
::  00,ff,ff,ff,ff,73,00,00,00,49,00,00,00,4d,a0,00,00,0d,00,00,00,00,00,00,00,\
::  00,02,15,08,00,00,00,00,03,00,00,00,0a,00,00,00,01,00,00,00,00,00,00,00,20,\
::  34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,1d,01,00,00,1e,00,\
::  00,00,89,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,00,00,00,00,00,04,00,00,\
::  00,00,00,00,00,90,34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,01,00,00,00,\
::  93,00,00,00,1e,00,00,00,8d,90,00,00,01,00,00,00,00,00,00,00,01,01,10,00,00,\
::  00,00,00,03,00,00,00,00,00,00,00,78,34,bf,43,f6,7f,00,00,00,00,00,00,00,00,\
::  00,00,ff,ff,ff,ff,4c,00,00,00,1e,00,00,00,8c,90,00,00,02,00,00,00,00,00,00,\
::  00,00,02,10,00,00,00,00,00,0c,00,00,00,00,00,00,00,08,36,bf,43,f6,7f,00,00,\
::  00,00,00,00,00,00,00,00,03,00,00,00,76,00,00,00,1e,00,00,00,94,90,00,00,03,\
::  00,00,00,00,00,00,00,01,02,10,00,00,00,00,00,0d,00,00,00,00,00,00,00,30,36,\
::  bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,4e,00,00,00,1e,00,00,\
::  00,95,90,00,00,04,00,00,00,00,00,00,00,00,01,10,00,00,00,00,00,0e,00,00,00,\
::  00,00,00,00,58,36,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,05,00,00,00,cf,\
::  00,00,00,1e,00,00,00,96,90,00,00,05,00,00,00,01,00,00,00,01,04,20,00,00,00,\
::  00,00,0f,00,00,00,00,00,00,00,80,36,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,\
::  00,06,00,00,00,64,00,00,00,1e,00,00,00,97,90,00,00,06,00,00,00,01,00,00,00,\
::  01,04,20,02,00,00,00,00,10,00,00,00,00,00,00,00,a0,36,bf,43,f6,7f,00,00,00,\
::  00,00,00,00,00,00,00,07,00,00,00,7f,00,00,00,1e,00,00,00,98,90,00,00,07,00,\
::  00,00,00,00,00,00,01,01,10,00,00,00,00,00,11,00,00,00,00,00,00,00,c0,36,bf,\
::  43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,91,00,00,00,1e,00,00,00,\
::  99,90,00,00,08,00,00,00,00,00,00,00,00,01,10,00,00,00,00,00,06,00,00,00,00,\
::  00,00,00,f0,34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,09,00,00,00,19,01,\
::  00,00,1e,00,00,00,8f,90,00,00,09,00,00,00,00,00,00,00,01,01,10,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,04,00,00,00,0b,00,00,00,01,00,00,00,00,00,00,00,20,34,bf,\
::  43,f6,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,25,01,00,00,1e,00,00,00,\
::  9e,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,00,00,00,00,00,12,00,00,00,00,\
::  00,00,00,e8,36,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,2d,00,\
::  00,00,1e,00,00,00,9b,90,00,00,01,00,00,00,00,00,00,00,00,04,20,00,00,00,00,\
::  00,14,00,00,00,00,00,00,00,08,37,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,\
::  ff,ff,ff,ff,64,00,00,00,1e,00,00,00,9d,90,00,00,02,00,00,00,00,00,00,00,00,\
::  01,10,00,00,00,00,00,13,00,00,00,00,00,00,00,30,37,bf,43,f6,7f,00,00,00,00,\
::  00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,9c,90,00,00,03,00,00,\
::  00,00,00,00,00,00,01,10,00,00,00,00,00,03,00,00,00,00,00,00,00,78,34,bf,43,\
::  f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6f,00,00,00,1e,00,00,00,8c,\
::  90,00,00,04,00,00,00,00,00,00,00,01,02,10,00,00,00,00,00,07,00,00,00,00,00,\
::  00,00,18,35,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,05,00,00,00,49,00,00,\
::  00,49,00,00,00,90,90,00,00,05,00,00,00,00,00,00,00,01,04,21,00,00,00,00,00,\
::  08,00,00,00,00,00,00,00,48,34,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,06,\
::  00,00,00,49,00,00,00,49,00,00,00,91,90,00,00,06,00,00,00,01,00,00,00,01,04,\
::  21,02,00,00,00,00,09,00,00,00,00,00,00,00,38,35,bf,43,f6,7f,00,00,00,00,00,\
::  00,00,00,00,00,07,00,00,00,49,00,00,00,49,00,00,00,92,90,00,00,07,00,00,00,\
::  00,00,00,00,01,04,21,08,00,00,00,00,0a,00,00,00,00,00,00,00,50,35,bf,43,f6,\
::  7f,00,00,00,00,00,00,00,00,00,00,08,00,00,00,49,00,00,00,49,00,00,00,93,90,\
::  00,00,08,00,00,00,00,00,00,00,01,04,21,08,00,00,00,00,0b,00,00,00,00,00,00,\
::  00,70,35,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,09,00,00,00,49,00,00,00,\
::  49,00,00,00,39,a0,00,00,09,00,00,00,00,00,00,00,01,04,21,08,00,00,00,00,1c,\
::  00,00,00,00,00,00,00,90,35,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,0a,00,\
::  00,00,64,00,00,00,49,00,00,00,3a,a0,00,00,0a,00,00,00,00,00,00,00,00,01,10,\
::  08,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,02,00,00,00,08,00,00,00,01,00,00,00,00,00,00,00,20,34,bf,43,f6,\
::  7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,71,01,00,00,1e,00,00,00,b0,90,\
::  00,00,00,00,00,00,ff,00,00,00,01,01,50,00,00,00,00,00,15,00,00,00,00,00,00,\
::  00,50,37,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6b,00,00,00,\
::  1e,00,00,00,b1,90,00,00,01,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,16,\
::  00,00,00,00,00,00,00,80,37,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,\
::  ff,ff,6b,00,00,00,1e,00,00,00,b2,90,00,00,02,00,00,00,01,00,00,00,00,04,25,\
::  02,00,00,00,00,18,00,00,00,00,00,00,00,a8,37,bf,43,f6,7f,00,00,00,00,00,00,\
::  00,00,00,00,ff,ff,ff,ff,8e,00,00,00,1e,00,00,00,b4,90,00,00,03,00,00,00,00,\
::  00,00,00,00,04,25,00,00,00,00,00,17,00,00,00,00,00,00,00,d0,37,bf,43,f6,7f,\
::  00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,7c,00,00,00,1e,00,00,00,b3,90,00,\
::  00,04,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,19,00,00,00,00,00,00,00,\
::  08,38,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,a0,00,00,00,1e,\
::  00,00,00,b5,90,00,00,05,00,00,00,00,00,00,00,00,04,20,00,00,00,00,00,1a,00,\
::  00,00,00,00,00,00,38,38,bf,43,f6,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,\
::  ff,7d,00,00,00,1e,00,00,00,b6,90,00,00,06,00,00,00,00,00,00,00,00,04,20,00,\
::  00,00,00,00,1b,00,00,00,00,00,00,00,68,38,bf,43,f6,7f,00,00,00,00,00,00,00,\
::  00,00,00,ff,ff,ff,ff,7d,00,00,00,1e,00,00,00,b7,90,00,00,07,00,00,00,00,00,\
::  00,00,00,04,20,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,01,01,00,00,00,00,00,00,01,00,00,00,00,00,00,00,00,00,5c,00,3f,00,5c,\
::  00,53,00,43,00,53,00,49,00,23,00,44,00,69,00,73,00,6b,00,26,00,56,00,65,00,\
::  6e,00,5f,00,56,00,42,00,4f,00,58,00,26,00,50,00,72,00,6f,00,64,00,5f,00,48,\
::  00,41,00,52,00,44,00,44,00,49,00,53,00,4b,00,23,00,34,00,26,00,32,00,36,00,\
::  31,00,37,00,61,00,65,00,61,00,65,00,26,00,30,00,26,00,30,00,30,00,30,00,30,\
::  00,30,00,30,00,23,00,7b,00,35,00,33,00,66,00,35,00,36,00,33,00,30,00,37,00,\
::  2d,00,62,00,36,00,62,00,66,00,2d,00,31,00,31,00,64,00,30,00,2d,00,39,00,34,\
::  00,66,00,32,00,2d,00,30,00,30,00,61,00,30,00,63,00,39,00,31,00,65,00,66,00,\
::  62,00,38,00,62,00,7d,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,01,00,da,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,\
::  00,00,00,00,95,0d,21,fc,78,08,00,00,b8,00,00,00,31,02,00,00,26,00,00,00,48,\
::  00,00,00,73,00,00,00,41,00,00,00,50,00,00,00,24,00,00,00,3f,00,00,00,2a,00,\
::  00,00,83,00,00,00,9d,00,00,00,a0,00,00,00,cb,00,00,00,a9,00,00,00,a7,00,00,\
::  00,4e,00,00,00,48,00,00,00,37,00,00,00,46,00,00,00,37,00,00,00,57,00,00,00,\
::  37,00,00,00,36,00,00,00,4d,00,00,00,48,00,00,00,3c,00,00,00,3f,00,00,00,3e,\
::  00,00,00,57,00,00,00,59,00,00,00,5b,00,00,00,ea,02,00,00,c4,05,00,00,94,00,\
::  00,00,3b,00,00,00,38,00,00,00,6b,00,00,00,30,01,00,00,97,00,00,00,6b,00,00,\
::  00,66,00,00,00,63,00,00,00,23,00,00,00,4a,00,00,00,8b,00,00,00,7a,00,00,00,\
::  cf,00,00,00,00,00,00,00,01,00,00,00,02,00,00,00,03,00,00,00,04,00,00,00,05,\
::  00,00,00,06,00,00,00,07,00,00,00,08,00,00,00,09,00,00,00,0a,00,00,00,0b,00,\
::  00,00,0c,00,00,00,0d,00,00,00,0e,00,00,00,0f,00,00,00,10,00,00,00,11,00,00,\
::  00,12,00,00,00,13,00,00,00,14,00,00,00,15,00,00,00,16,00,00,00,17,00,00,00,\
::  18,00,00,00,19,00,00,00,1a,00,00,00,1b,00,00,00,1c,00,00,00,1d,00,00,00,1e,\
::  00,00,00,1f,00,00,00,20,00,00,00,21,00,00,00,22,00,00,00,23,00,00,00,24,00,\
::  00,00,25,00,00,00,26,00,00,00,27,00,00,00,28,00,00,00,29,00,00,00,2a,00,00,\
::  00,2b,00,00,00,2c,00,00,00,2d,00,00,00,2e,00,00,00,2f,00,00,00,0a,00,00,00,\
::  01,00,00,00,1f,00,00,00,00,00,00,00,08,01,00,00,2c,00,00,00,e1,01,00,00,3b,\
::  00,00,00,d3,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,01,00,00,00,02,00,00,00,03,00,00,00,04,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
::'))
::
::#endregion configs > Windows > Baseline English
::
::
::#region configs > Windows > Baseline Russian
::
::Set-Variable -Option Constant CONFIG_BASELINE_RUSSIAN ([String]('[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\TaskManager]
::"Preferences"=hex:0d,00,00,00,60,00,00,00,60,00,00,00,9c,00,00,00,9c,00,00,00,\
::  17,02,00,00,10,02,00,00,00,00,00,00,00,00,00,80,00,00,00,80,d8,01,00,80,df,\
::  01,00,80,00,01,00,01,00,00,00,00,00,00,00,00,94,07,00,00,cf,03,00,00,f4,01,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,0f,00,00,00,01,00,00,00,00,00,00,\
::  00,20,34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,bd,01,00,00,\
::  1e,00,00,00,89,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,00,00,00,00,00,0d,\
::  00,00,00,00,00,00,00,60,34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,\
::  ff,ff,71,00,00,00,1e,00,00,00,8b,90,00,00,01,00,00,00,00,00,00,00,00,10,10,\
::  00,00,00,00,00,03,00,00,00,00,00,00,00,78,34,f4,5c,f7,7f,00,00,00,00,00,00,\
::  00,00,00,00,ff,ff,ff,ff,82,00,00,00,1e,00,00,00,8c,90,00,00,02,00,00,00,00,\
::  00,00,00,01,02,12,00,00,00,00,00,04,00,00,00,00,00,00,00,90,34,f4,5c,f7,7f,\
::  00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,b0,00,00,00,1e,00,00,00,8d,90,00,\
::  00,03,00,00,00,00,00,00,00,00,01,10,00,00,00,00,00,02,00,00,00,00,00,00,00,\
::  b0,34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,56,00,00,00,1e,\
::  00,00,00,8a,90,00,00,04,00,00,00,00,00,00,00,00,08,20,00,00,00,00,00,05,00,\
::  00,00,00,00,00,00,c8,34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,\
::  ff,c1,00,00,00,1e,00,00,00,8e,90,00,00,05,00,00,00,00,00,00,00,00,01,10,00,\
::  00,00,00,00,06,00,00,00,00,00,00,00,f0,34,f4,5c,f7,7f,00,00,00,00,00,00,00,\
::  00,00,00,ff,ff,ff,ff,04,01,00,00,1e,00,00,00,8f,90,00,00,06,00,00,00,00,00,\
::  00,00,00,01,10,01,00,00,00,00,07,00,00,00,00,00,00,00,18,35,f4,5c,f7,7f,00,\
::  00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,90,90,00,00,\
::  07,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,08,00,00,00,00,00,00,00,48,\
::  34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,\
::  00,00,91,90,00,00,08,00,00,00,01,00,00,00,00,04,25,02,00,00,00,00,09,00,00,\
::  00,00,00,00,00,38,35,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,\
::  49,00,00,00,49,00,00,00,92,90,00,00,09,00,00,00,00,00,00,00,00,04,25,08,00,\
::  00,00,00,0a,00,00,00,00,00,00,00,50,35,f4,5c,f7,7f,00,00,00,00,00,00,00,00,\
::  00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,93,90,00,00,0a,00,00,00,00,00,00,\
::  00,00,04,25,08,00,00,00,00,0b,00,00,00,00,00,00,00,70,35,f4,5c,f7,7f,00,00,\
::  00,00,00,00,00,00,00,00,ff,ff,ff,ff,49,00,00,00,49,00,00,00,39,a0,00,00,0b,\
::  00,00,00,00,00,00,00,00,04,25,08,00,00,00,00,1c,00,00,00,00,00,00,00,90,35,\
::  f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,4c,00,00,00,49,00,00,\
::  00,3a,a0,00,00,0c,00,00,00,00,00,00,00,00,01,10,08,00,00,00,00,1d,00,00,00,\
::  00,00,00,00,b8,35,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,80,\
::  00,00,00,49,00,00,00,4c,a0,00,00,0d,00,00,00,00,00,00,00,00,02,15,08,00,00,\
::  00,00,1e,00,00,00,00,00,00,00,d8,35,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,\
::  00,ff,ff,ff,ff,bb,00,00,00,49,00,00,00,4d,a0,00,00,0e,00,00,00,00,00,00,00,\
::  00,02,15,08,00,00,00,00,03,00,00,00,0a,00,00,00,01,00,00,00,00,00,00,00,20,\
::  34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,1d,01,00,00,1e,00,\
::  00,00,89,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,00,00,00,00,00,04,00,00,\
::  00,00,00,00,00,90,34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,01,00,00,00,\
::  93,00,00,00,1e,00,00,00,8d,90,00,00,01,00,00,00,00,00,00,00,01,01,10,00,00,\
::  00,00,00,03,00,00,00,00,00,00,00,78,34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,\
::  00,00,ff,ff,ff,ff,4c,00,00,00,1e,00,00,00,8c,90,00,00,02,00,00,00,00,00,00,\
::  00,00,02,10,00,00,00,00,00,0c,00,00,00,00,00,00,00,08,36,f4,5c,f7,7f,00,00,\
::  00,00,00,00,00,00,00,00,03,00,00,00,76,00,00,00,1e,00,00,00,94,90,00,00,03,\
::  00,00,00,00,00,00,00,01,02,10,00,00,00,00,00,0d,00,00,00,00,00,00,00,30,36,\
::  f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,4e,00,00,00,1e,00,00,\
::  00,95,90,00,00,04,00,00,00,00,00,00,00,00,01,10,00,00,00,00,00,0e,00,00,00,\
::  00,00,00,00,58,36,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,05,00,00,00,cf,\
::  00,00,00,1e,00,00,00,96,90,00,00,05,00,00,00,01,00,00,00,01,04,20,00,00,00,\
::  00,00,0f,00,00,00,00,00,00,00,80,36,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,\
::  00,06,00,00,00,64,00,00,00,1e,00,00,00,97,90,00,00,06,00,00,00,01,00,00,00,\
::  01,04,20,02,00,00,00,00,10,00,00,00,00,00,00,00,a0,36,f4,5c,f7,7f,00,00,00,\
::  00,00,00,00,00,00,00,07,00,00,00,7f,00,00,00,1e,00,00,00,98,90,00,00,07,00,\
::  00,00,00,00,00,00,01,01,10,00,00,00,00,00,11,00,00,00,00,00,00,00,c0,36,f4,\
::  5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,91,00,00,00,1e,00,00,00,\
::  99,90,00,00,08,00,00,00,00,00,00,00,00,01,10,00,00,00,00,00,06,00,00,00,00,\
::  00,00,00,f0,34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,09,00,00,00,19,01,\
::  00,00,1e,00,00,00,8f,90,00,00,09,00,00,00,00,00,00,00,01,01,10,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,04,00,00,00,0b,00,00,00,01,00,00,00,00,00,00,00,20,34,f4,\
::  5c,f7,7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,25,01,00,00,1e,00,00,00,\
::  9e,90,00,00,00,00,00,00,ff,00,00,00,01,01,50,00,00,00,00,00,12,00,00,00,00,\
::  00,00,00,e8,36,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,2d,00,\
::  00,00,1e,00,00,00,9b,90,00,00,01,00,00,00,00,00,00,00,00,04,20,00,00,00,00,\
::  00,14,00,00,00,00,00,00,00,08,37,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,\
::  ff,ff,ff,ff,64,00,00,00,1e,00,00,00,9d,90,00,00,02,00,00,00,00,00,00,00,00,\
::  01,10,00,00,00,00,00,13,00,00,00,00,00,00,00,30,37,f4,5c,f7,7f,00,00,00,00,\
::  00,00,00,00,00,00,ff,ff,ff,ff,64,00,00,00,1e,00,00,00,9c,90,00,00,03,00,00,\
::  00,00,00,00,00,00,01,10,00,00,00,00,00,03,00,00,00,00,00,00,00,78,34,f4,5c,\
::  f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6f,00,00,00,1e,00,00,00,8c,\
::  90,00,00,04,00,00,00,00,00,00,00,01,02,10,00,00,00,00,00,07,00,00,00,00,00,\
::  00,00,18,35,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,05,00,00,00,49,00,00,\
::  00,49,00,00,00,90,90,00,00,05,00,00,00,00,00,00,00,01,04,21,00,00,00,00,00,\
::  08,00,00,00,00,00,00,00,48,34,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,06,\
::  00,00,00,49,00,00,00,49,00,00,00,91,90,00,00,06,00,00,00,01,00,00,00,01,04,\
::  21,02,00,00,00,00,09,00,00,00,00,00,00,00,38,35,f4,5c,f7,7f,00,00,00,00,00,\
::  00,00,00,00,00,07,00,00,00,49,00,00,00,49,00,00,00,92,90,00,00,07,00,00,00,\
::  00,00,00,00,01,04,21,08,00,00,00,00,0a,00,00,00,00,00,00,00,50,35,f4,5c,f7,\
::  7f,00,00,00,00,00,00,00,00,00,00,08,00,00,00,49,00,00,00,49,00,00,00,93,90,\
::  00,00,08,00,00,00,00,00,00,00,01,04,21,08,00,00,00,00,0b,00,00,00,00,00,00,\
::  00,70,35,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,09,00,00,00,49,00,00,00,\
::  49,00,00,00,39,a0,00,00,09,00,00,00,00,00,00,00,01,04,21,08,00,00,00,00,1c,\
::  00,00,00,00,00,00,00,90,35,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,0a,00,\
::  00,00,64,00,00,00,49,00,00,00,3a,a0,00,00,0a,00,00,00,00,00,00,00,00,01,10,\
::  08,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,02,00,00,00,08,00,00,00,01,00,00,00,00,00,00,00,20,34,f4,5c,f7,\
::  7f,00,00,00,00,00,00,00,00,00,00,00,00,00,00,c2,01,00,00,1e,00,00,00,b0,90,\
::  00,00,00,00,00,00,ff,00,00,00,01,01,50,00,00,00,00,00,15,00,00,00,00,00,00,\
::  00,50,37,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,6b,00,00,00,\
::  1e,00,00,00,b1,90,00,00,01,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,16,\
::  00,00,00,00,00,00,00,80,37,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,\
::  ff,ff,6b,00,00,00,1e,00,00,00,b2,90,00,00,02,00,00,00,01,00,00,00,00,04,25,\
::  02,00,00,00,00,18,00,00,00,00,00,00,00,a8,37,f4,5c,f7,7f,00,00,00,00,00,00,\
::  00,00,00,00,ff,ff,ff,ff,8e,00,00,00,1e,00,00,00,b4,90,00,00,03,00,00,00,00,\
::  00,00,00,00,04,25,00,00,00,00,00,17,00,00,00,00,00,00,00,d0,37,f4,5c,f7,7f,\
::  00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,7c,00,00,00,1e,00,00,00,b3,90,00,\
::  00,04,00,00,00,00,00,00,00,00,04,25,00,00,00,00,00,19,00,00,00,00,00,00,00,\
::  08,38,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,a0,00,00,00,1e,\
::  00,00,00,b5,90,00,00,05,00,00,00,00,00,00,00,00,04,20,00,00,00,00,00,1a,00,\
::  00,00,00,00,00,00,38,38,f4,5c,f7,7f,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,\
::  ff,7d,00,00,00,1e,00,00,00,b6,90,00,00,06,00,00,00,00,00,00,00,00,04,20,00,\
::  00,00,00,00,1b,00,00,00,00,00,00,00,68,38,f4,5c,f7,7f,00,00,00,00,00,00,00,\
::  00,00,00,ff,ff,ff,ff,7d,00,00,00,1e,00,00,00,b7,90,00,00,07,00,00,00,00,00,\
::  00,00,00,04,20,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,01,01,00,00,00,00,00,00,01,00,00,00,00,00,00,00,00,00,5c,00,3f,00,5c,\
::  00,53,00,43,00,53,00,49,00,23,00,44,00,69,00,73,00,6b,00,26,00,56,00,65,00,\
::  6e,00,5f,00,56,00,42,00,4f,00,58,00,26,00,50,00,72,00,6f,00,64,00,5f,00,48,\
::  00,41,00,52,00,44,00,44,00,49,00,53,00,4b,00,23,00,34,00,26,00,32,00,36,00,\
::  31,00,37,00,61,00,65,00,61,00,65,00,26,00,30,00,26,00,30,00,30,00,30,00,30,\
::  00,30,00,30,00,23,00,7b,00,35,00,33,00,66,00,35,00,36,00,33,00,30,00,37,00,\
::  2d,00,62,00,36,00,62,00,66,00,2d,00,31,00,31,00,64,00,30,00,2d,00,39,00,34,\
::  00,66,00,32,00,2d,00,30,00,30,00,61,00,30,00,63,00,39,00,31,00,65,00,66,00,\
::  62,00,38,00,62,00,7d,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,01,00,da,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,\
::  00,00,00,00,85,0d,20,e0,40,08,00,00,ce,00,00,00,31,02,00,00,58,00,00,00,6c,\
::  00,00,00,73,00,00,00,4e,00,00,00,7a,00,00,00,28,00,00,00,50,00,00,00,3c,00,\
::  00,00,95,00,00,00,ca,00,00,00,7e,00,00,00,a5,00,00,00,87,00,00,00,c2,00,00,\
::  00,9a,00,00,00,a4,00,00,00,99,00,00,00,9a,00,00,00,84,00,00,00,7b,00,00,00,\
::  58,00,00,00,37,00,00,00,67,00,00,00,59,00,00,00,d4,00,00,00,d2,00,00,00,bf,\
::  00,00,00,b9,00,00,00,af,00,00,00,a1,00,00,00,ea,02,00,00,d9,05,00,00,c7,00,\
::  00,00,4e,00,00,00,a0,00,00,00,7a,00,00,00,8c,01,00,00,e0,00,00,00,78,00,00,\
::  00,a9,00,00,00,d1,00,00,00,2d,00,00,00,41,00,00,00,0f,01,00,00,f3,00,00,00,\
::  da,00,00,00,00,00,00,00,01,00,00,00,02,00,00,00,03,00,00,00,04,00,00,00,05,\
::  00,00,00,06,00,00,00,07,00,00,00,08,00,00,00,09,00,00,00,0a,00,00,00,0b,00,\
::  00,00,0c,00,00,00,0d,00,00,00,0e,00,00,00,0f,00,00,00,10,00,00,00,11,00,00,\
::  00,12,00,00,00,13,00,00,00,14,00,00,00,15,00,00,00,16,00,00,00,17,00,00,00,\
::  18,00,00,00,19,00,00,00,1a,00,00,00,1b,00,00,00,1c,00,00,00,1d,00,00,00,1e,\
::  00,00,00,1f,00,00,00,20,00,00,00,21,00,00,00,22,00,00,00,23,00,00,00,24,00,\
::  00,00,25,00,00,00,26,00,00,00,27,00,00,00,28,00,00,00,29,00,00,00,2a,00,00,\
::  00,2b,00,00,00,2c,00,00,00,2d,00,00,00,2e,00,00,00,2f,00,00,00,0a,00,00,00,\
::  01,00,00,00,1f,00,00,00,00,00,00,00,09,01,00,00,54,00,00,00,de,02,00,00,57,\
::  00,00,00,d3,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,01,00,00,00,02,00,00,00,03,00,00,00,04,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
::'))
::
::#endregion configs > Windows > Baseline Russian
::
::
::#region configs > Windows > Baseline
::
::Set-Variable -Option Constant CONFIG_BASELINE ([String]('[HKEY_CURRENT_USER\Control Panel\Desktop]
::"JPEGImportQuality"=dword:00000064
::
::[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
::"MultilingualEnabled"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Notepad]
::"iWindowPosX"=dword:FFFFFFF8
::"iWindowPosY"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\View]
::"WindowPlacement"=hex:2C,00,00,00,02,00,00,00,03,00,00,00,00,83,FF,FF,00,83,\
::  FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,00,00,00,00,00,00,00,00,80,07,00,00,93,03,00,00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
::"Value"="Allow"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"Hidden"=dword:00000001 ; Show hidden files
::"NavPaneShowAllCloudStates"=dword:00000001
::"SeparateProcess"=dword:00000001
::"ShowClockInNotificationCenter"=dword:00000001
::
::; Enable "End task" in the taskbar
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings]
::"TaskbarEndTask"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel]
::"AllItemsIconView"=dword:00000000
::"StartupPage"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\ShowJumpView]
::"AllItemsIconView"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
::"{2cc5ca98-6485-489a-920e-b3e88a6ccce3}"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer]
::"PreviewPaneSizer"=hex:9E,00,00,00,01,00,00,00,00,00,00,00,59,03,00,00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\PerExplorerSettings\3\Sizer]
::"PreviewPaneSizer"=hex:9E,00,00,00,01,00,00,00,00,00,00,00,59,03,00,00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager]
::"EnthusiastMode"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\Preferences]
::"ArchivedFiles"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
::"VisualFXSetting"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy]
::"01"=dword:00000001
::"256"=dword:0000003C
::"2048"=dword:0000001E
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\D3D Shader Cache]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Device Driver Packages]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Diagnostic Data Viewer database files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Language Pack]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\RetailDemo Offline Content]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\User file versions]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
::"ConsentPromptBehaviorUser"=dword:00000000
::"DisableAutomaticRestartSignOn"=dword:00000001
::"FilterAdministratorToken"=dword:00000001
::"PromptOnSecureDesktop"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update]
::"AUOptions"=dword:00000004
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\AU]
::"AUOptions"=dword:00000004
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services]
::"DefaultService"="7971f918-a847-4430-9279-4a52d1efe18d"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971F918-A847-4430-9279-4A52D1EFE18D]
::"RegisteredWithAU"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Search\Preferences]
::"AllowIndexingEncryptedStoresOrItems"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search]
::"EnableFindMyFiles"=dword:00000001
::"SystemIndexNormalization"=dword:00000003
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex]
::"EnableFindMyFiles"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings]
::"AllowMUUpdateService"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System]
::"ConsentPromptBehaviorUser"=dword:00000000
::"FilterAdministratorToken"=dword:00000001
::"PromptOnSecureDesktop"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows Search]
::"EnableFindMyFiles"=dword:00000001
::"SystemIndexNormalization"=dword:00000003
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows Search\Gather\Windows\SystemIndex]
::"EnableFindMyFiles"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl]
::"DisableEmoticon"=dword:00000001
::"DisplayParameters"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
::"LongPathsEnabled"=dword:00000001
::"NTFSDisable8dot3NameCreation"=dword:00000001
::"Win95TruncatedExtensions"=dword:00000000
::'))
::
::#endregion configs > Windows > Baseline
::
::
::#region configs > Windows > Performance
::
::Set-Variable -Option Constant CONFIG_PERFORMANCE ([String]('[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
::"VideoQualityOnBattery"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile]
::"NetworkThrottlingIndex"=dword:FFFFFFFF
::"SystemResponsiveness"=dword:00000010
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
::"StartupBoostEnabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main]
::"AllowPrelaunch"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge]
::"StartupBoostEnabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\MicrosoftEdge\Main]
::"AllowPrelaunch"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control]
::"SvcHostSplitThresholdInKB"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling]
::"PowerThrottlingOff"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Ndu]
::"Start"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters]
::"DefaultTTL"=dword:00000064
::"GlobalMaxTcpWindowSize"=dword:00065535
::"MaxUserPort"=dword:00065534
::"Tcp1323Opts"=dword:00000001
::"TcpMaxDupAcks"=dword:00000002
::"TCPTimedWaitDelay"=dword:00000030
::'))
::
::#endregion configs > Windows > Performance
::
::
::#region configs > Windows > Personalisation
::
::Set-Variable -Option Constant CONFIG_PERSONALISATION ([String]('; Enable classic context menu
::[HKEY_CURRENT_USER\Software\Classes\CLSID\{86CA1AA0-34AA-4E8B-A509-50C905BAE2A2}\InprocServer32]
::@=""
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
::"ContentDeliveryAllowed"=dword:00000001
::"RotatingLockScreenEnabled"=dword:00000001
::"SubscribedContent-338387Enabled"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\DesktopSpotlight\Settings]
::"EnabledState"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
::"EnableAutoTray"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"LaunchTo"=dword:00000001 ; Launch File Explorer to "This PC"
::"MMTaskbarGlomLevel"=dword:00000001 ; Combine taskbar when full
::"NavPaneExpandToCurrentFolder"=dword:00000001
::"NavPaneShowAllFolders"=dword:00000001
::"ShowCopilotButton"=dword:00000000 ; Disable Copilot button on the taskbar
::"ShowCortanaButton"=dword:00000000
::"Start_Layout"=dword:00000001
::"TaskbarAl"=dword:00000000 ; Align taskbar left
::"TaskbarGlomLevel"=dword:00000001 ; Combine taskbar when full
::"TaskbarMn"=dword:00000000 ; Disable chat taskbar (Windows 11)
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People]
::"PeopleBand"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Feeds]
::"ShellFeedsTaskbarViewMode"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen]
::"RotatingLockScreenOverlayEnabled"=dword:00000000
::
::; Disable chat taskbar (Windows 10)
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"HideSCAMeetNow"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
::"SearchboxTaskbarMode"=dword:00000001 ; Show search icon
::"WebViewBundleType"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings\Appearance\Current]
::"baseline"="{00000000-0000-0000-0000-000000000000}"
::"current"="{00000000-0000-0000-0000-000000000000}"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start]
::"VisiblePlaces"=hex:2F,B3,67,E3,DE,89,55,43,BF,CE,61,F3,7B,18,A9,37,86,08,73, \
::  52,AA,51,43,42,9F,7B,27,76,58,46,59,D4
::
::[HKEY_LOCAL_MACHINE\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
::"ShowCmd"=dword:00000003
::"WFlags"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
::"ShowCmd"=dword:00000003
::"WFlags"=dword:00000002
::
::; Disable widgets service
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests]
::"value"=dword:00000000
::
::; Disable chat taskbar (Windows 10)
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"HideSCAMeetNow"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked]
::"{CB3B0003-8088-4EDE-8769-8B354AB2FF8C}"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Shell\Copilot]
::"CopilotDisabledReason"="IsEnabledForGeographicRegionFailed"
::"IsCopilotAvailable"=dword:00000000
::
::; Disable widgets service
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh]
::"AllowNewsAndInterests"=dword:00000000
::
::; Disable Copilot service
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
::"TurnOffWindowsCopilot"=dword:00000001
::
::; Disable chat taskbar (Windows 10)
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"HideSCAMeetNow"=dword:00000001
::
::; Disable widgets service
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Dsh]
::"AllowNewsAndInterests"=dword:00000000
::
::; Disable Copilot service
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsCopilot]
::"TurnOffWindowsCopilot"=dword:00000001
::'))
::
::#endregion configs > Windows > Personalisation
::
::
::#region configs > Windows > Power settings
::
::Set-Variable -Option Constant CONFIG_POWER_SETTINGS (
::    [Hashtable[]]@(
::        @{SubGroup = '0d7dbae2-4294-402a-ba8e-26777e8488cd'; Setting = '309dce9b-bef4-4119-9921-a851fb12f0f4'; Value = 0 },
::        @{SubGroup = '02f815b5-a5cf-4c84-bf20-649d1f75d3d8'; Setting = '4c793e7d-a264-42e1-87d3-7a0d2f523ccd'; Value = 1 },
::        @{SubGroup = '19cbb8fa-5279-450e-9fac-8a3d5fedd0c1'; Setting = '12bbebe6-58d6-4636-95bb-3217ef867c1a'; Value = 0 },
::        @{SubGroup = '9596fb26-9850-41fd-ac3e-f7c3c00afd4b'; Setting = '03680956-93bc-4294-bba6-4e0f09bb717f'; Value = 1 },
::        @{SubGroup = '9596fb26-9850-41fd-ac3e-f7c3c00afd4b'; Setting = '10778347-1370-4ee0-8bbd-33bdacaade49'; Value = 1 },
::        @{SubGroup = '9596fb26-9850-41fd-ac3e-f7c3c00afd4b'; Setting = '34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4'; Value = 0 },
::        @{SubGroup = 'de830923-a562-41af-a086-e3a2c6bad2da'; Setting = 'e69653ca-cf7f-4f05-aa73-cb833fa90ad4'; Value = 0 },
::        @{SubGroup = 'SUB_PCIEXPRESS'; Setting = 'ASPM'; Value = 0 },
::        @{SubGroup = 'SUB_PROCESSOR'; Setting = 'SYSCOOLPOL'; Value = 1 },
::        @{SubGroup = 'SUB_SLEEP'; Setting = 'HYBRIDSLEEP'; Value = 1 },
::        @{SubGroup = 'SUB_SLEEP'; Setting = 'RTCWAKE'; Value = 1 }
::    )
::)
::
::#endregion configs > Windows > Power settings
::
::
::#region configs > Windows > Privacy
::
::Set-Variable -Option Constant CONFIG_PRIVACY ([String]('[HKEY_CURRENT_USER\Control Panel\International\User Profile]
::"HttpAcceptLanguageOptOut"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]
::"DoNotTrack"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]
::"EnableCortana"=dword:00000000
::
::; Disable "Improve Inking and Typing Recognition"
::[HKEY_CURRENT_USER\Software\Microsoft\Input\TIPC]
::"Enabled"=dword:00000000
::
::; Disable "Inking and Typing Personalization"
::[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization]
::"RestrictImplicitInkCollection"=dword:00000001
::"RestrictImplicitTextCollection"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore]
::"HarvestContacts"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main]
::"DoNotTrack"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\Privacy\SettingsStore\Anonymous]
::"OptionalConnectedExperiencesNoticeVersion"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings]
::"AcceptedPrivacyPolicy"=dword:00000000
::
::; Set Feedback Frequency to Never
::[HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules]
::"NumberOfSIUFInPeriod"=dword:00000000
::"PeriodInNanoSeconds"=-
::
::; Disable "Online Speech Recognition"
::[HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy]
::"HasAccepted"=dword:00000000
::
::; Disable "Let Apps use Advertising ID for Relevant Ads" (Windows 10)
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
::"Enabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics]
::"Value"="Deny"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation]
::"Value"="Deny"
::
::; Disable "Tailored experiences with diagnostic data"
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CPSS\Store]
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::; Disable "Let Windows improve Start and search results by tracking app launches"
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"Start_TrackProgs"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Feeds]
::"EnableFeeds"=dword:00000000
::
::; Disable "Tailored experiences with diagnostic data"
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Privacy]
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
::"AllowCortana"=dword:00000000
::"AllowSearchToUseLocation"=dword:00000000
::"ConnectedSearchPrivacy"=dword:00000003
::"CortanaConsent"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Windows Search]
::"CortanaConsent"=dword:00000000
::
::; Disable personalization of ads, Microsoft Edge, search, news and other Microsoft services by sending browsing history, favorites and collections, usage and other browsing data to Microsoft
::; Disable required and optional diagnostic data about browser usage
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge]
::"ConfigureDoNotTrack"=dword:00000001
::"EdgeShoppingAssistantEnabled"=dword:00000000
::"PaymentMethodQueryEnabled"=dword:00000000
::"PersonalizationReportingEnabled"=dword:00000000
::"UserFeedbackAllowed"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\Common]
::"QMEnable"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\Common\Feedback]
::"Enabled"=dword:00000000
::"IncludeEmail"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\osm]
::"EnableFileObfuscation"=dword:00000001
::"Enablelogging"=dword:00000000
::"EnableUpload"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\Common\ClientTelemetry]
::"DisableTelemetry"=dword:00000001
::"SendTelemetry"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent]
::"DisableTailoredExperiencesWithDiagnosticData"=dword:00000001
::"DisableWindowsSpotlightOnLockScreen"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Windows Feeds]
::"EnableFeeds"=dword:00000000
::
::; Disable AI recall
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
::"DisableAIDataAnalysis"=dword:00000001
::
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Performance Toolkit\v5\WPRControl\DiagTrackMiniLogger\Boot\RunningProfile]
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth]
::"AllowAdvertising"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Education]
::"IsEducationEnvironment"=dword:00000001
::
::; Disable "Let Apps use Advertising ID for Relevant Ads" (Windows 10)
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics]
::"Value"="Deny"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
::"Value"="Allow"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation]
::"Value"="Deny"
::
::; Disable "Tailored experiences with diagnostic data"
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store]
::"AllowTelemetry"=dword:00000000
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack]
::"DiagTrackStatus"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\TraceManager]
::"miniTraceHasStopTime"=dword:00000000
::"miniTraceIsAutoLogger"=dword:00000000
::"miniTraceProfileHash"=hex:00,00,00,00,00,00,00,00
::"miniTraceRequiredBufferSpace"=dword:00000000
::"miniTraceScenarioId"=-
::"miniTraceSessionStartTime"=hex:00,00,00,00,00,00,00,00
::"miniTraceSlotEnabled"=dword:00000000
::"miniTraceStopTime"=hex:00,00,00,00,00,00,00,00
::
::; Send only Required Diagnostic and Usage Data
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
::"AllowTelemetry"=dword:00000000
::"MaxTelemetryAllowed"=dword:00000000
::
::; Disable "Tailored experiences with diagnostic data"
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy]
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Shell\Copilot\BingChat]
::"IsUserEligible"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting]
::"Disabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}]
::"SensorPermissionState"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\BraveSoftware\Brave]
::"BraveAIChatEnabled"=dword:00000000
::"BraveNewsDisabled"=dword:00000001
::"BraveRewardsDisabled"=dword:00000001
::"BraveTalkDisabled"=dword:00000001
::"BraveVPNDisabled"=dword:00000001
::"BraveWalletDisabled"=dword:00000001
::
::; Disable Microsoft Edge MSN news feed, sponsored links, shopping assistant and more.
::; Disable personalization of ads, Microsoft Edge, search, news and other Microsoft services by sending browsing history, favorites and collections, usage and other browsing data to Microsoft
::; Disable required and optional diagnostic data about browser usage
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
::"AllowGamesMenu"=dword:00000000
::"BuiltInDNSClientEnabled"=dword:00000000
::"ComposeInlineEnabled"=dword:00000000
::"ConfigureDoNotTrack"=dword:00000001
::"CopilotCDPPageContext"=dword:00000000
::"CopilotPageContext"=dword:00000000
::"CryptoWalletEnabled"=dword:00000000
::"DiagnosticData"=dword:00000000
::"EdgeAssetDeliveryServiceEnabled"=dword:00000000
::"EdgeCollectionsEnabled"=dword:00000000
::"EdgeEntraCopilotPageContext"=dword:00000000
::"EdgeHistoryAISearchEnabled"=dword:00000000
::"EdgeShoppingAssistantEnabled"=dword:00000000
::"ExperimentationAndConfigurationServiceControl"=dword:00000002
::"GenAILocalFoundationalModelSettings"=dword:00000001
::"HubsSidebarEnabled"=dword:00000000
::"Microsoft365CopilotChatIconEnabled"=dword:00000000
::"MicrosoftEdgeInsiderPromotionEnabled"=dword:00000000
::"NewTabPageBingChatEnabled"=dword:00000000
::"NewTabPageContentEnabled"=dword:00000000
::"NewTabPageHideDefaultTopSites"=dword:00000001
::"PersonalizationReportingEnabled"=dword:00000000
::"ShowMicrosoftRewards"=dword:00000000
::"ShowRecommendationsEnabled"=dword:00000000
::"SpotlightExperiencesAndRecommendationsEnabled"=dword:00000000
::"TabServicesEnabled"=dword:00000000
::"UserFeedbackAllowed"=dword:00000000
::"WalletDonationEnabled"=dword:00000000
::"WebToBrowserSignInEnabled"=dword:00000000
::"WebWidgetAllowed"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\Recommended]
::"BlockThirdPartyCookies"=dword:00000001
::"DefaultShareAdditionalOSRegionSetting"=dword:00000002
::
::; Disable "Inking and Typing Personalization"
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\InputPersonalization]
::"AllowInputPersonalization"=dword:00000000
::
::; Disable "Let Apps use Advertising ID for Relevant Ads" (Windows 10)
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo]
::"DisabledByGroupPolicy"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat]
::"AITEnable"=dword:00000000
::"DisableInventory"=dword:00000001
::"DisableUAR"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent]
::"ConfigureWindowsSpotlight"=dword:00000002
::"DisableSoftLanding"=dword:00000001
::"DisableSpotlightCollectionOnDesktop"=dword:00000001
::"DisableTailoredExperiencesWithDiagnosticData"=dword:00000001
::"DisableThirdPartySuggestions"=dword:00000001
::"DisableWindowsSpotlightFeatures"=dword:00000001
::"DisableWindowsSpotlightOnActionCenter"=dword:00000001
::"DisableWindowsSpotlightOnSettings"=dword:00000001
::"DisableWindowsSpotlightWindowsWelcomeExperience"=dword:00000001
::"IncludeEnterpriseSpotlight"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection]
::"AllowTelemetry"=dword:00000000 ; Send only Required Diagnostic and Usage Data
::"LimitDiagnosticLogCollection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports]
::"PreventHandwritingErrorReports"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors]
::"DisableLocationScripting"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization]
::"NoLockScreenCamera"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
::"AllowClipboardHistory"=dword:00000000
::"EnableMmx"=dword:00000000
::"PublishUserActivities"=dword:00000000 ; Disable "Activity History"
::"UploadUserActivities"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\TabletPC]
::"PreventHandwritingDataSharing"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds]
::"EnableFeeds"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
::"AllowCortana"=dword:00000000 ; Disable Cortana in search
::"AllowCortanaAboveLock"=dword:00000000 ; Disable Cortana in search
::"AllowSearchToUseLocation"=dword:00000000
::"ConnectedSearchUseWeb"=dword:00000000
::"ConnectedSearchUseWebOverMeteredConnections"=dword:00000000
::"CortanaConsent"=dword:00000000
::"DisableWebSearch"=dword:00000001
::"EnableDynamicContentInWSB"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsAI]
::"AllowRecallEnablement"=dword:00000000 ; Disable AI recall
::"DisableAIDataAnalysis"=dword:00000001 ; Disable AI recall
::"DisableClickToDo"=dword:00000001 ; Disable click to do
::"TurnOffSavingSnapshots"=dword:00000001 ; Disable AI recall
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet]
::"SpyNetReporting"=dword:00000000
::
::; Send only Required Diagnostic and Usage Data
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
::"AllowTelemetry"=dword:00000000
::"MaxTelemetryAllowed"=dword:00000000
::
::; Disable personalization of ads, Microsoft Edge, search, news and other Microsoft services by sending browsing history, favorites and collections, usage and other browsing data to Microsoft
::; Disable required and optional diagnostic data about browser usage
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge]
::"AllowGamesMenu"=dword:00000000
::"BuiltInDNSClientEnabled"=dword:00000000
::"ComposeInlineEnabled"=dword:00000000
::"ConfigureDoNotTrack"=dword:00000001
::"CopilotCDPPageContext"=dword:00000000
::"CopilotPageContext"=dword:00000000
::"CryptoWalletEnabled"=dword:00000000
::"DiagnosticData"=dword:00000000
::"EdgeAssetDeliveryServiceEnabled"=dword:00000000
::"EdgeCollectionsEnabled"=dword:00000000
::"EdgeEntraCopilotPageContext"=dword:00000000
::"EdgeHistoryAISearchEnabled"=dword:00000000
::"EdgeShoppingAssistantEnabled"=dword:00000000
::"ExperimentationAndConfigurationServiceControl"=dword:00000002
::"GenAILocalFoundationalModelSettings"=dword:00000001
::"HubsSidebarEnabled"=dword:00000000
::"Microsoft365CopilotChatIconEnabled"=dword:00000000
::"MicrosoftEdgeInsiderPromotionEnabled"=dword:00000000
::"NewTabPageBingChatEnabled"=dword:00000000
::"NewTabPageContentEnabled"=dword:00000000
::"NewTabPageHideDefaultTopSites"=dword:00000001
::"PersonalizationReportingEnabled"=dword:00000000
::"ShowMicrosoftRewards"=dword:00000000
::"ShowRecommendationsEnabled"=dword:00000000
::"SpotlightExperiencesAndRecommendationsEnabled"=dword:00000000
::"TabServicesEnabled"=dword:00000000
::"UserFeedbackAllowed"=dword:00000000
::"WalletDonationEnabled"=dword:00000000
::"WebToBrowserSignInEnabled"=dword:00000000
::"WebWidgetAllowed"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\Recommended]
::"BlockThirdPartyCookies"=dword:00000001
::"DefaultShareAdditionalOSRegionSetting"=dword:00000002
::
::; Disable "Inking and Typing Personalization"
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\InputPersonalization]
::"AllowInputPersonalization"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\AppCompat]
::"AITEnable"=dword:00000000
::"DisableInventory"=dword:00000001
::"DisableUAR"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\DataCollection]
::"AllowTelemetry"=dword:00000000 ; Send only Required Diagnostic and Usage Data
::"LimitDiagnosticLogCollection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\HandwritingErrorReports]
::"PreventHandwritingErrorReports"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\LocationAndSensors]
::"DisableLocationScripting"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Personalization]
::"NoLockScreenCamera"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\System]
::"EnableMmx"=dword:00000000
::"PublishUserActivities"=dword:00000000 ; Disable "Activity History"
::"UploadUserActivities"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\TabletPC]
::"PreventHandwritingDataSharing"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Windows Search]
::"AllowCloudSearch"=dword:00000000
::"AllowCortana"=dword:00000000 ; Disable Cortana in search
::"AllowCortanaAboveLock"=dword:00000000 ; Disable Cortana in search
::"AllowSearchToUseLocation"=dword:00000000
::"ConnectedSearchUseWeb"=dword:00000000
::"ConnectedSearchUseWebOverMeteredConnections"=dword:00000000
::"CortanaConsent"=dword:00000000
::"DisableWebSearch"=dword:00000001
::"EnableDynamicContentInWSB"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsAI]
::"AllowRecallEnablement"=dword:00000000
::"DisableAIDataAnalysis"=dword:00000001
::"DisableClickToDo"=dword:00000001 ; Disable click to do
::"TurnOffSavingSnapshots"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender\Spynet]
::"SpyNetReporting"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager]
::"EnablePeriodicBackup"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener]
::"Start"=dword:00000000
::'))
::
::#endregion configs > Windows > Privacy
::
::
::#region configs > Windows > Security
::
::Set-Variable -Option Constant CONFIG_SECURITY ([String]('[HKEY_CURRENT_USER\Software\Microsoft\Edge\SmartScreenPuaEnabled]
::@=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main]
::"Isolation"="PMEM"
::"Isolation64Bit"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\PhishingFilter]
::"EnabledV9"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings]
::"SecureProtocols"=dword:00002820
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\LockDown_Zones\0]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\LockDown_Zones\1]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\LockDown_Zones\2]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\LockDown_Zones\3]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\LockDown_Zones\4]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4]
::"140C"=dword:00000003
::"140D"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings]
::"NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"NoDriveTypeAutoRun"=dword:00000091
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\Wintrust\Config]
::"EnableCertPaddingCheck"="1"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\OneDrive]
::"PreventNetworkTrafficPreUserSignIn"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit]
::"ProcessCreationIncludeCmdLine_Enabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\NoExecuteState]
::"LastNoExecuteRadioButtonState"=dword:000036BD
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]
::"scremoveoption"="1"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Script Host\Settings]
::"Enabled"=dword:00000000
::"IgnoreUserSettings"=dword:00000001
::"Remote"=dword:00000000
::"TrustPolicy"=dword:00000002
::"UseWinSAFER"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Cryptography]
::"ForceKeyProtection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
::"AudioSandboxEnabled"=dword:00000001
::"BasicAuthOverHttpEnabled"=dword:00000000
::"DefaultWebUsbGuardSetting"=dword:00000002
::"DnsOverHttpsMode"="automatic"
::"DynamicCodeSettings"=dword:00000001
::"EncryptedClientHelloEnabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\TLSCipherSuiteDenyList]
::"1"="0xc013"
::"2"="0xc014"
::"3"="0x0035"
::"4"="0x002f"
::"5"="0x009c"
::"6"="0x009d"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\FVE]
::"EnableBDEWithNoTPM"=dword:00000001
::"UseAdvancedStartup"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Internet Explorer\HTA]
::"DisableHTMLApplication"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat]
::"VDMDisallowed"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Cryptography\Wintrust\Config]
::"EnableCertPaddingCheck"="1"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Cryptography]
::"ForceKeyProtection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge]
::"AudioSandboxEnabled"=dword:00000001
::"BasicAuthOverHttpEnabled"=dword:00000000
::"DefaultWebUsbGuardSetting"=dword:00000002
::"DnsOverHttpsMode"="automatic"
::"DynamicCodeSettings"=dword:00000001
::"EncryptedClientHelloEnabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\TLSCipherSuiteDenyList]
::"1"="0xc013"
::"2"="0xc014"
::"3"="0x0035"
::"4"="0x002f"
::"5"="0x009c"
::"6"="0x009d"
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control]
::"DisableRemoteSCMEndpoints"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Policy]
::"VerifiedAndReputablePolicyState"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA]
::"LmCompatibilityLevel"=dword:00000005
::"NoLMHash"=dword:00000001
::"restrictanonymous"=dword:00000001
::"RestrictRemoteSAM"="O:BAG:BAD:(A;;RC;;;BA)"
::"RunAsPPL"=dword:00000001
::"SCENoApplyLegacyAuditPolicy"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA\MSV1_0]
::"allownullsessionfallback"=dword:00000000
::"NtlmMinClientSec"=dword:20080000
::"NtlmMinServerSec"=dword:20080000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56/128]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client]
::"DisabledByDefault"=dword:00000001
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server]
::"DisabledByDefault"=dword:00000001
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client]
::"DisabledByDefault"=dword:00000001
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server]
::"DisabledByDefault"=dword:00000001
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager]
::"CWDIllegalInDLLSearch"=dword:ffffffff
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment]
::"MP_FORCE_USE_SANDBOX"="1"
::"NoDefaultCurrentDirectoryInExePath"="*"
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WoW]
::"DisallowedPolicyDefault"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters]
::"IRPStackSize"=dword:0000001E
::"requiresecuritysignature"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters]
::"RequireSecuritySignature"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration]
::"Status"=dword:00000000
::'))
::
::#endregion configs > Windows > Security
::
::
::#region configs > Windows > Tools > Debloat app list
::
::Set-Variable -Option Constant CONFIG_DEBLOAT_APP_LIST ([String]('ACGMediaPlayer                                 # Media player app
::ActiproSoftwareLLC                             # Potentially UI controls or software components, often bundled by OEMs
::AD2F1837.HPAIExperienceCenter                  # HP OEM software, AI-enhanced features and support
::AD2F1837.HPConnectedMusic                      # HP OEM software for music (Potentially discontinued)
::AD2F1837.HPConnectedPhotopoweredbySnapfish     # HP OEM software for photos, integrated with Snapfish (Potentially discontinued)
::AD2F1837.HPDesktopSupportUtilities             # HP OEM software providing desktop support tools
::AD2F1837.HPEasyClean                           # HP OEM software for system cleaning or optimization
::AD2F1837.HPFileViewer                          # HP OEM software for viewing specific file types
::AD2F1837.HPJumpStarts                          # HP OEM software for tutorials, app discovery, or quick access to HP features
::AD2F1837.HPPCHardwareDiagnosticsWindows        # HP OEM software for PC hardware diagnostics
::AD2F1837.HPPowerManager                        # HP OEM software for managing power settings and battery
::AD2F1837.HPPrinterControl                      # HP OEM software for managing HP printers
::AD2F1837.HPPrivacySettings                     # HP OEM software for managing privacy settings
::AD2F1837.HPQuickDrop                           # HP OEM software for quick file transfer between devices
::AD2F1837.HPQuickTouch                          # HP OEM software, possibly for touch-specific shortcuts or controls
::AD2F1837.HPRegistration                        # HP OEM software for product registration
::AD2F1837.HPSupportAssistant                    # HP OEM software for support, updates, and troubleshooting
::AD2F1837.HPSureShieldAI                        # HP OEM security software, likely AI-based threat protection
::AD2F1837.HPSystemInformation                   # HP OEM software for displaying system information
::AD2F1837.HPWelcome                             # HP OEM software providing a welcome experience or initial setup help
::AD2F1837.HPWorkWell                            # HP OEM software focused on well-being, possibly with break reminders or ergonomic tips
::AD2F1837.myHP                                  # HP OEM central hub app for device info, support, and services
::AdobeSystemsIncorporated.AdobePhotoshopExpress # Basic photo editing app from Adobe
::Amazon.com.Amazon                              # Amazon shopping app
::AmazonVideo.PrimeVideo                         # Amazon Prime Video streaming service app
::Asphalt8Airborne                               # Racing game
::AutodeskSketchBook                             # Digital drawing and sketching app
::CaesarsSlotsFreeCasino                         # Casino slot machine game
::Clipchamp.Clipchamp                            # Video editor from Microsoft
::COOKINGFEVER                                   # Restaurant simulation game
::CyberLinkMediaSuiteEssentials                  # Multimedia software suite (often preinstalled by OEMs)
::Disney                                         # General Disney content app (may vary by region/OEM, often Disney+)
::DisneyMagicKingdoms                            # Disney theme park building game
::DrawboardPDF                                   # PDF viewing and annotation app, often focused on pen input
::Duolingo-LearnLanguagesforFree                 # Language learning app
::EclipseManager                                 # Often related to specific OEM software or utilities (e.g., for managing screen settings)
::Facebook                                       # Facebook social media app
::FarmVille2CountryEscape                        # Farming simulation game
::fitbit                                         # Fitbit activity tracker companion app
::Flipboard                                      # News and social network aggregator styled as a magazine
::HiddenCity                                     # Hidden object puzzle adventure game
::HULULLC.HULUPLUS                               # Hulu streaming service app
::iHeartRadio                                    # Internet radio streaming app
::Instagram                                      # Instagram social media app
::king.com.BubbleWitch3Saga                      # Puzzle game from King
::king.com.CandyCrushSaga                        # Puzzle game from King
::king.com.CandyCrushSodaSaga                    # Puzzle game from King
::LinkedInforWindows                             # LinkedIn professional networking app
::MarchofEmpires                                 # Strategy game
::Microsoft.3DBuilder                            # Basic 3D modeling software
::Microsoft.549981C3F5F10                        # Microsoft Cortana voice assistant (Discontinued)
::Microsoft.BingFinance                          # Finance news and tracking via Bing (Discontinued)
::Microsoft.BingFoodAndDrink                     # Recipes and food news via Bing (Discontinued)
::Microsoft.BingHealthAndFitness                 # Health and fitness tracking/news via Bing (Discontinued)
::Microsoft.BingNews                             # News aggregator via Bing (Replaced by Microsoft News/Start)
::Microsoft.BingSearch                           # Web Search from Microsoft Bing (Integrates into Windows Search)
::Microsoft.BingSports                           # Sports news and scores via Bing (Discontinued)
::Microsoft.BingTranslator                       # Translation service via Bing
::Microsoft.BingTravel                           # Travel planning and news via Bing (Discontinued)
::Microsoft.Copilot                              # AI assistant integrated into Windows
::Microsoft.GamingApp                            # Modern Xbox Gaming App, required for installing some PC games
::Microsoft.Getstarted                           # Tips and introductory guide for Windows (Cannot be uninstalled in Windows 11)
::Microsoft.M365Companions                       # Microsoft 365 (Business) Calendar, Files and People mini-apps, these apps may be reinstalled if enabled by your Microsoft 365 admin
::Microsoft.Messaging                            # Messaging app, often integrates with Skype (Largely deprecated)
::Microsoft.Microsoft3DViewer                    # Viewer for 3D models
::Microsoft.MicrosoftJournal                     # Digital note-taking app optimized for pen input
::Microsoft.MicrosoftOfficeHub                   # Hub to access Microsoft Office apps and documents (Precursor to Microsoft 365 app)
::Microsoft.MicrosoftPowerBIForWindows           # Business analytics service client
::Microsoft.MixedReality.Portal                  # Portal for Windows Mixed Reality headsets
::Microsoft.MSPaint                              # Paint 3D (Modern paint application with 3D features)
::Microsoft.NetworkSpeedTest                     # Internet connection speed test utility
::Microsoft.News                                 # News aggregator (Replaced Bing News, now part of Microsoft Start)
::Microsoft.Office.OneNote                       # Digital note-taking app (Universal Windows Platform version)
::Microsoft.Office.Sway                          # Presentation and storytelling app
::Microsoft.OneConnect                           # Mobile Operator management app (Replaced by Mobile Plans)
::Microsoft.OutlookForWindows                    # New Outlook for Windows mail client
::Microsoft.People                               # Required for & included with Mail & Calendar (Contacts management)
::Microsoft.PowerAutomateDesktop                 # Desktop automation tool (RPA)
::Microsoft.Print3D                              # 3D printing preparation software
::Microsoft.SkypeApp                             # Skype communication app, Universal Windows Platform version (Discontinued)
::Microsoft.StartExperiencesApp                  # This app powers Windows Widgets My Feed
::Microsoft.Todos                                # To-do list and task management app
::Microsoft.Whiteboard                           # Digital collaborative whiteboard app
::Microsoft.Windows.DevHome                      # Developer dashboard and tool configuration utility (Discontinued)
::Microsoft.WindowsAlarms                        # Alarms & Clock app
::Microsoft.windowscommunicationsapps            # Mail & Calendar app suite (Discontinued)
::Microsoft.WindowsFeedbackHub                   # App for providing feedback to Microsoft on Windows
::Microsoft.WindowsMaps                          # Mapping and navigation app
::Microsoft.WindowsSoundRecorder                 # Basic audio recording app
::Microsoft.XboxApp                              # Old Xbox Console Companion App (Discontinued)
::Microsoft.ZuneMusic                            # Modern Media Player (Replaced Groove Music, plays local audio/video)
::Microsoft.ZuneVideo                            # Movies & TV app for renting/buying/playing video content (Rebranded as "Films & TV")
::MicrosoftCorporationII.MicrosoftFamily         # Family Safety App for managing family accounts and settings
::MicrosoftCorporationII.QuickAssist             # Remote assistance tool
::Netflix                                        # Netflix streaming service app
::NYTCrossword                                   # New York Times crossword puzzle app
::OneCalendar                                    # Calendar aggregation app
::PandoraMediaInc                                # Pandora music streaming app
::PhototasticCollage                             # Photo collage creation app
::PicsArt-PhotoStudio                            # Photo editing and creative app
::Plex                                           # Media server and player app
::PolarrPhotoEditorAcademicEdition               # Photo editing app (Academic Edition)
::Royal Revolt                                   # Tower defense / strategy game
::Shazam                                         # Music identification app
::Sidia.LiveWallpaper                            # Live wallpaper app
::SlingTV                                        # Live TV streaming service app
::Spotify                                        # Spotify music streaming app
::TikTok                                         # TikTok short-form video app
::TuneInRadio                                    # Internet radio streaming app
::Twitter                                        # Twitter (now X) social media app
::Viber                                          # Messaging and calling app
::WinZipUniversal                                # File compression and extraction utility (Universal Windows Platform version)
::Wunderlist                                     # To-do list app (Acquired by Microsoft, functionality moved to Microsoft To Do)
::XING                                           # Professional networking platform popular in German-speaking countries
::'))
::
::#endregion configs > Windows > Tools > Debloat app list
::
::
::#region configs > Windows > Tools > Debloat preset base
::
::Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET_BASE ([String]('{
::  "Version": "1.0",
::  "Settings": [
::    { "Name": "AddFoldersToThisPC", "Value": false },
::    { "Name": "ClearStart", "Value": false },
::    { "Name": "ClearStartAllUsers", "Value": false },
::    { "Name": "CombineMMTaskbarAlways", "Value": false },
::    { "Name": "CombineMMTaskbarNever", "Value": false },
::    { "Name": "CombineMMTaskbarWhenFull", "Value": false },
::    { "Name": "CombineTaskbarAlways", "Value": false },
::    { "Name": "CombineTaskbarNever", "Value": false },
::    { "Name": "CombineTaskbarWhenFull", "Value": false },
::    { "Name": "CreateRestorePoint", "Value": true },
::    { "Name": "DisableAnimations", "Value": false },
::    { "Name": "DisableBing", "Value": true },
::    { "Name": "DisableBraveBloat", "Value": true },
::    { "Name": "DisableClickToDo", "Value": true },
::    { "Name": "DisableCopilot", "Value": false },
::    { "Name": "DisableDesktopSpotlight", "Value": false },
::    { "Name": "DisableDVR", "Value": false },
::    { "Name": "DisableDragTray", "Value": false },
::    { "Name": "DisableEdgeAds", "Value": true },
::    { "Name": "DisableEdgeAI", "Value": false },
::    { "Name": "DisableFastStartup", "Value": false },
::    { "Name": "DisableGameBarIntegration", "Value": false },
::    { "Name": "DisableLockscreenTips", "Value": false },
::    { "Name": "DisableModernStandbyNetworking", "Value": false },
::    { "Name": "DisableMouseAcceleration", "Value": false },
::    { "Name": "DisableNotepadAI", "Value": false },
::    { "Name": "DisablePaintAI", "Value": false },
::    { "Name": "DisableRecall", "Value": true },
::    { "Name": "DisableSettings365Ads", "Value": true },
::    { "Name": "DisableSettingsHome", "Value": false },
::    { "Name": "DisableStartPhoneLink", "Value": false },
::    { "Name": "DisableStartRecommended", "Value": false },
::    { "Name": "DisableStickyKeys", "Value": false },
::    { "Name": "DisableSuggestions", "Value": true },
::    { "Name": "DisableTelemetry", "Value": true },
::    { "Name": "DisableTransparency", "Value": false },
::    { "Name": "DisableWidgets", "Value": false },
::    { "Name": "EnableDarkMode", "Value": false },
::    { "Name": "EnableEndTask", "Value": true },
::    { "Name": "EnableLastActiveClick", "Value": false },
::    { "Name": "ExplorerToDownloads", "Value": false },
::    { "Name": "ExplorerToHome", "Value": false },
::    { "Name": "ExplorerToOneDrive", "Value": false },
::    { "Name": "ExplorerToThisPC", "Value": false },
::    { "Name": "ForceRemoveEdge", "Value": false },
::    { "Name": "Hide3dObjects", "Value": false },
::    { "Name": "HideChat", "Value": false },
::    { "Name": "HideDupliDrive", "Value": false },
::    { "Name": "HideGallery", "Value": false },
::    { "Name": "HideGiveAccessTo", "Value": false },
::    { "Name": "HideHome", "Value": false },
::    { "Name": "HideIncludeInLibrary", "Value": false },
::    { "Name": "HideMusic", "Value": false },
::    { "Name": "HideOnedrive", "Value": false },
::    { "Name": "HideSearchTb", "Value": false },
::    { "Name": "HideShare", "Value": false },
::    { "Name": "HideTaskview", "Value": false },
::    { "Name": "MMTaskbarModeActive", "Value": false },
::    { "Name": "MMTaskbarModeAll", "Value": false },
::    { "Name": "MMTaskbarModeMainActive", "Value": false },
::    { "Name": "RevertContextMenu", "Value": false },
::    { "Name": "ShowHiddenFolders", "Value": true },
::    { "Name": "ShowKnownFileExt", "Value": false },
::    { "Name": "ShowSearchBoxTb", "Value": false },
::    { "Name": "ShowSearchIconTb", "Value": false },
::    { "Name": "ShowSearchLabelTb", "Value": false },
::    { "Name": "TaskbarAlignLeft", "Value": false }
::  ]
::}
::'))
::
::#endregion configs > Windows > Tools > Debloat preset base
::
::
::#region configs > Windows > Tools > Debloat preset personalisation
::
::Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET_PERSONALISATION ([String]('{
::  "Version": "1.0",
::  "Settings": [
::    { "Name": "AddFoldersToThisPC", "Value": false },
::    { "Name": "ClearStart", "Value": false },
::    { "Name": "ClearStartAllUsers", "Value": false },
::    { "Name": "CombineMMTaskbarAlways", "Value": false },
::    { "Name": "CombineMMTaskbarNever", "Value": false },
::    { "Name": "CombineMMTaskbarWhenFull", "Value": true },
::    { "Name": "CombineTaskbarAlways", "Value": false },
::    { "Name": "CombineTaskbarNever", "Value": false },
::    { "Name": "CombineTaskbarWhenFull", "Value": true },
::    { "Name": "CreateRestorePoint", "Value": true },
::    { "Name": "DisableAnimations", "Value": false },
::    { "Name": "DisableBing", "Value": true },
::    { "Name": "DisableBraveBloat", "Value": true },
::    { "Name": "DisableClickToDo", "Value": true },
::    { "Name": "DisableCopilot", "Value": true },
::    { "Name": "DisableDesktopSpotlight", "Value": false },
::    { "Name": "DisableDVR", "Value": false },
::    { "Name": "DisableDragTray", "Value": false },
::    { "Name": "DisableEdgeAds", "Value": true },
::    { "Name": "DisableEdgeAI", "Value": false },
::    { "Name": "DisableFastStartup", "Value": false },
::    { "Name": "DisableGameBarIntegration", "Value": false },
::    { "Name": "DisableLockscreenTips", "Value": true },
::    { "Name": "DisableModernStandbyNetworking", "Value": false },
::    { "Name": "DisableMouseAcceleration", "Value": false },
::    { "Name": "DisableNotepadAI", "Value": false },
::    { "Name": "DisablePaintAI", "Value": false },
::    { "Name": "DisableRecall", "Value": true },
::    { "Name": "DisableSettings365Ads", "Value": true },
::    { "Name": "DisableSettingsHome", "Value": false },
::    { "Name": "DisableStartPhoneLink", "Value": false },
::    { "Name": "DisableStartRecommended", "Value": true },
::    { "Name": "DisableStickyKeys", "Value": false },
::    { "Name": "DisableSuggestions", "Value": true },
::    { "Name": "DisableTelemetry", "Value": true },
::    { "Name": "DisableTransparency", "Value": false },
::    { "Name": "DisableWidgets", "Value": true },
::    { "Name": "EnableDarkMode", "Value": false },
::    { "Name": "EnableEndTask", "Value": true },
::    { "Name": "EnableLastActiveClick", "Value": false },
::    { "Name": "ExplorerToDownloads", "Value": false },
::    { "Name": "ExplorerToHome", "Value": false },
::    { "Name": "ExplorerToOneDrive", "Value": false },
::    { "Name": "ExplorerToThisPC", "Value": true },
::    { "Name": "ForceRemoveEdge", "Value": false },
::    { "Name": "Hide3dObjects", "Value": false },
::    { "Name": "HideChat", "Value": false },
::    { "Name": "HideDupliDrive", "Value": false },
::    { "Name": "HideGallery", "Value": false },
::    { "Name": "HideGiveAccessTo", "Value": false },
::    { "Name": "HideHome", "Value": false },
::    { "Name": "HideIncludeInLibrary", "Value": false },
::    { "Name": "HideMusic", "Value": false },
::    { "Name": "HideOnedrive", "Value": false },
::    { "Name": "HideSearchTb", "Value": false },
::    { "Name": "HideShare", "Value": false },
::    { "Name": "HideTaskview", "Value": false },
::    { "Name": "MMTaskbarModeActive", "Value": false },
::    { "Name": "MMTaskbarModeAll", "Value": false },
::    { "Name": "MMTaskbarModeMainActive", "Value": false },
::    { "Name": "RevertContextMenu", "Value": true },
::    { "Name": "ShowHiddenFolders", "Value": true },
::    { "Name": "ShowKnownFileExt", "Value": false },
::    { "Name": "ShowSearchBoxTb", "Value": false },
::    { "Name": "ShowSearchIconTb", "Value": false },
::    { "Name": "ShowSearchLabelTb", "Value": true },
::    { "Name": "TaskbarAlignLeft", "Value": true }
::  ]
::}
::'))
::
::#endregion configs > Windows > Tools > Debloat preset personalisation
::
::
::#region configs > Windows > Tools > OOShutUp10
::
::Set-Variable -Option Constant CONFIG_OOSHUTUP10 ([String]('P001	+	# Disable sharing of handwriting data (Category: Privacy)
::P002	+	# Disable sharing of handwriting error reports (Category: Privacy)
::P003	+	# Disable Inventory Collector (Category: Privacy)
::P004	+	# Disable camera in logon screen (Category: Privacy)
::P005	+	# Disable and reset Advertising ID and info for the machine (Category: Privacy)
::P006	+	# Disable and reset Advertising ID and info for current user (Category: Privacy)
::P008	+	# Disable transmission of typing information (Category: Privacy)
::P026	+	# Disable advertisements via Bluetooth (Category: Privacy)
::P027	+	# Disable the Windows Customer Experience Improvement Program (Category: Privacy)
::P028	-	# Disable backup of text messages into the cloud (Category: Privacy)
::P064	+	# Disable suggestions in the timeline (Category: Privacy)
::P065	+	# Disable suggestions in Start (Category: Privacy)
::P066	+	# Disable tips, tricks, and suggestions when using Windows (Category: Privacy)
::P067	+	# Disable showing suggested content in the Settings app (Category: Privacy)
::P070	+	# Disable the possibility of suggesting to finish the setup of the device (Category: Privacy)
::P069	+	# Disable Windows Error Reporting (Category: Privacy)
::P009	-	# Disable biometrical features (Category: Privacy)
::P010	-	# Disable app notifications (Category: Privacy)
::P015	-	# Disable access to local language for browsers (Category: Privacy)
::P068	-	# Disable text suggestions when typing on the software keyboard (Category: Privacy)
::P016	-	# Disable sending URLs from apps to Windows Store (Category: Privacy)
::A001	+	# Disable recordings of user activity (Category: Activity History and Clipboard)
::A002	+	# Disable storing users" activity history on this device (Category: Activity History and Clipboard)
::A003	+	# Disable the submission of user activities to Microsoft (Category: Activity History and Clipboard)
::A004	+	# Disable storage of clipboard history for whole machine (Category: Activity History and Clipboard)
::A006	-	# Disable storage of clipboard history for current user (Category: Activity History and Clipboard)
::A005	-	# Disable the transfer of the clipboard to other devices via the cloud (Category: Activity History and Clipboard)
::P007	+	# Disable app access to user account information on this device (Category: App Privacy)
::P036	+	# Disable app access to user account information for current user (Category: App Privacy)
::P025	+	# Disable Windows tracking of app starts (Category: App Privacy)
::P033	+	# Disable app access to diagnostics information on this device (Category: App Privacy)
::P023	+	# Disable app access to diagnostics information for current user (Category: App Privacy)
::P056	-	# Disable app access to device location on this device (Category: App Privacy)
::P057	-	# Disable app access to device location for current user (Category: App Privacy)
::P012	-	# Disable app access to camera on this device (Category: App Privacy)
::P034	-	# Disable app access to camera for current user (Category: App Privacy)
::P013	-	# Disable app access to microphone on this device (Category: App Privacy)
::P035	-	# Disable app access to microphone for current user (Category: App Privacy)
::P062	-	# Disable app access to use voice activation for current user (Category: App Privacy)
::P063	-	# Disable app access to use voice activation when device is locked for current user (Category: App Privacy)
::P081	-	# Disable the standard app for the headset button (Category: App Privacy)
::P047	-	# Disable app access to notifications on this device (Category: App Privacy)
::P019	-	# Disable app access to notifications for current user (Category: App Privacy)
::P048	-	# Disable app access to motion on this device (Category: App Privacy)
::P049	-	# Disable app access to movements for current user (Category: App Privacy)
::P020	-	# Disable app access to contacts on this device (Category: App Privacy)
::P037	-	# Disable app access to contacts for current user (Category: App Privacy)
::P011	-	# Disable app access to calendar on this device (Category: App Privacy)
::P038	-	# Disable app access to calendar for current user (Category: App Privacy)
::P050	-	# Disable app access to phone calls on this device (Category: App Privacy)
::P051	-	# Disable app access to phone calls for current user (Category: App Privacy)
::P018	-	# Disable app access to call history on this device (Category: App Privacy)
::P039	-	# Disable app access to call history for current user (Category: App Privacy)
::P021	-	# Disable app access to email on this device (Category: App Privacy)
::P040	-	# Disable app access to email for current user (Category: App Privacy)
::P022	-	# Disable app access to tasks on this device (Category: App Privacy)
::P041	-	# Disable app access to tasks for current user (Category: App Privacy)
::P014	-	# Disable app access to messages on this device (Category: App Privacy)
::P042	-	# Disable app access to messages for current user (Category: App Privacy)
::P052	-	# Disable app access to radios on this device (Category: App Privacy)
::P053	-	# Disable app access to radios for current user (Category: App Privacy)
::P054	-	# Disable app access to unpaired devices on this device (Category: App Privacy)
::P055	-	# Disable app access to unpaired devices for current user (Category: App Privacy)
::P029	-	# Disable app access to documents on this device (Category: App Privacy)
::P043	-	# Disable app access to documents for current user (Category: App Privacy)
::P030	-	# Disable app access to images on this device (Category: App Privacy)
::P044	-	# Disable app access to images for current user (Category: App Privacy)
::P031	-	# Disable app access to videos on this device (Category: App Privacy)
::P045	-	# Disable app access to videos for current user (Category: App Privacy)
::P032	-	# Disable app access to the file system on this device (Category: App Privacy)
::P046	-	# Disable app access to the file system for current user (Category: App Privacy)
::P058	-	# Disable app access to wireless equipment on this device (Category: App Privacy)
::P059	-	# Disable app access to wireless technology for current user (Category: App Privacy)
::P060	-	# Disable app access to eye tracking on this device (Category: App Privacy)
::P061	-	# Disable app access to eye tracking for current user (Category: App Privacy)
::P071	-	# Disable the ability for apps to take screenshots on this device (Category: App Privacy)
::P072	-	# Disable the ability for apps to take screenshots for current user (Category: App Privacy)
::P073	-	# Disable the ability for desktop apps to take screenshots for current user (Category: App Privacy)
::P074	-	# Disable the ability for apps to take screenshots without borders on this device (Category: App Privacy)
::P075	-	# Disable the ability for apps to take screenshots without borders for current user (Category: App Privacy)
::P076	-	# Disable the ability for desktop apps to take screenshots without margins for current user (Category: App Privacy)
::P077	-	# Disable app access to music libraries on this device (Category: App Privacy)
::P078	-	# Disable app access to music libraries for current user (Category: App Privacy)
::P079	-	# Disable app access to downloads folder on this device (Category: App Privacy)
::P080	-	# Disable app access to downloads folder for current user (Category: App Privacy)
::P024	-	# Prohibit apps from running in the background (Category: App Privacy)
::S001	-	# Disable password reveal button (Category: Security)
::S002	+	# Disable user steps recorder (Category: Security)
::S003	+	# Disable telemetry (Category: Security)
::S008	-	# Disable Internet access of Windows Media Digital Rights Management (DRM) (Category: Security)
::E101	+	# Disable tracking in the web (Category: Microsoft Edge (new version based on Chromium))
::E201	+	# Disable tracking in the web (Category: Microsoft Edge (new version based on Chromium))
::E115	-	# Disable check for saved payment methods by sites (Category: Microsoft Edge (new version based on Chromium))
::E215	-	# Disable check for saved payment methods by sites (Category: Microsoft Edge (new version based on Chromium))
::E118	+	# Disable personalizing advertising, search, news and other services (Category: Microsoft Edge (new version based on Chromium))
::E218	+	# Disable personalizing advertising, search, news and other services (Category: Microsoft Edge (new version based on Chromium))
::E107	-	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (new version based on Chromium))
::E207	-	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (new version based on Chromium))
::E111	+	# Disable user feedback in toolbar (Category: Microsoft Edge (new version based on Chromium))
::E211	+	# Disable user feedback in toolbar (Category: Microsoft Edge (new version based on Chromium))
::E112	-	# Disable storing and autocompleting of credit card data on websites (Category: Microsoft Edge (new version based on Chromium))
::E212	-	# Disable storing and autocompleting of credit card data on websites (Category: Microsoft Edge (new version based on Chromium))
::E109	-	# Disable form suggestions (Category: Microsoft Edge (new version based on Chromium))
::E209	-	# Disable form suggestions (Category: Microsoft Edge (new version based on Chromium))
::E121	-	# Disable suggestions from local providers (Category: Microsoft Edge (new version based on Chromium))
::E221	-	# Disable suggestions from local providers (Category: Microsoft Edge (new version based on Chromium))
::E103	-	# Disable search and website suggestions (Category: Microsoft Edge (new version based on Chromium))
::E203	-	# Disable search and website suggestions (Category: Microsoft Edge (new version based on Chromium))
::E123	+	# Disable shopping assistant in Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E223	+	# Disable shopping assistant in Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E124	-	# Disable Edge bar (Category: Microsoft Edge (new version based on Chromium))
::E224	+	# Disable Edge bar (Category: Microsoft Edge (new version based on Chromium))
::E128	-	# Disable Sidebar in Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E228	-	# Disable Sidebar in Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E129	-	# Disable the Microsoft Account Sign-In Button (Category: Microsoft Edge (new version based on Chromium))
::E229	-	# Disable the Microsoft Account Sign-In Button (Category: Microsoft Edge (new version based on Chromium))
::E130	-	# Disable Enhanced Spell Checking (Category: Microsoft Edge (new version based on Chromium))
::E230	-	# Disable Enhanced Spell Checking (Category: Microsoft Edge (new version based on Chromium))
::E119	-	# Disable use of web service to resolve navigation errors (Category: Microsoft Edge (new version based on Chromium))
::E219	-	# Disable use of web service to resolve navigation errors (Category: Microsoft Edge (new version based on Chromium))
::E120	-	# Disable suggestion of similar sites when website cannot be found (Category: Microsoft Edge (new version based on Chromium))
::E220	-	# Disable suggestion of similar sites when website cannot be found (Category: Microsoft Edge (new version based on Chromium))
::E122	-	# Disable preload of pages for faster browsing and searching (Category: Microsoft Edge (new version based on Chromium))
::E222	-	# Disable preload of pages for faster browsing and searching (Category: Microsoft Edge (new version based on Chromium))
::E125	-	# Disable saving passwords for websites (Category: Microsoft Edge (new version based on Chromium))
::E225	-	# Disable saving passwords for websites (Category: Microsoft Edge (new version based on Chromium))
::E126	-	# Disable site safety services for more information about a visited website (Category: Microsoft Edge (new version based on Chromium))
::E226	-	# Disable site safety services for more information about a visited website (Category: Microsoft Edge (new version based on Chromium))
::E131	-	# Disable automatic redirection from Internet Explorer to Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E106	-	# Disable SmartScreen Filter (Category: Microsoft Edge (new version based on Chromium))
::E206	-	# Disable SmartScreen Filter (Category: Microsoft Edge (new version based on Chromium))
::E127	-	# Disable typosquatting checker for site addresses (Category: Microsoft Edge (new version based on Chromium))
::E227	-	# Disable typosquatting checker for site addresses (Category: Microsoft Edge (new version based on Chromium))
::E001	+	# Disable tracking in the web (Category: Microsoft Edge (legacy version))
::E002	-	# Disable page prediction (Category: Microsoft Edge (legacy version))
::E003	-	# Disable search and website suggestions (Category: Microsoft Edge (legacy version))
::E008	-	# Disable Cortana in Microsoft Edge (Category: Microsoft Edge (legacy version))
::E007	-	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (legacy version))
::E010	-	# Disable showing search history (Category: Microsoft Edge (legacy version))
::E011	+	# Disable user feedback in toolbar (Category: Microsoft Edge (legacy version))
::E012	-	# Disable storing and autocompleting of credit card data on websites (Category: Microsoft Edge (legacy version))
::E009	-	# Disable form suggestions (Category: Microsoft Edge (legacy version))
::E004	-	# Disable sites saving protected media licenses on my device (Category: Microsoft Edge (legacy version))
::E005	-	# Do not optimize web search results on the task bar for screen reader (Category: Microsoft Edge (legacy version))
::E013	+	# Disable Microsoft Edge launch in the background (Category: Microsoft Edge (legacy version))
::E014	-	# Disable loading the start and new tab pages in the background (Category: Microsoft Edge (legacy version))
::E006	-	# Disable SmartScreen Filter (Category: Microsoft Edge (legacy version))
::F002	+	# Disable telemetry for Microsoft Office (Category: Microsoft Office)
::F014	+	# Disable diagnostic data submission (Category: Microsoft Office)
::F015	+	# Disable participation in the Customer Experience Improvement Program (Category: Microsoft Office)
::F016	+	# Disable the display of LinkedIn information (Category: Microsoft Office)
::F001	-	# Disable inline text prediction in mails (Category: Microsoft Office)
::F003	+	# Disable logging for Microsoft Office Telemetry Agent (Category: Microsoft Office)
::F004	+	# Disable upload of data for Microsoft Office Telemetry Agent (Category: Microsoft Office)
::F005	+	# Obfuscate file names when uploading telemetry data (Category: Microsoft Office)
::F007	+	# Disable Microsoft Office surveys (Category: Microsoft Office)
::F008	+	# Disable feedback to Microsoft (Category: Microsoft Office)
::F009	+	# Disable Microsoft"s feedback tracking (Category: Microsoft Office)
::F017	+	# Disable Microsoft"s feedback tracking (Category: Microsoft Office)
::F006	-	# Disable automatic receipt of updates (Category: Microsoft Office)
::F010	-	# Disable connected experiences in Office (Category: Microsoft Office)
::F011	-	# Disable connected experiences with content analytics (Category: Microsoft Office)
::F012	-	# Disable online content downloading for connected experiences (Category: Microsoft Office)
::F013	-	# Disable optional connected experiences in Office (Category: Microsoft Office)
::Y001	-	# Disable synchronization of all settings (Category: Synchronization of Windows Settings)
::Y002	-	# Disable synchronization of design settings (Category: Synchronization of Windows Settings)
::Y003	-	# Disable synchronization of browser settings (Category: Synchronization of Windows Settings)
::Y004	-	# Disable synchronization of credentials (passwords) (Category: Synchronization of Windows Settings)
::Y005	-	# Disable synchronization of language settings (Category: Synchronization of Windows Settings)
::Y006	-	# Disable synchronization of accessibility settings (Category: Synchronization of Windows Settings)
::Y007	-	# Disable synchronization of advanced Windows settings (Category: Synchronization of Windows Settings)
::C012	-	# Disable and reset Cortana (Category: Cortana (Personal Assistant))
::C002	-	# Disable Input Personalization (Category: Cortana (Personal Assistant))
::C013	-	# Disable online speech recognition (Category: Cortana (Personal Assistant))
::C007	+	# Cortana and search are disallowed to use location (Category: Cortana (Personal Assistant))
::C008	+	# Disable web search from Windows Desktop Search (Category: Cortana (Personal Assistant))
::C009	+	# Disable display web results in Search (Category: Cortana (Personal Assistant))
::C010	-	# Disable download and updates of speech recognition and speech synthesis models (Category: Cortana (Personal Assistant))
::C011	-	# Disable cloud search (Category: Cortana (Personal Assistant))
::C014	-	# Disable Cortana above lock screen (Category: Cortana (Personal Assistant))
::C015	+	# Disable the search highlights in the taskbar (Category: Cortana (Personal Assistant))
::C101	+	# Disable the Windows Copilot (Category: Windows AI)
::C201	+	# Disable the Windows Copilot (Category: Windows AI)
::C204	+	# Disable the provision of recall functionality to all users (Category: Windows AI)
::C205	-	# Disable the Image Creator in Microsoft Paint (Category: Windows AI)
::C102	+	# Disable the Copilot button from the taskbar (Category: Windows AI)
::C103	+	# Disable Windows Copilot+ Recall (Category: Windows AI)
::C203	+	# Disable Windows Copilot+ Recall (Category: Windows AI)
::C206	-	# Disable Cocreator in Microsoft Paint (Category: Windows AI)
::C207	-	# Disable AI-powered image fill in Microsoft Paint (Category: Windows AI)
::L001	-	# Disable functionality to locate the system (Category: Location Services)
::L003	+	# Disable scripting functionality to locate the system (Category: Location Services)
::L004	-	# Disable sensors for locating the system and its orientation (Category: Location Services)
::L005	-	# Disable Windows Geolocation Service (Category: Location Services)
::U001	+	# Disable application telemetry (Category: User Behavior)
::U004	+	# Disable diagnostic data from customizing user experiences for whole machine (Category: User Behavior)
::U005	+	# Disable the use of diagnostic data for a tailor-made user experience for current user (Category: User Behavior)
::U006	+	# Disable diagnostic log collection (Category: User Behavior)
::U007	+	# Disable downloading of OneSettings configuration settings (Category: User Behavior)
::W001	-	# Disable Windows Update via peer-to-peer (Category: Windows Update)
::W011	-	# Disable updates to the speech recognition and speech synthesis modules. (Category: Windows Update)
::W004	-	# Activate deferring of upgrades (Category: Windows Update)
::W005	-	# Disable automatic downloading manufacturers" apps and icons for devices (Category: Windows Update)
::W010	-	# Disable automatic driver updates through Windows Update (Category: Windows Update)
::W009	-	# Disable automatic app updates through Windows Update (Category: Windows Update)
::P017	-	# Disable Windows dynamic configuration and update rollouts (Category: Windows Update)
::W006	-	# Disable automatic Windows Updates (Category: Windows Update)
::W008	-	# Disable Windows Updates for other products (e.g. Microsoft Office) (Category: Windows Update)
::M006	+	# Disable occasionally showing app suggestions in Start menu (Category: Windows Explorer)
::M011	-	# Do not show recently opened items in Jump Lists on "Start" or the taskbar (Category: Windows Explorer)
::M010	+	# Disable ads in Windows Explorer/OneDrive (Category: Windows Explorer)
::O003	+	# Disable OneDrive access to network before login (Category: Windows Explorer)
::O001	-	# Disable Microsoft OneDrive (Category: Windows Explorer)
::S012	+	# Disable Microsoft SpyNet membership (Category: Microsoft Defender and Microsoft SpyNet)
::S013	-	# Disable submitting data samples to Microsoft (Category: Microsoft Defender and Microsoft SpyNet)
::S014	-	# Disable reporting of malware infection information (Category: Microsoft Defender and Microsoft SpyNet)
::K001	-	# Disable Windows Spotlight (Category: Lock Screen)
::K002	+	# Disable fun facts, tips, tricks, and more on your lock screen (Category: Lock Screen)
::K005	-	# Disable notifications on lock screen (Category: Lock Screen)
::D001	-	# Disable access to mobile devices (Category: Mobile Devices)
::D002	-	# Disable Phone Link app (Category: Mobile Devices)
::D003	-	# Disable showing suggestions for using mobile devices with Windows (Category: Mobile Devices)
::D104	-	# Disable connecting the PC to mobile devices (Category: Mobile Devices)
::M025	+	# Disable search with AI in search box (Category: Search)
::M003	+	# Disable extension of Windows search with Bing (Category: Search)
::M015	+	# Disable People icon in the taskbar (Category: Taskbar)
::M016	-	# Disable search box in task bar (Category: Taskbar)
::M017	+	# Disable "Meet now" in the task bar on this device (Category: Taskbar)
::M018	+	# Disable "Meet now" in the task bar for current user (Category: Taskbar)
::M019	+	# Disable news and interests in the task bar on this device (Category: Taskbar)
::M021	+	# Disable widgets in Windows Explorer (Category: Taskbar)
::M022	+	# Disable feedback reminders on this device (Category: Miscellaneous)
::M001	+	# Disable feedback reminders for current user (Category: Miscellaneous)
::M004	+	# Disable automatic installation of recommended Windows Store Apps (Category: Miscellaneous)
::M005	+	# Disable tips, tricks, and suggestions while using Windows (Category: Miscellaneous)
::M024	+	# Disable Windows Media Player Diagnostics (Category: Miscellaneous)
::M012	-	# Disable Key Management Service Online Activation (Category: Miscellaneous)
::M013	-	# Disable automatic download and update of map data (Category: Miscellaneous)
::M014	-	# Disable unsolicited network traffic on the offline maps settings page (Category: Miscellaneous)
::M026	-	# Disable remote assistance connections to this computer (Category: Miscellaneous)
::M027	-	# Disable remote connections to this computer (Category: Miscellaneous)
::M028	+	# Disable the desktop icon for information on "Windows Spotlight" (Category: Miscellaneous)
::N001	-	# Disable Network Connectivity Status Indicator (Category: Miscellaneous)
::'))
::
::#endregion configs > Windows > Tools > OOShutUp10
::
::
::#region configs > Windows > Tools > sdi
::
::Set-Variable -Option Constant CONFIG_SDI ([String]('-checkupdates
::-delextrainfs
::-expertmode
::-filters:166
::-license:1
::-port:443
::-showdrpnames2
::-theme:Metro
::-wndsc:3
::'))
::
::#endregion configs > Windows > Tools > sdi
::
::
::#region configs > Windows > Tools > WinUtil Personalisation
::
::Set-Variable -Option Constant CONFIG_WINUTIL_PERSONALISATION ([String]('                      "WPFTweaksEndTaskOnTaskbar",
::                      "WPFTweaksRightClickMenu",
::                      "WPFTweaksRemoveCopilot",
::'))
::
::#endregion configs > Windows > Tools > WinUtil Personalisation
::
::
::#region configs > Windows > Tools > WinUtil
::
::Set-Variable -Option Constant CONFIG_WINUTIL ([String]('{
::    "WPFTweaks":  [
::                      "WPFTweaksRestorePoint",
::                      "WPFTweaksBraveDebloat",
::                      "WPFTweaksConsumerFeatures",
::                      "WPFTweaksEdgeDebloat",
::                      "WPFTweaksLocation",
::                      "WPFTweaksPowershell7Tele",
::                      "WPFTweaksTelemetry",
::                      "WPFTweaksDeleteTempFiles",
::                      "WPFTweaksDiskCleanup"
::                  ],
::    "Install":  [
::
::                ],
::    "WPFInstall":  [
::
::                   ],
::    "WPFFeature":  [
::                       "WPFFeatureRegBackup"
::                   ]
::}
::'))
::
::#endregion configs > Windows > Tools > WinUtil
::
::
::#region functions > App lifecycle > Exit
::
::function Reset-State {
::    param(
::        [Switch][Parameter(Position = 0)]$Update
::    )
::
::    if (-not $Update) {
::        Remove-File "$PATH_TEMP_DIR\qiiwexc.ps1" -Silent
::    }
::
::    $HOST.UI.RawUI.WindowTitle = $ORIGINAL_WINDOW_TITLE
::    Write-Host ''
::}
::
::function Exit-App {
::    param(
::        [Switch][Parameter(Position = 0)]$Update
::    )
::
::    Write-LogInfo 'Exiting the app...'
::    Reset-State -Update:$Update
::    $FORM.Close()
::}
::
::#endregion functions > App lifecycle > Exit
::
::
::#region functions > App lifecycle > Get-SystemInformation
::
::function Get-SystemInformation {
::    Write-LogInfo 'Current system information:'
::
::    Set-Variable -Option Constant LogIndentLevel ([Int]1)
::
::    Set-Variable -Option Constant Motherboard ([PSObject](Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property Manufacturer, Product))
::    Write-LogInfo "Motherboard: $($Motherboard.Manufacturer) $($Motherboard.Product)" $LogIndentLevel
::
::    Set-Variable -Option Constant BIOS ([PSObject](Get-CimInstance -ClassName CIM_BIOSElement | Select-Object -Property Manufacturer, Name, ReleaseDate))
::    Write-LogInfo "BIOS: $($BIOS.Manufacturer) $($BIOS.Name) (release date: $($BIOS.ReleaseDate))" $LogIndentLevel
::
::    Write-LogInfo "Operation system: $($OPERATING_SYSTEM.Caption)" $LogIndentLevel
::
::    Set-Variable -Option Constant WindowsRelease ([String](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion)
::
::    Write-LogInfo "OS release: v$WindowsRelease" $LogIndentLevel
::    Write-LogInfo "Build number: $($OPERATING_SYSTEM.Version)" $LogIndentLevel
::    Write-LogInfo "OS architecture: $($OPERATING_SYSTEM.OSArchitecture)" $LogIndentLevel
::    Write-LogInfo "OS language: $SYSTEM_LANGUAGE" $LogIndentLevel
::
::    switch ($OFFICE_VERSION) {
::        16 {
::            Set-Variable -Option Constant OfficeYear ([String]'2016 / 2019 / 2021 / 2024')
::        }
::        15 {
::            Set-Variable -Option Constant OfficeYear ([String]'2013')
::        }
::        14 {
::            Set-Variable -Option Constant OfficeYear ([String]'2010')
::        }
::        12 {
::            Set-Variable -Option Constant OfficeYear ([String]'2007')
::        }
::        11 {
::            Set-Variable -Option Constant OfficeYear ([String]'2003')
::        }
::    }
::
::    if ($OfficeYear) {
::        Set-Variable -Option Constant OfficeName ([String]"Microsoft Office $OfficeYear")
::    } else {
::        Set-Variable -Option Constant OfficeName ([String]'Unknown version or not installed')
::    }
::
::    Write-LogInfo "Office version: $OfficeName" $LogIndentLevel
::
::    if ($OFFICE_INSTALL_TYPE) {
::        Write-LogInfo "Office installation type: $OFFICE_INSTALL_TYPE" $LogIndentLevel
::    }
::}
::
::#endregion functions > App lifecycle > Get-SystemInformation
::
::
::#region functions > App lifecycle > Initialize-App
::
::function Initialize-App {
::    $FORM.Activate()
::
::    Write-FormLog ([LogLevel]::INFO) ([String]"[$((Get-Date).ToString())] Initializing...") -NoNewLine
::
::    Get-SystemInformation
::
::    Remove-Directory $PATH_WINUTIL -Silent
::    Remove-Directory $PATH_OOSHUTUP10 -Silent
::    Remove-Directory $PATH_APP_DIR -Silent
::
::    Initialize-AppDirectory
::
::    Update-App
::}
::
::#endregion functions > App lifecycle > Initialize-App
::
::
::#region functions > App lifecycle > Initialize-AppDirectory
::
::function Initialize-AppDirectory {
::    New-Directory $PATH_APP_DIR
::}
::
::#endregion functions > App lifecycle > Initialize-AppDirectory
::
::
::#region functions > App lifecycle > Logger
::
::function Write-LogDebug {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Message,
::        [Int][Parameter(Position = 1)]$Level = 0
::    )
::
::    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::DEBUG) $Message -IndentLevel $Level))
::    Write-Host $FormattedMessage
::}
::
::function Write-LogInfo {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Message,
::        [Int][Parameter(Position = 1)]$Level = 0
::    )
::
::    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::INFO) $Message -IndentLevel $Level))
::    Write-Host $FormattedMessage
::    Write-FormLog ([LogLevel]::INFO) $FormattedMessage
::}
::
::function Write-LogWarning {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Message,
::        [Int][Parameter(Position = 1)]$Level = 0
::    )
::
::    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::WARN) $Message -IndentLevel $Level))
::    Write-Warning $FormattedMessage
::    Write-FormLog ([LogLevel]::WARN) $FormattedMessage
::}
::
::function Write-LogError {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Message,
::        [Int][Parameter(Position = 1)]$Level = 0
::    )
::
::    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::ERROR) $Message -IndentLevel $Level))
::    Write-Error $FormattedMessage
::    Write-FormLog ([LogLevel]::ERROR) $FormattedMessage
::}
::
::function Out-Status {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Status,
::        [Int][Parameter(Position = 1)]$Level = 0
::    )
::
::    Write-LogInfo " > $Status" $Level
::}
::
::
::function Out-Success {
::    param(
::        [Int][Parameter(Position = 0)]$Level = 0
::    )
::
::    Out-Status "Done $(Get-Emoji '2705')" $Level
::}
::
::function Out-Failure {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Message,
::        [Int][Parameter(Position = 1)]$Level = 0
::    )
::
::    Out-Status "$(Get-Emoji '274C') $Message" $Level
::}
::
::
::function Get-Emoji {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Code
::    )
::
::    Set-Variable -Option Constant Emoji ([Convert]::ToInt32($Code, 16))
::
::    return [Char]::ConvertFromUtf32($Emoji)
::}
::
::
::function Format-Message {
::    param(
::        [LogLevel][Parameter(Position = 0, Mandatory)]$Level,
::        [String][Parameter(Position = 1, Mandatory)]$Message,
::        [Int][Parameter(Position = 2)]$IndentLevel = 0
::    )
::
::    switch ($Level) {
::        ([LogLevel]::WARN) {
::            Set-Variable -Option Constant Emoji (Get-Emoji '26A0')
::        }
::        ([LogLevel]::ERROR) {
::            Set-Variable -Option Constant Emoji (Get-Emoji '274C')
::        }
::        Default {}
::    }
::
::    if (-not $ACTIVITIES -or $ACTIVITIES.Count -le 0) {
::        Set-Variable -Option Constant Indent ([Int]$IndentLevel)
::    } else {
::        Set-Variable -Option Constant Indent ([Int]($ACTIVITIES.Count + $IndentLevel))
::    }
::
::    Set-Variable -Option Constant IndentSpaces ([String]$('   ' * $Indent))
::    Set-Variable -Option Constant Date ([String]$((Get-Date).ToString()))
::
::    return ([String]"[$Date]$IndentSpaces$Emoji $Message")
::}
::
::
::function Write-FormLog {
::    param(
::        [LogLevel][Parameter(Position = 0, Mandatory)]$Level,
::        [String][Parameter(Position = 1, Mandatory)]$Message,
::        [Switch][Parameter(Position = 2)]$NoNewLine
::    )
::
::    $LOG.SelectionStart = $LOG.TextLength
::
::    switch ($Level) {
::        ([LogLevel]::WARN) {
::            $LOG.SelectionColor = 'blue'
::        }
::        ([LogLevel]::ERROR) {
::            $LOG.SelectionColor = 'red'
::        }
::        Default {
::            $LOG.SelectionColor = 'black'
::        }
::    }
::
::    if ($NoNewLine) {
::        $LOG.AppendText($Message)
::    } else {
::        $LOG.AppendText("`n$Message")
::    }
::    $LOG.SelectionColor = 'black'
::    $LOG.ScrollToCaret()
::}
::
::#endregion functions > App lifecycle > Logger
::
::
::#region functions > App lifecycle > Progressbar
::
::Set-Variable -Scope Script -Name ACTIVITIES -Value ([Collections.Stack]@())
::Set-Variable -Scope Script -Name CURRENT_TASK -Value $Null
::
::function Invoke-WriteProgress {
::    param(
::        [Int][Parameter(Position = 0, Mandatory)]$Id,
::        [String][Parameter(Position = 1, Mandatory)]$Activity,
::        [Int][Parameter(Position = 2)]$ParentId,
::        [Int][Parameter(Position = 3)]$PercentComplete,
::        [String][Parameter(Position = 4)]$Status,
::        [Switch]$Completed
::    )
::
::    Set-Variable -Name Params -Value ([Hashtable]@{
::            Id       = $Id
::            Activity = $Activity
::        })
::
::    if ($ParentId -gt 0) { $Params.ParentId = $ParentId }
::    if ($Status) { $Params.Status = $Status }
::
::    if ($Completed) {
::        $Params.Completed = $True
::    } else {
::        $Params.PercentComplete = $PercentComplete
::    }
::
::    Write-Progress @Params
::}
::
::function New-Activity {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Activity
::    )
::
::    Write-LogInfo "$Activity..."
::
::    $ACTIVITIES.Push($Activity)
::
::    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)
::
::    if ($TaskLevel -gt 1) {
::        Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
::    } else {
::        Set-Variable -Option Constant ParentId ([Int]0)
::    }
::
::    Invoke-WriteProgress -Id $TaskLevel -Activity $Activity -ParentId $ParentId -PercentComplete 1
::}
::
::function Write-ActivityProgress {
::    param(
::        [Int][Parameter(Position = 0, Mandatory)]$PercentComplete,
::        [String][Parameter(Position = 1)]$Task
::    )
::
::    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)
::
::    if ($TaskLevel -gt 0) {
::        Set-Variable -Option Constant Activity ([String]$ACTIVITIES.Peek())
::
::        if ($TaskLevel -gt 1) {
::            Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
::        } else {
::            Set-Variable -Option Constant ParentId ([Int]0)
::        }
::
::        if ($Task) {
::            Set-Variable -Scope Script CURRENT_TASK ([String]$Task)
::            Write-LogInfo $Task
::        }
::
::        Invoke-WriteProgress -Id $TaskLevel -Activity $Activity -ParentId $ParentId -PercentComplete $PercentComplete -Status $Task
::    }
::}
::
::function Write-ActivityCompleted {
::    param(
::        [Bool][Parameter(Position = 0)]$Success = $True
::    )
::
::    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)
::
::    if ($TaskLevel -gt 0) {
::        Set-Variable -Option Constant Activity ([String]$ACTIVITIES.Pop())
::
::        if ($TaskLevel -gt 1) {
::            Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
::        } else {
::            Set-Variable -Option Constant ParentId ([Int]0)
::        }
::
::        Invoke-WriteProgress -Id $TaskLevel -Activity $Activity -ParentId $ParentId -Completed
::    }
::
::    if ($Success) {
::        Out-Success
::    } else {
::        Out-Failure "$CURRENT_TASK failed"
::    }
::
::    Set-Variable -Scope Script CURRENT_TASK $Null
::}
::
::#endregion functions > App lifecycle > Progressbar
::
::
::#region functions > App lifecycle > Set-CheckboxState
::
::function Set-CheckboxState {
::    param(
::        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$Control,
::        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$Dependant
::    )
::
::    $Dependant.Enabled = $Control.Checked
::
::    if (-not $Dependant.Enabled) {
::        $Dependant.Checked = $False
::    }
::}
::
::#endregion functions > App lifecycle > Set-CheckboxState
::
::
::#region functions > App lifecycle > Set-Icon
::
::function Set-Icon {
::    param(
::        [IconName][Parameter(Position = 0)]$Name
::    )
::
::    switch ($Name) {
::        ([IconName]::Cleanup) {
::            $FORM.Icon = $ICON_CLEANUP
::        }
::        ([IconName]::Download) {
::            $FORM.Icon = $ICON_DOWNLOAD
::        }
::        Default {
::            $FORM.Icon = $ICON_DEFAULT
::        }
::    }
::}
::
::#endregion functions > App lifecycle > Set-Icon
::
::
::#region functions > App lifecycle > Updater
::
::function Update-App {
::    try {
::        Set-Variable -Option Constant AppBatFile ([String]"$PATH_WORKING_DIR\qiiwexc.bat")
::
::        Set-Variable -Option Constant IsUpdateAvailable ([Bool](Get-UpdateAvailability))
::
::        if ($IsUpdateAvailable) {
::            Get-NewVersion $AppBatFile
::
::            Write-LogWarning 'Restarting...'
::
::            Invoke-CustomCommand $AppBatFile
::
::            Exit-App -Update
::        }
::    } catch {
::        Out-Failure "Failed to start new version: $_"
::    }
::}
::
::
::function Get-UpdateAvailability {
::    try {
::        Write-LogInfo 'Checking for updates...'
::
::        if ($DevMode) {
::            Out-Status 'Skipping in dev mode'
::            return
::        }
::
::        if (-not (Test-NetworkConnection)) {
::            return
::        }
::
::        Set-Variable -Option Constant AvailableVersion ([Version](Invoke-WebRequest -UseBasicParsing -Uri 'https://bit.ly/qiiwexc_version').ToString().Trim())
::
::        if ($AvailableVersion -gt $VERSION) {
::            Write-LogWarning "Newer version available: v$AvailableVersion"
::            return $True
::        } else {
::            Out-Status 'No updates available'
::        }
::    } catch {
::        Out-Failure "Failed to check for updates: $_"
::    }
::}
::
::
::function Get-NewVersion {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppBatFile
::    )
::
::    try {
::        Write-LogWarning 'Downloading new version...'
::
::        if (-not (Test-NetworkConnection)) {
::            return
::        }
::
::        Invoke-WebRequest -Uri 'https://bit.ly/qiiwexc_bat' -OutFile $AppBatFile
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to download update: $_"
::    }
::}
::
::#endregion functions > App lifecycle > Updater
::
::
::#region functions > Common > Expand-Zip
::
::function Expand-Zip {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$ZipPath,
::        [Switch]$Temp
::    )
::
::    Write-ActivityProgress 50 "Extracting '$ZipPath'..."
::
::    $Extension = [IO.Path]::GetExtension($ZipPath).ToLower()
::    if ($Extension -notin @('.zip', '.7z')) {
::        throw "Unsupported archive format: $Extension. Supported formats: .zip, .7z"
::    }
::
::    if (-not (Test-Path $ZipPath)) {
::        throw "Archive not found: $ZipPath"
::    }
::
::    Set-Variable -Option Constant ZipName ([String](Split-Path -Leaf $ZipPath -ErrorAction Stop))
::    Set-Variable -Option Constant ExtractionPath ([String]($ZipPath -replace '\.(zip|7z)$', ''))
::    Set-Variable -Option Constant ExtractionDir ([String](Split-Path -Leaf $ExtractionPath -ErrorAction Stop))
::
::    if ($Temp) {
::        Set-Variable -Option Constant TargetPath ([String]$PATH_APP_DIR)
::    } else {
::        Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
::    }
::
::    Set-Variable -Option Constant Executable ([String](Get-ExecutableName $ZipName $ExtractionDir))
::
::    Set-Variable -Option Constant IsDirectory ([Bool]($ExtractionDir -and $Executable -like "$ExtractionDir\*"))
::    Set-Variable -Option Constant TemporaryExe ([String]"$ExtractionPath\$Executable")
::    Set-Variable -Option Constant TargetExe ([String]"$TargetPath\$Executable")
::
::    if (Test-Path $TargetExe) {
::        Write-LogWarning 'Previous extraction found, returning it'
::        return $TargetExe
::    }
::
::    Initialize-AppDirectory
::
::    Remove-File $TemporaryExe
::
::    Remove-Directory $ExtractionPath
::
::    New-Directory $ExtractionPath
::
::    if ($ZipPath.Split('.')[-1].ToLower() -eq 'zip') {
::        Expand-Archive $ZipPath $ExtractionPath -Force -ErrorAction Stop
::    } else {
::        if (-not $SHELL) {
::            Set-Variable -Option Constant -Scope Script SHELL (New-Object -ComObject Shell.Application)
::        }
::
::        foreach ($Item in $SHELL.NameSpace($ZipPath).Items()) {
::            $SHELL.NameSpace($ExtractionPath).CopyHere($Item, 4)
::        }
::    }
::
::    if (-not $IsDirectory) {
::        Move-Item -Force $TemporaryExe $TargetExe -ErrorAction Stop
::        Remove-Directory $ExtractionPath
::    } elseif (-not $Temp) {
::        Remove-Directory "$TargetPath\$ExtractionDir"
::        Move-Item -Force $ExtractionPath $TargetPath -ErrorAction Stop
::    }
::
::    Out-Success
::    Write-LogInfo "Files extracted to '$TargetPath'"
::
::    return $TargetExe
::}
::
::#endregion functions > Common > Expand-Zip
::
::
::#region functions > Common > Find-RunningProcess
::
::function Find-RunningProcess {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$ProcessName
::    )
::
::    return Get-Process -ErrorAction Stop | Where-Object { $_.ProcessName -eq $ProcessName }
::}
::
::#endregion functions > Common > Find-RunningProcess
::
::
::#region functions > Common > Find-RunningScript
::
::function Find-RunningScript {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$CommandLinePart
::    )
::
::    return Get-CimInstance -ClassName Win32_Process -Filter "name='powershell.exe'" | Where-Object { $_.CommandLine -like "*$CommandLinePart*" }
::}
::
::#endregion functions > Common > Find-RunningScript
::
::
::#region functions > Common > Get-ExecutableName
::
::function Get-ExecutableName {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$ZipName,
::        [String][Parameter(Position = 1, Mandatory)]$ExtractionDir
::    )
::
::    switch -Wildcard ($ZipName) {
::        'Office_Installer.zip' {
::            if (-not $OS_64_BIT) {
::                Set-Variable -Option Constant Suffix ([String]' x86')
::            }
::            return "Office Installer$Suffix.exe"
::        }
::        'cpu-z_*' {
::            if ($OS_64_BIT) {
::                Set-Variable -Option Constant Suffix ([String]'64')
::            } else {
::                Set-Variable -Option Constant Suffix ([String]'32')
::            }
::            return "$ExtractionDir\cpuz_x$Suffix.exe"
::        }
::        'SDI_*' {
::            if ($OS_64_BIT) {
::                Set-Variable -Option Constant Suffix ([String]'64')
::            }
::            return "$ExtractionDir\SDI$Suffix-drv.exe"
::        }
::        'ventoy*' {
::            return "$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe"
::        }
::        'Victoria*' {
::            return "$ExtractionDir\$ExtractionDir\Victoria.exe"
::        }
::        Default {
::            return ($ZipName -replace '\.zip$', '') + '.exe'
::        }
::    }
::}
::
::#endregion functions > Common > Get-ExecutableName
::
::
::#region functions > Common > Invoke-CustomCommand
::
::function Invoke-CustomCommand {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Command,
::        [Switch]$Elevated,
::        [Switch]$HideWindow
::    )
::
::    if ($Elevated) {
::        Set-Variable -Option Constant Verb ([String]'RunAs')
::    } else {
::        Set-Variable -Option Constant Verb ([String]'Open')
::    }
::
::    if ($HideWindow) {
::        Set-Variable -Option Constant WindowStyle ([String]'Hidden')
::    } else {
::        Set-Variable -Option Constant WindowStyle ([String]'Normal')
::    }
::
::    Start-Process PowerShell $Command -Verb $Verb -WindowStyle $WindowStyle -ErrorAction Stop
::}
::
::#endregion functions > Common > Invoke-CustomCommand
::
::
::#region functions > Common > Network
::
::function Get-NetworkAdapter {
::    return (Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' -OperationTimeoutSec 15)
::}
::
::function Test-NetworkConnection {
::    try {
::        Set-Variable -Option Constant IsConnected ([Boolean](Get-NetworkAdapter))
::    } catch [Microsoft.Management.Infrastructure.CimException] {
::        if ($_.Exception.Message -match 'timeout|timed out') {
::            Out-Failure 'Network check timed out'
::        } else {
::            Out-Failure "Network check failed: $_"
::        }
::        return $False
::    } catch {
::        Out-Failure "Network check failed: $_"
::        return $False
::    }
::
::    if (-not $IsConnected) {
::        Out-Failure 'Computer is not connected to the Internet'
::    }
::
::    return $IsConnected
::}
::
::#endregion functions > Common > Network
::
::
::#region functions > Common > New-Directory
::
::function New-Directory {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Path
::    )
::
::    $Null = New-Item -Force -ItemType Directory $Path -ErrorAction Stop
::}
::
::#endregion functions > Common > New-Directory
::
::
::#region functions > Common > Open-InBrowser
::
::function Open-InBrowser {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Url
::    )
::
::    try {
::        Write-LogInfo "Opening URL in the default browser: $Url"
::        Start-Process $Url -ErrorAction Stop
::    } catch {
::        Out-Failure "Could not open the URL: $_"
::    }
::}
::
::#endregion functions > Common > Open-InBrowser
::
::
::#region functions > Common > Remove-Directory
::
::function Remove-Directory {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$DirectoryPath,
::        [Switch]$Silent
::    )
::
::    if (Test-Path $DirectoryPath) {
::        if ($Silent) {
::            Remove-Item -Force -Recurse $DirectoryPath -ErrorAction Ignore
::        } else {
::            Remove-Item -Force -Recurse $DirectoryPath
::        }
::    }
::}
::
::#endregion functions > Common > Remove-Directory
::
::
::#region functions > Common > Remove-File
::
::function Remove-File {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$FilePath,
::        [Switch]$Silent
::    )
::
::    if (Test-Path $FilePath) {
::        if ($Silent) {
::            Remove-Item -Force $FilePath -ErrorAction Ignore
::        } else {
::            Remove-Item -Force $FilePath
::        }
::    }
::}
::
::#endregion functions > Common > Remove-File
::
::
::#region functions > Common > Start-Download
::
::function Start-Download {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$URL,
::        [String][Parameter(Position = 1)]$SaveAs,
::        [Switch]$Temp
::    )
::
::    Write-ActivityProgress 10 "Downloading from $URL"
::
::    Set-Variable -Option Constant MaxRetries ([Int]3)
::
::    if ($SaveAs) {
::        Set-Variable -Option Constant FileName ([String]$SaveAs)
::    } else {
::        Set-Variable -Option Constant FileName ([String](Split-Path -Leaf $URL -ErrorAction Stop))
::    }
::
::    Set-Variable -Option Constant TempPath ([String]"$PATH_APP_DIR\$FileName")
::
::    if ($Temp) {
::        Set-Variable -Option Constant SavePath ([String]$TempPath)
::    } else {
::        Set-Variable -Option Constant SavePath ([String]"$PATH_WORKING_DIR\$FileName")
::    }
::
::    if (Test-Path $SavePath) {
::        Write-LogWarning 'Previous download found, returning it'
::        return $SavePath
::    }
::
::    if (-not (Test-NetworkConnection)) {
::        throw 'No network connection detected'
::    }
::
::    Initialize-AppDirectory
::
::    Write-ActivityProgress 20
::
::    [Int]$RetryCount = 0
::    [Bool]$DownloadSuccess = $False
::
::    while (-not $DownloadSuccess -and $RetryCount -lt $MaxRetries) {
::        try {
::            $RetryCount++
::            if ($RetryCount -gt 1) {
::                Write-LogWarning "Download attempt $RetryCount of $MaxRetries"
::                Start-Sleep -Seconds 2
::            }
::
::            Start-BitsTransfer -Source $URL -Destination $TempPath -Dynamic -ErrorAction Stop
::            $DownloadSuccess = $True
::        } catch {
::            if ($RetryCount -ge $MaxRetries) {
::                throw "Download failed after $MaxRetries attempts: $_"
::            }
::            Write-LogWarning "Download attempt $RetryCount failed: $_"
::        }
::    }
::
::    if (-not $Temp) {
::        Move-Item -Force $TempPath $SavePath -ErrorAction Stop
::    }
::
::    if (Test-Path $SavePath) {
::        Out-Success
::        return $SavePath
::    } else {
::        throw 'Possibly computer is offline or disk is full'
::    }
::}
::
::#endregion functions > Common > Start-Download
::
::
::#region functions > Common > Start-DownloadUnzipAndRun
::
::function Start-DownloadUnzipAndRun {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$URL,
::        [String][Parameter(Position = 1)]$FileName,
::        [String][Parameter(Position = 2)]$Params,
::        [String]$ConfigFile,
::        [String]$Configuration,
::        [Switch]$Execute,
::        [Switch]$Silent
::    )
::
::    New-Activity 'Download and run'
::    Set-Icon ([IconName]::Download)
::
::    try {
::        Set-Variable -Option Constant UrlEnding ([String]$URL.Split('.')[-1].ToLower())
::        Set-Variable -Option Constant IsArchive ([Bool]($UrlEnding -eq 'zip' -or $UrlEnding -eq '7z'))
::        Set-Variable -Option Constant DownloadedFile ([String](Start-Download $URL $FileName -Temp:($Execute -or $IsArchive)))
::    } catch {
::        Out-Failure "Download failed: $_"
::        Write-ActivityCompleted $False
::        Set-Icon (([IconName]::Default))
::        return
::    }
::
::    if ($DownloadedFile) {
::        if ($IsArchive) {
::            try {
::                Set-Variable -Option Constant Executable ([String](Expand-Zip $DownloadedFile -Temp:$Execute))
::            } catch {
::                Out-Failure "Failed to extract '$DownloadedFile': $_"
::                Write-ActivityCompleted $False
::                Set-Icon (([IconName]::Default))
::                return
::            }
::        } else {
::            Set-Variable -Option Constant Executable ([String]$DownloadedFile)
::        }
::
::        if ($Configuration) {
::            Set-Variable -Option Constant ParentPath ([String](Split-Path -Parent $Executable))
::            Set-Content "$ParentPath\$ConfigFile" $Configuration -NoNewline
::        }
::
::        if ($Execute) {
::            try {
::                Start-Executable $Executable $Params -Silent:$Silent
::            } catch {
::                Out-Failure "Failed to run '$Executable': $_"
::                Write-ActivityCompleted $False
::                Set-Icon (([IconName]::Default))
::                return
::            }
::        }
::    }
::
::    Write-ActivityCompleted
::    Set-Icon (([IconName]::Default))
::}
::
::#endregion functions > Common > Start-DownloadUnzipAndRun
::
::
::#region functions > Common > Start-Executable
::
::function Start-Executable {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Executable,
::        [String][Parameter(Position = 1)]$Switches,
::        [Switch]$Silent
::    )
::
::    Set-Variable -Option Constant ProcessName ([String](Split-Path -Leaf $Executable -ErrorAction Stop) -replace '\.exe$', '')
::    if (Find-RunningProcess $ProcessName) {
::        Write-LogWarning "Process '$ProcessName' is already running"
::        return
::    }
::
::    if ($Switches -and $Silent) {
::        Write-ActivityProgress 90 "Running '$Executable' silently..."
::        Start-Process -Wait $Executable $Switches -ErrorAction Stop
::        Out-Success
::
::        Write-LogDebug "Removing '$Executable'..."
::        Remove-File $Executable -Silent
::        Out-Success
::    } else {
::        Write-ActivityProgress 90 "Running '$Executable'..."
::
::        if ($Switches) {
::            Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable) -ErrorAction Stop
::        } else {
::            Start-Process $Executable -WorkingDirectory (Split-Path $Executable) -ErrorAction Stop
::        }
::    }
::}
::
::#endregion functions > Common > Start-Executable
::
::
::#region functions > Common > types
::
::enum LogLevel {
::    ERROR
::    WARN
::    INFO
::    DEBUG
::}
::
::enum IconName {
::    Default
::    Cleanup
::    Download
::}
::
::#endregion functions > Common > types
::
::
::#region functions > Configuration > Apps > Set-7zipConfiguration
::
::function Set-7zipConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName
::    )
::
::    try {
::        Import-RegistryConfiguration $AppName (Add-SysPrepConfig $CONFIG_7ZIP)
::        Out-Success
::    } catch {
::        Out-Failure "Failed to configure '$AppName': $_"
::    }
::}
::
::#endregion functions > Configuration > Apps > Set-7zipConfiguration
::
::
::#region functions > Configuration > Apps > Set-AnyDeskConfiguration
::
::function Set-AnyDeskConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName
::    )
::
::    try {
::        Set-Variable -Option Constant ConfigPath ([String]"$env:AppData\$AppName\user.conf")
::
::        if (Test-Path $ConfigPath) {
::            Set-Variable -Option Constant CurrentConfig ([String](Get-Content $ConfigPath -Raw -Encoding UTF8 -ErrorAction Stop))
::        } else {
::            Set-Variable -Option Constant CurrentConfig ([String]'')
::        }
::
::        Write-ConfigurationFile $AppName ($CurrentConfig + $CONFIG_ANYDESK) $ConfigPath
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to configure '$AppName': $_"
::    }
::}
::
::#endregion functions > Configuration > Apps > Set-AnyDeskConfiguration
::
::
::#region functions > Configuration > Apps > Set-AppsConfiguration
::
::function Set-AppsConfiguration {
::    param(
::        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$7zip,
::        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$VLC,
::        [Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory)]$AnyDesk,
::        [Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory)]$qBittorrent,
::        [Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory)]$Edge,
::        [Windows.Forms.CheckBox][Parameter(Position = 5, Mandatory)]$Chrome
::    )
::
::    New-Activity 'Configuring apps'
::
::    if ($7zip.Checked) {
::        Write-ActivityProgress 11 "Applying configuration to $($7zip.Text)..."
::        Set-7zipConfiguration $7zip.Text
::    }
::
::    if ($VLC.Checked) {
::        Write-ActivityProgress 22 "Applying configuration to $($VLC.Text)..."
::        Set-VlcConfiguration $VLC.Text
::    }
::
::    if ($AnyDesk.Checked) {
::        Write-ActivityProgress 33 "Applying configuration to $($AnyDesk.Text)..."
::        Set-AnyDeskConfiguration $AnyDesk.Text
::    }
::
::    if ($qBittorrent.Checked) {
::        Write-ActivityProgress 44 "Applying configuration to $($qBittorrent.Text)..."
::        Set-qBittorrentConfiguration $qBittorrent.Text
::    }
::
::    if ($Edge.Checked) {
::        Write-ActivityProgress 55 "Applying configuration to $($Edge.Text)..."
::        Set-MicrosoftEdgeConfiguration $Edge.Text
::    }
::
::    if ($Chrome.Checked) {
::        Write-ActivityProgress 77 "Applying configuration to $($Chrome.Text)..."
::        Set-GoogleChromeConfiguration $Chrome.Text
::    }
::
::    Write-ActivityCompleted
::}
::
::#endregion functions > Configuration > Apps > Set-AppsConfiguration
::
::
::#region functions > Configuration > Apps > Set-GoogleChromeConfiguration
::
::function Set-GoogleChromeConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName
::    )
::
::    try {
::        Set-Variable -Option Constant ProcessName ([String]'chrome')
::
::        Update-BrowserConfiguration $AppName $ProcessName $CONFIG_CHROME_LOCAL_STATE "$env:LocalAppData\Google\Chrome\User Data\Local State"
::        Update-BrowserConfiguration $AppName $ProcessName $CONFIG_CHROME_PREFERENCES "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to configure '$AppName': $_"
::    }
::}
::
::#endregion functions > Configuration > Apps > Set-GoogleChromeConfiguration
::
::
::#region functions > Configuration > Apps > Set-MicrosoftEdgeConfiguration
::
::function Set-MicrosoftEdgeConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName
::    )
::
::    try {
::        Set-Variable -Option Constant ProcessName ([String]'msedge')
::
::        Update-BrowserConfiguration $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$env:LocalAppData\Microsoft\Edge\User Data\Local State"
::        Update-BrowserConfiguration $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$env:LocalAppData\Microsoft\Edge\User Data\Default\Preferences"
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to configure '$AppName': $_"
::    }
::}
::
::#endregion functions > Configuration > Apps > Set-MicrosoftEdgeConfiguration
::
::
::#region functions > Configuration > Apps > Set-qBittorrentConfiguration
::
::function Set-qBittorrentConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName
::    )
::
::    try {
::        if ($SYSTEM_LANGUAGE -match 'ru') {
::            Set-Variable -Option Constant Content ([String]($CONFIG_QBITTORRENT_BASE + $CONFIG_QBITTORRENT_RUSSIAN))
::        } else {
::            Set-Variable -Option Constant Content ([String]($CONFIG_QBITTORRENT_BASE + $CONFIG_QBITTORRENT_ENGLISH))
::        }
::
::        Write-ConfigurationFile $AppName $Content "$env:AppData\$AppName\$AppName.ini"
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to configure '$AppName': $_"
::    }
::}
::
::#endregion functions > Configuration > Apps > Set-qBittorrentConfiguration
::
::
::#region functions > Configuration > Apps > Set-VlcConfiguration
::
::function Set-VlcConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName
::    )
::
::    try {
::        Write-ConfigurationFile $AppName $CONFIG_VLC "$env:AppData\vlc\vlcrc"
::        Out-Success
::    } catch {
::        Out-Failure "Failed to configure '$AppName': $_"
::    }
::}
::
::#endregion functions > Configuration > Apps > Set-VlcConfiguration
::
::
::#region functions > Configuration > Helpers > Add-SysPrepConfig
::
::function Add-SysPrepConfig {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$Config
::    )
::
::    Set-Variable -Option Constant SysprepConfig ([String]($Config.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')))
::
::    return "$SysprepConfig`n$Config"
::}
::
::#endregion functions > Configuration > Helpers > Add-SysPrepConfig
::
::
::#region functions > Configuration > Helpers > Get-UsersRegistryKeys
::
::function Get-UsersRegistryKeys {
::    try {
::        Set-Variable -Option Constant Users ([String[]](Get-Item 'Registry::HKEY_USERS\*' -ErrorAction Stop).Name)
::        return $Users | Where-Object { $_ -match 'S-1-5-21' -and $_ -notmatch '_Classes$' } | ForEach-Object { Split-Path $_ -Leaf }
::    } catch {
::        Write-LogWarning "Failed to retrieve users registry keys: $_"
::        return $()
::    }
::}
::
::#endregion functions > Configuration > Helpers > Get-UsersRegistryKeys
::
::
::#region functions > Configuration > Helpers > Import-RegistryConfiguration
::
::function Import-RegistryConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName,
::        [String[]][Parameter(Position = 1, Mandatory)]$Content
::    )
::
::    Set-Variable -Option Constant LogIndentLevel ([Int]1)
::
::    try {
::        Write-LogInfo "Importing $AppName configuration into registry..." $LogIndentLevel
::
::        Set-Variable -Option Constant RegFilePath ([String]"$PATH_APP_DIR\$AppName.reg")
::
::        Initialize-AppDirectory
::
::        "Windows Registry Editor Version 5.00`n`n" + (-join $Content) | Set-Content $RegFilePath -NoNewline -ErrorAction Stop
::
::        Start-Process -Verb RunAs -Wait 'regedit' "/s `"$RegFilePath`"" -ErrorAction Stop
::
::        Out-Success $LogIndentLevel
::    } catch {
::        Write-LogWarning "Failed to import file into registry: $_" $LogIndentLevel
::        throw $_
::    }
::}
::
::#endregion functions > Configuration > Helpers > Import-RegistryConfiguration
::
::
::#region functions > Configuration > Helpers > Merge-JsonObject
::
::function Merge-JsonObject {
::    param(
::        [Parameter(Position = 0, Mandatory)][AllowNull()]$Source,
::        [Parameter(Position = 1, Mandatory)][AllowNull()]$Extend
::    )
::
::    if ($Source -is [PSCustomObject] -and $Extend -is [PSCustomObject]) {
::        $Merged = [Ordered]@{}
::
::        foreach ($Property in $Source.PSObject.Properties) {
::            if ($Null -eq $Extend.$($Property.Name)) {
::                $Merged[$Property.Name] = $Property.Value
::            } else {
::                $Merged[$Property.Name] = Merge-JsonObject $Property.Value $Extend.$($Property.Name)
::            }
::        }
::
::        foreach ($Property in $Extend.PSObject.Properties) {
::            if ($Null -eq $Source.$($Property.Name)) {
::                $Merged[$Property.Name] = $Property.Value
::            }
::        }
::
::        return $Merged
::    } elseif ($Source -is [Collections.IList] -and $Extend -is [Collections.IList]) {
::        Set-Variable -Option Constant MaxCount ([Math]::Max($Source.Count, $Extend.Count))
::
::        [Collections.IList]$Merged = for ($i = 0; $i -lt $MaxCount; ++$i) {
::            if ($i -ge $Source.Count) {
::                $Extend[$i]
::            } elseif ($i -ge $Extend.Count) {
::                $Source[$i]
::            } else {
::                Merge-JsonObject $Source[$i] $Extend[$i]
::            }
::        }
::
::        return , $Merged
::    } else {
::        return $Extend
::    }
::}
::
::#endregion functions > Configuration > Helpers > Merge-JsonObject
::
::
::#region functions > Configuration > Helpers > Stop-ProcessIfRunning
::
::function Stop-ProcessIfRunning {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$ProcessName
::    )
::
::    Set-Variable -Option Constant LogIndentLevel ([Int]2)
::
::    if (Find-RunningProcess $ProcessName) {
::        Write-LogInfo "Stopping process '$AppName'..." $LogIndentLevel
::        Stop-Process -Name $ProcessName -Force -ErrorAction Stop
::        Out-Success $LogIndentLevel
::    }
::}
::
::#endregion functions > Configuration > Helpers > Stop-ProcessIfRunning
::
::
::#region functions > Configuration > Helpers > Update-BrowserConfiguration
::
::function Update-BrowserConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName,
::        [String][Parameter(Position = 1, Mandatory)]$ProcessName,
::        [String][Parameter(Position = 2, Mandatory)]$Content,
::        [String][Parameter(Position = 3, Mandatory)]$Path
::    )
::
::    Set-Variable -Option Constant LogIndentLevel ([Int]1)
::
::    try {
::        Write-LogInfo "Writing '$AppName' configuration to '$Path'..." $LogIndentLevel
::
::        Stop-ProcessIfRunning $ProcessName
::
::        if (-not (Test-Path $Path)) {
::            Write-LogInfo "'$AppName' profile does not exist. Launching '$AppName' to create it" $LogIndentLevel
::
::            try {
::                Start-Process $ProcessName -ErrorAction Stop
::            } catch {
::                Out-Failure "Couldn't start '$AppName': $_" $LogIndentLevel
::                throw $_
::            }
::
::            for ([Int]$i = 0; $i -lt 5; $i++) {
::                Start-Sleep -Seconds 10
::                if (Test-Path $Path) {
::                    break
::                }
::            }
::        }
::
::        Set-Variable -Option Constant CurrentConfig ([PSCustomObject](Get-Content $Path -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop))
::        Set-Variable -Option Constant ExtendConfig ([PSCustomObject]($Content | ConvertFrom-Json -ErrorAction Stop))
::
::        Set-Variable -Option Constant UpdatedConfig ([String](Merge-JsonObject $CurrentConfig $ExtendConfig -ErrorAction Stop | ConvertTo-Json -Depth 100 -Compress -ErrorAction Stop))
::
::        Set-Content $Path $UpdatedConfig -Encoding UTF8 -NoNewline -ErrorAction Stop
::
::        Out-Success $LogIndentLevel
::    } catch {
::        Out-Failure "Failed to update '$AppName' configuration: $_" $LogIndentLevel
::    }
::}
::
::#endregion functions > Configuration > Helpers > Update-BrowserConfiguration
::
::
::#region functions > Configuration > Helpers > Write-ConfigurationFile
::
::function Write-ConfigurationFile {
::    param(
::        [String][Parameter(Position = 0, Mandatory)]$AppName,
::        [String][Parameter(Position = 1, Mandatory)]$Content,
::        [String][Parameter(Position = 2, Mandatory)]$Path,
::        [String][Parameter(Position = 3)]$ProcessName = $AppName
::    )
::
::    Set-Variable -Option Constant LogIndentLevel ([Int]1)
::
::    try {
::        Stop-ProcessIfRunning $ProcessName
::
::        Write-LogInfo "Writing $AppName configuration to '$Path'..." $LogIndentLevel
::
::        New-Directory (Split-Path -Parent $Path -ErrorAction Stop)
::
::        Set-Content $Path $Content -NoNewline -ErrorAction Stop
::
::        Out-Success $LogIndentLevel
::    } catch {
::        Write-LogWarning "Failed to write configuration file '$Path': $_" $LogIndentLevel
::        throw $_
::    }
::}
::
::#endregion functions > Configuration > Helpers > Write-ConfigurationFile
::
::
::#region functions > Configuration > Windows > Remove-Annoyances
::
::function Remove-Annoyances {
::    try {
::        Import-RegistryConfiguration 'Remove Windows Annoyances' (Add-SysPrepConfig $CONFIG_ANNOYANCES) -ErrorAction Stop
::        Out-Success
::    } catch {
::        Out-Failure "Failed to remove Windows annoyances: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Remove-Annoyances
::
::
::#region functions > Configuration > Windows > Set-BaselineConfiguration
::
::function Set-BaselineConfiguration {
::    try {
::        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value 3 -ErrorAction Stop
::    } catch {
::        Out-Failure "Failed to enable time zone auto update: $_"
::    }
::
::    try {
::        Set-Variable -Option Constant UnelevatedExplorerTaskName ([String]'CreateExplorerShellUnelevatedTask')
::        if (Get-ScheduledTask | Where-Object { $_.TaskName -eq $UnelevatedExplorerTaskName }) {
::            Unregister-ScheduledTask -TaskName $UnelevatedExplorerTaskName -Confirm:$False -ErrorAction Stop
::        }
::    } catch {
::        Out-Failure "Failed to remove unelevated Explorer scheduled task: $_"
::    }
::
::    if ($SYSTEM_LANGUAGE -match 'ru') {
::        Set-Variable -Option Constant LocalisedConfig ([String]$CONFIG_BASELINE_RUSSIAN)
::    } else {
::        Set-Variable -Option Constant LocalisedConfig ([String]$CONFIG_BASELINE_ENGLISH)
::    }
::
::    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_BASELINE
::    $ConfigLines.Add("`n")
::    $ConfigLines.Add((Add-SysPrepConfig $LocalisedConfig))
::
::    try {
::        Set-Variable -Option Constant VolumeRegistries ([String[]](Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*' -ErrorAction Stop).Name)
::        foreach ($Registry in $VolumeRegistries) {
::            $ConfigLines.Add("`n[$Registry]`n")
::            $ConfigLines.Add("`"MaxCapacity`"=dword:000FFFFF`n")
::        }
::    } catch {
::        Out-Failure "Failed to read the registry: $_"
::    }
::
::    try {
::        Import-RegistryConfiguration 'Windows Baseline Config' $ConfigLines -ErrorAction Stop
::        Out-Success
::    } catch {
::        Out-Failure "Failed to apply Windows base configuration: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-BaselineConfiguration
::
::
::#region functions > Configuration > Windows > Set-CloudFlareDNS
::
::function Set-CloudFlareDNS {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory)]$MalwareProtection,
::        [Switch][Parameter(Position = 1, Mandatory)]$FamilyFriendly
::    )
::
::    try {
::        if ($FamilyFriendly) {
::            Set-Variable -Option Constant PreferredDnsServer ([String]'1.1.1.3')
::        } elseif ($MalwareProtection) {
::            Set-Variable -Option Constant PreferredDnsServer ([String]'1.1.1.2')
::        } else {
::            Set-Variable -Option Constant PreferredDnsServer ([String]'1.1.1.1')
::        }
::
::        if ($FamilyFriendly) {
::            Set-Variable -Option Constant AlternateDnsServer ([String]'1.0.0.3')
::        } elseif ($MalwareProtection) {
::            Set-Variable -Option Constant AlternateDnsServer ([String]'1.0.0.2')
::        } else {
::            Set-Variable -Option Constant AlternateDnsServer ([String]'1.0.0.1')
::        }
::
::        Write-LogInfo "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."
::        Write-LogWarning 'Internet connection may get interrupted briefly'
::
::        Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
::        if (-not $IsConnected) {
::            return
::        }
::
::        Set-Variable -Option Constant Status ([Int[]](Get-NetworkAdapter | Invoke-CimMethod -MethodName 'SetDNSServerSearchOrder' -Arguments @{ DNSServerSearchOrder = @($PreferredDnsServer, $AlternateDnsServer) } -ErrorAction Stop).ReturnValue)
::
::        if ($Status | Where-Object { $_ -ne 0 }) {
::            throw "Error code(s) returned: $($Status -join ', ')"
::        }
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to change DNS server: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-CloudFlareDNS
::
::
::#region functions > Configuration > Windows > Set-LocalisationConfiguration
::
::function Set-LocalisationConfiguration {
::    try {
::        Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sCurrency' -Value ([Char]0x20AC) -ErrorAction Stop
::    } catch {
::        Out-Failure "Failed to set currency symbol: $_"
::    }
::
::    try {
::        Set-WinHomeLocation -GeoId 140 -ErrorAction Stop
::    } catch {
::        Out-Failure "Failed to set home location to Latvia: $_"
::    }
::
::    try {
::        $LanguageList = Get-WinUserLanguageList -ErrorAction Stop
::        if (-not ($LanguageList | Where-Object { $_.LanguageTag -like 'lv' })) {
::            $LanguageList.Add('lv')
::            Set-WinUserLanguageList $LanguageList -Force -ErrorAction Stop
::        }
::        Out-Success
::    } catch {
::        Out-Failure "Failed to add Latvian language to user language list: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-LocalisationConfiguration
::
::
::#region functions > Configuration > Windows > Set-MalwareProtectionConfiguration
::
::function Set-MalwareProtectionConfiguration {
::    Set-Variable -Option Constant LogIndentLevel ([Int]1)
::
::    try {
::        Set-MpPreference -CheckForSignaturesBefore $True
::        Set-MpPreference -DisableBlockAtFirstSeen $False
::        Set-MpPreference -DisableCatchupQuickScan $False
::        Set-MpPreference -DisableEmailScanning $False
::        Set-MpPreference -DisableRemovableDriveScanning $False
::        Set-MpPreference -DisableRestorePoint $False
::        Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $False
::        Set-MpPreference -DisableScanningNetworkFiles $False
::        Set-MpPreference -EnableFileHashComputation $True
::        Set-MpPreference -EnableNetworkProtection Enabled
::        Set-MpPreference -PUAProtection Enabled
::        Set-MpPreference -AllowSwitchToAsyncInspection $True
::        Set-MpPreference -MeteredConnectionUpdates $True
::        Set-MpPreference -BruteForceProtectionLocalNetworkBlocking $True
::
::        Out-Success $LogIndentLevel
::    } catch {
::        Out-Failure "Failed to apply malware protection configuration: $_" $LogIndentLevel
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-MalwareProtectionConfiguration
::
::
::#region functions > Configuration > Windows > Set-PerformanceConfiguration
::
::function Set-PerformanceConfiguration {
::    try {
::        Import-RegistryConfiguration 'Windows Performance Config' (Add-SysPrepConfig $CONFIG_PERFORMANCE) -ErrorAction Stop
::        Out-Success
::    } catch {
::        Out-Failure "Failed to apply Windows performance configuration: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-PerformanceConfiguration
::
::
::#region functions > Configuration > Windows > Set-PersonalisationConfiguration
::
::function Set-PersonalisationConfiguration {
::    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_PERSONALISATION
::
::    try {
::        if ($OS_VERSION -gt 10) {
::            Set-Variable -Option Constant NotificationRegistries ([String[]](Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*' -ErrorAction Stop).Name)
::            foreach ($Registry in $NotificationRegistries) {
::                $ConfigLines.Add("`n[$Registry]`n")
::                $ConfigLines.Add("`"IsPromoted`"=dword:00000001`n")
::            }
::        }
::
::        foreach ($User in (Get-UsersRegistryKeys)) {
::            $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n")
::            $ConfigLines.Add("`"RotatingLockScreenEnabled`"=dword:00000001`n")
::        }
::    } catch {
::        Out-Failure "Failed to read the registry: $_"
::    }
::
::    try {
::        Import-RegistryConfiguration 'Windows Personalisation Config' $ConfigLines -ErrorAction Stop
::        Out-Success
::    } catch {
::        Out-Failure "Failed to apply Windows personalisation configuration: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-PersonalisationConfiguration
::
::
::#region functions > Configuration > Windows > Set-PowerSchemeConfiguration
::
::function Set-PowerSchemeConfiguration {
::    Set-Variable -Option Constant LogIndentLevel ([Int]1)
::
::    try {
::        powercfg /OverlaySetActive OVERLAY_SCHEME_MAX
::
::        foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
::            powercfg /SetAcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
::            powercfg /SetDcValueIndex SCHEME_ALL $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
::        }
::
::        Out-Success $LogIndentLevel
::    } catch {
::        Out-Failure "Failed to apply power settings configuration: $_" $LogIndentLevel
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-PowerSchemeConfiguration
::
::
::#region functions > Configuration > Windows > Set-PrivacyConfiguration
::
::function Set-PrivacyConfiguration {
::    try {
::        Set-Variable -Option Constant TelemetryTaskList (
::            [hashtable[]]@(
::                @{Name = 'Consolidator'; Path = 'Microsoft\Windows\Customer Experience Improvement Program' },
::                @{Name = 'DmClient'; Path = 'Microsoft\Windows\Feedback\Siuf' },
::                @{Name = 'DmClientOnScenarioDownload'; Path = 'Microsoft\Windows\Feedback\Siuf' },
::                @{Name = 'MareBackup'; Path = 'Microsoft\Windows\Application Experience' },
::                @{Name = 'Microsoft-Windows-DiskDiagnosticDataCollector'; Path = 'Microsoft\Windows\DiskDiagnostic' },
::                @{Name = 'PcaPatchDbTask'; Path = 'Microsoft\Windows\Application Experience' },
::                @{Name = 'Proxy'; Path = 'Microsoft\Windows\Autochk' },
::                @{Name = 'QueueReporting'; Path = 'Microsoft\Windows\Windows Error Reporting' },
::                @{Name = 'StartupAppTask'; Path = 'Microsoft\Windows\Application Experience' },
::                @{Name = 'UsbCeip'; Path = 'Microsoft\Windows\Customer Experience Improvement Program' }
::            )
::        )
::
::        foreach ($Task in $TelemetryTaskList) {
::            Disable-ScheduledTask -TaskName $Task.Name -TaskPath $Task.Path -ErrorAction Stop
::        }
::    } catch {
::        Out-Failure "Failed to disable telemetry tasks: $_"
::    }
::
::    [Collections.Generic.List[String]]$ConfigLines = Add-SysPrepConfig $CONFIG_PRIVACY
::
::    try {
::        foreach ($User in (Get-UsersRegistryKeys)) {
::            $ConfigLines.Add("`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n")
::            $ConfigLines.Add("`"RotatingLockScreenOverlayEnabled`"=dword:00000000`n")
::
::            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]`n")
::            $ConfigLines.Add("`"DoNotTrack`"=dword:00000001`n")
::
::            $ConfigLines.Add("`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]`n")
::            $ConfigLines.Add("`"EnableCortana`"=dword:00000000`n")
::        }
::    } catch {
::        Out-Failure "Failed to read the registry: $_"
::    }
::
::    try {
::        Import-RegistryConfiguration 'Windows Privacy Config' $ConfigLines -ErrorAction Stop
::        Out-Success
::    } catch {
::        Out-Failure "Failed to apply Windows privacy configuration: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-PrivacyConfiguration
::
::
::#region functions > Configuration > Windows > Set-SecurityConfiguration
::
::function Set-SecurityConfiguration {
::    try {
::        Import-RegistryConfiguration 'Windows Security Config' (Add-SysPrepConfig $CONFIG_SECURITY) -ErrorAction Stop
::        Out-Success
::    } catch {
::        Out-Failure "Failed to apply Windows security configuration: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-SecurityConfiguration
::
::
::#region functions > Configuration > Windows > Set-WindowsConfiguration
::
::function Set-WindowsConfiguration {
::    param(
::        [Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory)]$Security,
::        [Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory)]$Performance,
::        [Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory)]$Baseline,
::        [Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory)]$Annoyances,
::        [Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory)]$Privacy,
::        [Windows.Forms.CheckBox][Parameter(Position = 5, Mandatory)]$Localisation,
::        [Windows.Forms.CheckBox][Parameter(Position = 6, Mandatory)]$Personalisation
::    )
::
::    New-Activity 'Configuring Windows'
::
::    if ($Security.Checked) {
::        Write-ActivityProgress 10 'Applying malware protection configuration...'
::        Set-MalwareProtectionConfiguration
::
::        Write-ActivityProgress 20 'Applying Windows security configuration...'
::        Set-SecurityConfiguration
::    }
::
::    if ($Performance.Checked) {
::        Write-ActivityProgress 30 'Applying Windows power scheme settings...'
::        Set-PowerSchemeConfiguration
::
::        Write-ActivityProgress 40 'Applying Windows performance configuration...'
::        Set-PerformanceConfiguration
::    }
::
::    if ($Baseline.Checked) {
::        Write-ActivityProgress 50 'Applying Windows baseline configuration...'
::        Set-BaselineConfiguration
::    }
::
::    if ($Annoyances.Checked) {
::        Write-ActivityProgress 60 'Removing Windows ads and annoyances...'
::        Remove-Annoyances
::    }
::
::    if ($Privacy.Checked) {
::        Write-ActivityProgress 70 'Removing Windows telemetry and improving privacy...'
::        Set-PrivacyConfiguration
::    }
::
::    if ($Localisation.Checked) {
::        Write-ActivityProgress 80 'Applying Windows localisation configuration...'
::        Set-LocalisationConfiguration
::    }
::
::    if ($Personalisation.Checked) {
::        Write-ActivityProgress 90 'Applying Windows personalisation configuration...'
::        Set-PersonalisationConfiguration
::    }
::
::    Write-ActivityCompleted
::}
::
::#endregion functions > Configuration > Windows > Set-WindowsConfiguration
::
::
::#region functions > Configuration > Windows > Tools > Start-OoShutUp10
::
::function Start-OoShutUp10 {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory)]$Execute,
::        [Switch][Parameter(Position = 1, Mandatory)]$Silent
::    )
::
::    Write-LogInfo 'Starting OOShutUp10++ utility...'
::
::    try {
::        if ($Execute) {
::            Set-Variable -Option Constant TargetPath ([String]$PATH_OOSHUTUP10)
::        } else {
::            Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
::        }
::
::        Set-Variable -Option Constant ConfigFile ([String]"$TargetPath\ooshutup10.cfg")
::
::        New-Directory $TargetPath
::
::        Set-Content $ConfigFile $CONFIG_OOSHUTUP10 -NoNewline -ErrorAction Stop
::    } catch {
::        Write-LogWarning "Failed to initialize OOShutUp10++ configuration: $_"
::    }
::
::    if ($Execute -and $Silent) {
::        Start-DownloadUnzipAndRun 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe' -Execute:$Execute -Params $ConfigFile
::        Out-Success
::    } else {
::        Start-DownloadUnzipAndRun 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe' -Execute:$Execute
::        Out-Success
::    }
::}
::
::#endregion functions > Configuration > Windows > Tools > Start-OoShutUp10
::
::
::#region functions > Configuration > Windows > Tools > Start-WindowsDebloat
::
::function Start-WindowsDebloat {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory)]$UsePreset,
::        [Switch][Parameter(Position = 1, Mandatory)]$Personalisation,
::        [Switch][Parameter(Position = 2, Mandatory)]$Silent
::    )
::
::    Write-LogInfo 'Starting Windows 10/11 debloat utility...'
::
::    if (Find-RunningScript 'debloat.raphi.re') {
::        Write-LogWarning 'Windows debloat utility is already running'
::        return
::    }
::
::    if (-not (Test-NetworkConnection)) {
::        return
::    }
::
::    try {
::        Set-Variable -Option Constant TargetPath ([String]"$PATH_TEMP_DIR\Win11Debloat")
::
::        New-Directory $TargetPath
::
::        if ($UsePreset -and $Personalisation) {
::            Set-Variable -Option Constant AppsList ([String]($CONFIG_DEBLOAT_APP_LIST + 'Microsoft.OneDrive'))
::        } else {
::            Set-Variable -Option Constant AppsList ([String]$CONFIG_DEBLOAT_APP_LIST)
::        }
::
::        Set-Content "$TargetPath\CustomAppsList" $AppsList -NoNewline -ErrorAction Stop
::
::        if ($UsePreset -and $Personalisation) {
::            Set-Variable -Option Constant Configuration ([String]($CONFIG_DEBLOAT_PRESET_PERSONALISATION))
::        } else {
::            Set-Variable -Option Constant Configuration ([String]$CONFIG_DEBLOAT_PRESET_BASE)
::        }
::
::        Set-Content "$TargetPath\LastUsedSettings.json" $Configuration -NoNewline -ErrorAction Stop
::    } catch {
::        Write-LogWarning "Failed to initialize Windows debloat utility configuration: $_"
::    }
::
::    try {
::        if ($UsePreset -or $Personalisation) {
::            Set-Variable -Option Constant UsePresetParam ([String]' -RunSavedSettings -RemoveAppsCustom')
::        }
::
::        if ($Silent) {
::            Set-Variable -Option Constant SilentParam ([String]' -Silent')
::        }
::
::        if ($OS_VERSION -gt 10) {
::            Set-Variable -Option Constant SysprepParam ([String]' -Sysprep')
::        }
::
::        Set-Variable -Option Constant Params ([String]"-NoRestartExplorer$SysprepParam$UsePresetParam$SilentParam")
::
::        Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to start Windows debloat utility: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Tools > Start-WindowsDebloat
::
::
::#region functions > Configuration > Windows > Tools > Start-WinUtil
::
::function Start-WinUtil {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory)]$Personalisation,
::        [Switch][Parameter(Position = 1, Mandatory)]$AutomaticallyApply
::    )
::
::    Write-LogInfo 'Starting WinUtil utility...'
::
::    if (Find-RunningScript 'christitus.com') {
::        Write-LogWarning 'WinUtil utility is already running'
::        return
::    }
::
::    if (-not (Test-NetworkConnection)) {
::        return
::    }
::
::    try {
::        New-Directory $PATH_WINUTIL
::
::        Set-Variable -Option Constant ConfigFile ([String]"$PATH_WINUTIL\WinUtil.json")
::
::        [String]$Configuration = $CONFIG_WINUTIL
::        if ($Personalisation) {
::            $Configuration = $CONFIG_WINUTIL.Replace('    "WPFTweaks":  [
::', '    "WPFTweaks":  [
::' + $CONFIG_WINUTIL_PERSONALISATION)
::        }
::
::        Set-Content $ConfigFile $Configuration -NoNewline -ErrorAction Stop
::    } catch {
::        Write-LogWarning "Failed to initialize WinUtil configuration: $_"
::    }
::
::    try {
::        Set-Variable -Option Constant ConfigParam ([String]" -Config $ConfigFile")
::
::        if ($AutomaticallyApply) {
::            Set-Variable -Option Constant RunParam ([String]' -Run')
::        }
::
::        Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win')))$ConfigParam$RunParam"
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to start WinUtil utility: $_"
::    }
::}
::
::#endregion functions > Configuration > Windows > Tools > Start-WinUtil
::
::
::#region functions > Diagnostics and recovery > Get-BatteryReport
::
::function Get-BatteryReport {
::    try {
::        Write-LogInfo 'Exporting battery report...'
::
::        Set-Variable -Option Constant ReportPath ([String]"$PATH_APP_DIR\battery_report.html")
::
::        Initialize-AppDirectory
::
::        powercfg /BatteryReport /Output $ReportPath
::
::        Open-InBrowser $ReportPath
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to export battery report: $_"
::    }
::}
::
::#endregion functions > Diagnostics and recovery > Get-BatteryReport
::
::
::#region functions > Home > Start-Activator
::
::function Start-Activator {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory)]$ActivateWindows,
::        [Switch][Parameter(Position = 1, Mandatory)]$ActivateOffice
::    )
::
::    try {
::        Write-LogInfo 'Starting MAS activator...'
::
::        if (Find-RunningScript 'get.activated.win') {
::            Write-LogWarning 'MAS activator is already running'
::            return
::        }
::
::        if (-not (Test-NetworkConnection)) {
::            return
::        }
::
::        [String]$Params = ''
::
::        if ($ActivateWindows) {
::            $Params += ' /HWID'
::        }
::
::        if ($ActivateOffice) {
::            $Params += ' /Ohook'
::        }
::
::        Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm https://get.activated.win)))$Params"
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to start MAS activator: $_"
::    }
::}
::
::#endregion functions > Home > Start-Activator
::
::
::#region functions > Home > Start-Cleanup
::
::function Start-Cleanup {
::    New-Activity 'Cleaning up the system'
::    Set-Icon ([IconName]::Cleanup)
::
::    Set-Variable -Option Constant LogIndentLevel ([Int]1)
::
::    Write-ActivityProgress 10 'Clearing delivery optimization cache...'
::    Delete-DeliveryOptimizationCache -Force
::    Out-Success $LogIndentLevel
::
::    Write-ActivityProgress 20 'Clearing Windows temp folder...'
::    Set-Variable -Option Constant WindowsTemp ([String]"$env:SystemRoot\Temp")
::    Remove-Item -Path "$WindowsTemp\*" -Recurse -Force -ErrorAction Ignore
::    Out-Success $LogIndentLevel
::
::    Write-ActivityProgress 30 'Clearing user temp folder...'
::    Remove-Item -Path "$PATH_TEMP_DIR\*" -Recurse -Force -ErrorAction Ignore
::    Out-Success $LogIndentLevel
::
::    Write-ActivityProgress 40 'Clearing software distribution folder...'
::    Set-Variable -Option Constant SoftwareDistributionPath ([String]"$env:SystemRoot\SoftwareDistribution\Download")
::    Remove-Item -Path "$SoftwareDistributionPath\*" -Recurse -Force -ErrorAction Ignore
::    Out-Success $LogIndentLevel
::
::    Write-ActivityProgress 60 'Running system cleanup...'
::
::    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
::        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
::    }
::    Write-ActivityProgress 70
::
::    Set-Variable -Option Constant VolumeCaches (
::        [String[]]@(
::            'Active Setup Temp Folders',
::            'BranchCache',
::            'D3D Shader Cache',
::            'Delivery Optimization Files',
::            'Device Driver Packages',
::            'Diagnostic Data Viewer database files',
::            'Downloaded Program Files',
::            'Internet Cache Files',
::            'Language Pack',
::            'Old ChkDsk Files',
::            'Previous Installations',
::            'Recycle Bin',
::            'RetailDemo Offline Content',
::            'Setup Log Files',
::            'System error memory dump files',
::            'System error minidump files',
::            'Temporary Files',
::            'Temporary Setup Files',
::            'Thumbnail Cache',
::            'Update Cleanup',
::            'User file versions',
::            'Windows Defender',
::            'Windows Error Reporting Files',
::            'Windows ESD installation files',
::            'Windows Upgrade Log Files'
::        )
::    )
::
::    foreach ($VolumeCache in $VolumeCaches) {
::        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$VolumeCache" -Name StateFlags3224 -PropertyType DWord -Value 2 -Force
::    }
::    Write-ActivityProgress 80
::
::    Start-Process 'cleanmgr.exe' '/d C: /sagerun:3224'
::
::    Start-Sleep -Seconds 1
::
::    Write-ActivityProgress 90
::    Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
::        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
::    }
::
::    Out-Success $LogIndentLevel
::    Write-ActivityCompleted
::    Set-Icon (([IconName]::Default))
::}
::
::#endregion functions > Home > Start-Cleanup
::
::
::#region functions > Home > Update-MicrosoftOffice
::
::function Update-MicrosoftOffice {
::    try {
::        Write-LogInfo 'Starting Microsoft Office update...'
::
::        Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user' -ErrorAction Stop
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to update Microsoft Office: $_"
::    }
::}
::
::#endregion functions > Home > Update-MicrosoftOffice
::
::
::#region functions > Home > Update-MicrosoftStoreApps
::
::function Update-MicrosoftStoreApps {
::    try {
::        Write-LogInfo 'Starting Microsoft Store apps update...'
::
::        Get-CimInstance MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap' | Invoke-CimMethod -MethodName 'UpdateScanMethod'
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to update Microsoft Store apps: $_"
::    }
::}
::
::#endregion functions > Home > Update-MicrosoftStoreApps
::
::
::#region functions > Home > Update-Windows
::
::function Update-Windows {
::    try {
::        Write-LogInfo 'Starting Windows Update...'
::
::        Start-Process 'UsoClient' 'StartInteractiveScan' -ErrorAction Stop
::
::        Out-Success
::    } catch {
::        Out-Failure "Failed to update Windows: $_"
::    }
::}
::
::#endregion functions > Home > Update-Windows
::
::
::#region functions > Installs > Install-MicrosoftOffice
::
::function Install-MicrosoftOffice {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory)]$Execute
::    )
::
::    Write-LogInfo 'Starting Microsoft Office installation...'
::
::    try {
::        if ($Execute) {
::            Set-Variable -Option Constant TargetPath ([String]$PATH_APP_DIR)
::        } else {
::            Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
::        }
::
::        if ($SYSTEM_LANGUAGE -match 'ru') {
::            Set-Variable -Option Constant Config ([String]$CONFIG_OFFICE_INSTALLER.Replace('en-GB', 'ru-RU'))
::        } else {
::            Set-Variable -Option Constant Config ([String]$CONFIG_OFFICE_INSTALLER)
::        }
::
::        Initialize-AppDirectory
::
::        Set-Content "$TargetPath\Office Installer.ini" $Config -NoNewline -ErrorAction Stop
::    } catch {
::        Write-LogWarning "Failed to initialize Microsoft Office installer configuration: $_"
::    }
::
::    if ($Execute) {
::        try {
::            Import-RegistryConfiguration 'Microsoft Office' $CONFIG_MICROSOFT_OFFICE
::        } catch {
::            Write-LogWarning "Failed to import Microsoft Office registry configuration: $_"
::        }
::    }
::
::    Start-DownloadUnzipAndRun 'https://qiiwexc.github.io/d/Office_Installer.zip' -Execute:$Execute
::}
::
::#endregion functions > Installs > Install-MicrosoftOffice
::
::
::#region functions > Installs > Install-Unchecky
::
::function Install-Unchecky {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory)]$Execute,
::        [Switch][Parameter(Position = 1, Mandatory)]$Silent
::    )
::
::    Write-LogInfo 'Starting Unchecky installation...'
::
::    if ($Execute) {
::        try {
::            Set-Variable -Option Constant RegistryKey ([String]'HKCU:\Software\Unchecky')
::
::            if (-not (Test-Path $RegistryKey)) {
::                Write-LogDebug "Creating registry key '$RegistryKey'"
::                New-Item $RegistryKey -ErrorAction Stop
::            }
::
::            Set-ItemProperty -Path $RegistryKey -Name 'HideTrayIcon' -Value 1 -ErrorAction Stop
::        } catch {
::            Write-LogWarning "Failed to configure Unchecky parameters: $_"
::        }
::
::        if ($Silent) {
::            Set-Variable -Option Constant Params ([String]'-install -no_desktop_icon')
::        }
::    }
::
::    Start-DownloadUnzipAndRun 'https://fi.softradar.com/static/products/unchecky/distr/1.2/unchecky_softradar-com.exe' -Execute:$Execute -Params $Params -Silent:$Silent
::}
::
::#endregion functions > Installs > Install-Unchecky
::
::
::#region functions > Installs > Ninite
::
::function Set-NiniteButtonState {
::    $CHECKBOX_StartNinite.Enabled = $NINITE_CHECKBOXES.Where({ $_.Checked }, 'First', 1)
::}
::
::
::function Get-NiniteInstaller {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory)]$OpenInBrowser,
::        [Switch][Parameter(Position = 1)]$Execute
::    )
::
::    [Collections.Generic.List[String]]$AppIds = @()
::
::    foreach ($Checkbox in $NINITE_CHECKBOXES) {
::        if ($Checkbox.Checked) {
::            $AppIds.Add($Checkbox.Name)
::        }
::    }
::
::    Set-Variable -Option Constant Query ([String]($AppIds -join '-'))
::
::    if ($OpenInBrowser) {
::        Open-InBrowser "https://ninite.com/?select=$Query"
::    } else {
::        [Collections.Generic.List[String]]$AppNames = @()
::
::        foreach ($Checkbox in $NINITE_CHECKBOXES) {
::            if ($Checkbox.Checked) {
::                $AppNames.Add($Checkbox.Text)
::            }
::        }
::
::        Set-Variable -Option Constant FileName ([String]"Ninite $($AppNames -Join ' ') Installer.exe")
::        Set-Variable -Option Constant DownloadUrl ([String]"https://ninite.com/$Query/ninite.exe")
::
::        Start-DownloadUnzipAndRun $DownloadUrl $FileName -Execute:$Execute
::    }
::}
::
::#endregion functions > Installs > Ninite
::
::
::#region interface > Show window
::
::[Void]$FORM.ShowDialog()
::
::#endregion interface > Show window
::
