@echo off

if "%~1"=="Debug" set debug=true

set "psfile=%temp%\qiiwexc.ps1"

> "%psfile%" (
  for /f "delims=" %%A in ('findstr "^::" "%~f0"') do (
    set "line=%%A"
    setlocal enabledelayedexpansion
    echo(!line:~2!
    endlocal
  )
)

if "%debug%"=="true" (
  powershell -ExecutionPolicy Bypass -Command "& '%psfile%' -WorkingDirectory '%cd%' -DevMode"
) else (
  powershell -ExecutionPolicy Bypass -Command "& '%psfile%' -WorkingDirectory '%cd%'"
)

::#region init > Parameters
::
::#Requires -Version 3
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
::Set-Variable -Option Constant VERSION ([Version]'25.10.8')
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
::    } catch [Exception] {
::        Write-Error $_
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
::Set-Variable -Option Constant OLD_WINDOW_TITLE ($HOST.UI.RawUI.WindowTitle)
::$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION"
::
::try {
::    Add-Type -AssemblyName System.Windows.Forms
::} catch {
::    throw 'System not supported'
::}
::
::if (-not $DevMode) {
::    Add-Type -Namespace Console -Name Window -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
::                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
::    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
::}
::
::[System.Windows.Forms.Application]::EnableVisualStyles()
::
::
::Set-Variable -Option Constant PATH_WORKING_DIR $WorkingDirectory
::Set-Variable -Option Constant PATH_TEMP_DIR ([System.IO.Path]::GetTempPath())
::Set-Variable -Option Constant PATH_APP_DIR "$($PATH_TEMP_DIR)qiiwexc"
::Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
::Set-Variable -Option Constant PATH_WINUTIL "$env:ProgramData\WinUtil"
::Set-Variable -Option Constant PATH_OOSHUTUP10 "$env:ProgramData\OOShutUp10++"
::
::
::Set-Variable -Option Constant IS_LAPTOP ((Get-CimInstance -Class Win32_ComputerSystem -Property PCSystemType).PCSystemType -eq 2)
::
::Set-Variable -Option Constant SYSTEM_LANGUAGE (Get-SystemLanguage)
::
::Set-Variable -Option Constant PS_VERSION $PSVersionTable.PSVersion.Major
::
::Set-Variable -Option Constant OPERATING_SYSTEM (Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture)
::Set-Variable -Option Constant IsWindows11 ($OPERATING_SYSTEM.Caption -match 'Windows 11')
::Set-Variable -Option Constant WindowsBuild $OPERATING_SYSTEM.Version
::Set-Variable -Option Constant OS_VERSION $(if ($IsWindows11) { 11 } else { switch -Wildcard ($WindowsBuild) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } } })
::
::Set-Variable -Option Constant WordRegPath 'Registry::HKEY_CLASSES_ROOT\Word.Application\CurVer'
::if (Test-Path $WordRegPath) {
::    Set-Variable -Option Constant WordPath (Get-ItemProperty $WordRegPath)
::    Set-Variable -Option Constant OFFICE_VERSION ($WordPath.'(default)' -replace '\D+', '')
::    Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if (Test-Path $PATH_OFFICE_C2R_CLIENT_EXE) { 'C2R' } else { 'MSI' })
::}
::
::#endregion init > Initialization
::
::
::#region components > Constants
::
::Set-Variable -Option Constant BUTTON_WIDTH    170
::Set-Variable -Option Constant BUTTON_HEIGHT   30
::
::Set-Variable -Option Constant CHECKBOX_HEIGHT ($BUTTON_HEIGHT - 10)
::
::
::Set-Variable -Option Constant INTERVAL_BUTTON ($BUTTON_HEIGHT + 15)
::
::Set-Variable -Option Constant INTERVAL_CHECKBOX ($CHECKBOX_HEIGHT + 5)
::
::
::Set-Variable -Option Constant GROUP_WIDTH (15 + $BUTTON_WIDTH + 15)
::
::Set-Variable -Option Constant FORM_WIDTH  (($GROUP_WIDTH + 15) * 3 + 30)
::Set-Variable -Option Constant FORM_HEIGHT 560
::
::Set-Variable -Option Constant INITIAL_LOCATION_BUTTON '15, 20'
::
::Set-Variable -Option Constant SHIFT_CHECKBOX "0, $INTERVAL_CHECKBOX"
::
::
::Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
::Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"
::
::#endregion components > Constants
::
::
::#region components > Button
::
::function New-Button {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [ScriptBlock][Parameter(Position = 1)]$Function,
::        [Switch]$Disabled
::    )
::
::    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)
::
::    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [System.Drawing.Point]$Shift = '0, 0'
::
::    if ($PREVIOUS_LABEL_OR_CHECKBOX -or $PREVIOUS_RADIO) {
::        [Int]$PreviousLabelOrCheckboxY = if ($PREVIOUS_LABEL_OR_CHECKBOX) { $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y } else { 0 }
::        [Int]$PreviousRadioY = if ($PREVIOUS_RADIO) { $PREVIOUS_RADIO.Location.Y } else { 0 }
::
::        [Int]$PreviousMiscElement = if ($PreviousLabelOrCheckboxY -gt $PreviousRadioY) { $PreviousLabelOrCheckboxY } else { $PreviousRadioY }
::
::        $InitialLocation.Y = $PreviousMiscElement
::        $Shift = '0, 30'
::    } elseif ($PREVIOUS_BUTTON) {
::        $InitialLocation = $PREVIOUS_BUTTON.Location
::        $Shift = "0, $INTERVAL_BUTTON"
::    }
::
::
::    [System.Drawing.Point]$Location = $InitialLocation + $Shift
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
::    Set-Variable -Scope Script PREVIOUS_BUTTON $Button
::}
::
::#endregion components > Button
::
::
::#region components > ButtonBrowser
::
::function New-ButtonBrowser {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [ScriptBlock][Parameter(Position = 1, Mandatory = $True)]$Function
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
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [String][Parameter(Position = 1)]$Name,
::        [Switch]$Disabled,
::        [Switch]$Checked
::    )
::
::    Set-Variable -Option Constant CheckBox (New-Object System.Windows.Forms.CheckBox)
::
::    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [System.Drawing.Point]$Shift = '0, 0'
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
::    [System.Drawing.Point]$Location = $InitialLocation + $Shift
::
::    $CheckBox.Text = $Text
::    $CheckBox.Name = $Name
::    $CheckBox.Checked = $Checked
::    $CheckBox.Enabled = -not $Disabled
::    $CheckBox.Size = "160, $CHECKBOX_HEIGHT"
::    $CheckBox.Location = $Location
::
::    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
::    $CURRENT_GROUP.Controls.Add($CheckBox)
::
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $CheckBox
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
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [Int][Parameter(Position = 1)]$IndexOverride
::    )
::
::    Set-Variable -Option Constant GroupBox (New-Object System.Windows.Forms.GroupBox)
::
::    Set-Variable -Scope Script PREVIOUS_GROUP $CURRENT_GROUP
::    Set-Variable -Scope Script PAD_CHECKBOXES $True
::
::    [Int]$GroupIndex = 0
::
::    if ($IndexOverride) {
::        $GroupIndex = $IndexOverride
::    } else {
::        $CURRENT_TAB.Controls | ForEach-Object { $GroupIndex += $_.Length }
::    }
::
::    if ($GroupIndex -lt 3) {
::        Set-Variable -Option Constant Location $(if ($GroupIndex -eq 0) { '15, 15' } else { $PREVIOUS_GROUP.Location + "$($GROUP_WIDTH + 15), 0" })
::    } else {
::        Set-Variable -Option Constant PreviousGroup $CURRENT_TAB.Controls[$GroupIndex - 3]
::        Set-Variable -Option Constant Location ($PreviousGroup.Location + "0, $($PreviousGroup.Height + 15)")
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
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text
::    )
::
::    Set-Variable -Option Constant Label (New-Object System.Windows.Forms.Label)
::
::    [System.Drawing.Point]$Location = ($PREVIOUS_BUTTON.Location + "30, $BUTTON_HEIGHT")
::
::    $Label.Size = "145, $CHECKBOX_HEIGHT"
::    $Label.Text = $Text
::    $Label.Location = $Location
::
::    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
::    $CURRENT_GROUP.Controls.Add($Label)
::
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Label
::}
::
::#endregion components > Label
::
::
::#region components > RadioButton
::
::function New-RadioButton {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [Switch]$Checked,
::        [Switch]$Disabled
::    )
::
::    Set-Variable -Option Constant RadioButton (New-Object System.Windows.Forms.RadioButton)
::
::    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [System.Drawing.Point]$Shift = '0, 0'
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
::    [System.Drawing.Point]$Location = $InitialLocation + $Shift
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
::    Set-Variable -Scope Script PREVIOUS_RADIO $RadioButton
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
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text
::    )
::
::    Set-Variable -Option Constant TabPage (New-Object System.Windows.Forms.TabPage)
::
::    $TabPage.UseVisualStyleBackColor = $True
::    $TabPage.Text = $Text
::
::    $TAB_CONTROL.Controls.Add($TabPage)
::
::    Set-Variable -Scope Script PREVIOUS_GROUP $Null
::    Set-Variable -Scope Script CURRENT_TAB $TabPage
::}
::
::#endregion components > TabPage
::
::
::#region ui > Form
::
::Set-Variable -Option Constant FORM (New-Object System.Windows.Forms.Form)
::$FORM.Text = $HOST.UI.RawUI.WindowTitle
::$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
::$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
::$FORM.FormBorderStyle = 'Fixed3D'
::$FORM.StartPosition = 'CenterScreen'
::$FORM.MaximizeBox = $False
::$FORM.Top = $True
::$FORM.Add_Shown( { Initialize-App } )
::$FORM.Add_FormClosing( { Reset-State } )
::
::
::Set-Variable -Option Constant LOG (New-Object System.Windows.Forms.RichTextBox)
::$LOG.Height = 200
::$LOG.Width = $FORM_WIDTH - 10
::$LOG.Location = "5, $($FORM_HEIGHT - $LOG.Height - 5)"
::$LOG.Font = "$FONT_NAME, 9"
::$LOG.ReadOnly = $True
::$FORM.Controls.Add($LOG)
::
::
::Set-Variable -Option Constant TAB_CONTROL (New-Object System.Windows.Forms.TabControl)
::$TAB_CONTROL.Size = "$($LOG.Width + 1), $($FORM_HEIGHT - $LOG.Height - 1)"
::$TAB_CONTROL.Location = '5, 5'
::$FORM.Controls.Add($TAB_CONTROL)
::
::#endregion ui > Form
::
::
::#region ui > Home > Tab
::
::Set-Variable -Option Constant TAB_HOME (New-TabPage 'Home')
::
::#endregion ui > Home > Tab
::
::
::#region ui > Home > Check for updates
::
::New-GroupBox 'Check for updates'
::
::
::[Switch]$BUTTON_DISABLED = $OS_VERSION -lt 7
::[ScriptBlock]$BUTTON_FUNCTION = { Update-Windows }
::New-Button 'Windows update' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
::
::
::[Switch]$BUTTON_DISABLED = $OS_VERSION -lt 8
::[ScriptBlock]$BUTTON_FUNCTION = { Update-MicrosoftStoreApps }
::New-Button 'Microsoft Store updates' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
::
::
::[Switch]$BUTTON_DISABLED = $OFFICE_INSTALL_TYPE -ne 'C2R'
::[ScriptBlock]$BUTTON_FUNCTION = { Update-MicrosoftOffice }
::New-Button 'Microsoft Office updates' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
::
::#endregion ui > Home > Check for updates
::
::
::#region ui > Home > Activators
::
::New-GroupBox 'Activators (Windows 7+, Office)'
::
::
::[Switch]$BUTTON_DISABLED = $OS_VERSION -lt 7
::[ScriptBlock]$BUTTON_FUNCTION = { Start-Activator }
::New-Button 'MAS Activator' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -AVWarning -Execute:$CHECKBOX_StartActivationProgram.Checked 'https://qiiwexc.github.io/d/ActivationProgram.zip' }
::New-Button 'Activation Program' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartActivationProgram = New-CheckBoxRunAfterDownload -Checked
::
::#endregion ui > Home > Activators
::
::
::#region ui > Home > Bootable USB tools
::
::New-GroupBox 'Bootable USB tools'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = {
::    Set-Variable -Option Constant FileName $((Split-Path -Leaf 'https://github.com/ventoy/Ventoy/releases/download/v1.1.07/ventoy-1.1.07-windows.zip').Replace('-windows', ''))
::    Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartVentoy.Checked 'https://github.com/ventoy/Ventoy/releases/download/v1.1.07/ventoy-1.1.07-windows.zip' -FileName:$FileName
::}
::New-Button 'Windows Ventoy' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Checked
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartRufus.Checked 'https://github.com/pbatard/rufus/releases/download/v4.11/rufus-4.11p.exe' -Params:'-g' }
::New-Button 'Rufus' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Checked
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
::#region ui > Installs > Tab
::
::Set-Variable -Option Constant TAB_INSTALLS (New-TabPage 'Installs')
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
::[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
::$CHECKBOX_Ninite_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
::$CHECKBOX_Ninite_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
::$CHECKBOX_Ninite_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_TeamViewer = New-CheckBox 'TeamViewer' -Name 'teamviewer15' -Checked
::$CHECKBOX_Ninite_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
::$CHECKBOX_Ninite_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Ninite_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
::$CHECKBOX_Ninite_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Get-NiniteInstaller -OpenInBrowser:(-not $CHECKBOX_StartNinite.Enabled) -Execute:$CHECKBOX_StartNinite.Checked }
::New-Button 'Download selected' $BUTTON_FUNCTION
::
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked
::
::[ScriptBlock]$BUTTON_FUNCTION = { Get-NiniteInstaller -OpenInBrowser:$True }
::New-ButtonBrowser 'View other' $BUTTON_FUNCTION
::
::
::Set-Variable -Option Constant NINITE_CHECKBOXES @(
::    $CHECKBOX_Ninite_7zip,
::    $CHECKBOX_Ninite_VLC,
::    $CHECKBOX_Ninite_TeamViewer,
::    $CHECKBOX_Ninite_Chrome,
::    $CHECKBOX_Ninite_qBittorrent,
::    $CHECKBOX_Ninite_Malwarebytes
::)
::
::#endregion ui > Installs > Ninite
::
::
::#region ui > Installs > Essentials
::
::New-GroupBox 'Essentials'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartSDI.Checked 'https://www.glenn.delahoy.com/downloads/sdio/SDIO_1.15.6.817.zip' }
::New-Button 'Snappy Driver Installer' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Checked
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Install-MicrosoftOffice -Execute:$CHECKBOX_StartOfficeInstaller.Checked }
::New-Button 'Office Installer+' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartOfficeInstaller = New-CheckBoxRunAfterDownload -Checked
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Install-Unchecky -Execute:$CHECKBOX_StartUnchecky.Checked -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked }
::New-Button 'Unchecky' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Checked
::$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
::        Set-CheckboxState -Control:$CHECKBOX_StartUnchecky -Dependant:$CHECKBOX_SilentlyInstallUnchecky
::    } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Checked
::
::#endregion ui > Installs > Essentials
::
::
::#region ui > Installs > Windows images
::
::New-GroupBox 'Windows images'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser 'https://w16.monkrus.ws/2025/01/windows-11-v24h2-rus-eng-20in1-hwid-act.html' }
::New-ButtonBrowser 'Windows 11' $BUTTON_FUNCTION
::
::[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser 'https://w16.monkrus.ws/2022/11/windows-10-v22h2-rus-eng-x86-x64-32in1.html' }
::New-ButtonBrowser 'Windows 10' $BUTTON_FUNCTION
::
::[ScriptBlock]$BUTTON_FUNCTION = { Open-InBrowser 'https://w16.monkrus.ws/2024/02/windows-7-sp1-rus-eng-x86-x64-18in1.html' }
::New-ButtonBrowser 'Windows 7' $BUTTON_FUNCTION
::
::#endregion ui > Installs > Windows images
::
::
::#region ui > Configuration > Tab
::
::Set-Variable -Option Constant TAB_CONFIGURATION (New-TabPage 'Configuration')
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
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_7zip = New-CheckBox '7-Zip' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_VLC = New-CheckBox 'VLC' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_TeamViewer = New-CheckBox 'TeamViewer' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_qBittorrent = New-CheckBox 'qBittorrent' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_Edge = New-CheckBox 'Microsoft Edge' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_Chrome = New-CheckBox 'Google Chrome' -Checked
::
::
::Set-Variable -Option Constant AppsConfigurationParameters @{
::    '7zip'      = $CHECKBOX_Config_7zip
::    VLC         = $CHECKBOX_Config_VLC
::    TeamViewer  = $CHECKBOX_Config_TeamViewer
::    qBittorrent = $CHECKBOX_Config_qBittorrent
::    Edge        = $CHECKBOX_Config_Edge
::    Chrome      = $CHECKBOX_Config_Chrome
::}
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
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsBase = New-CheckBox 'Base config and privacy' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_PowerScheme = New-CheckBox 'Set power scheme' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsSearch = New-CheckBox 'Configure search index' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_FileAssociations = New-CheckBox 'Set file associations'
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'
::
::
::Set-Variable -Option Constant WindowsConfigurationParameters @{
::    Base             = $CHECKBOX_Config_WindowsBase
::    PowerScheme      = $CHECKBOX_Config_PowerScheme
::    Search           = $CHECKBOX_Config_WindowsSearch
::    FileAssociations = $CHECKBOX_Config_FileAssociations
::    Personalisation  = $CHECKBOX_Config_WindowsPersonalisation
::}
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
::[System.Windows.Forms.CheckBox]$CHECKBOX_UseDebloatPreset = New-CheckBox 'Use custom preset' -Checked
::$CHECKBOX_UseDebloatPreset.Add_CheckStateChanged( {
::        Set-CheckboxState -Control:$CHECKBOX_UseDebloatPreset -Dependant:$CHECKBOX_SilentlyRunDebloat
::        Set-CheckboxState -Control:$CHECKBOX_UseDebloatPreset -Dependant:$CHECKBOX_DebloatAndPersonalise
::    } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_DebloatAndPersonalise = New-CheckBox '+ Personalisation settings'
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunDebloat = New-CheckBox 'Silently apply tweaks'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-WinUtil -Personalisation:$CHECKBOX_WinUtilPersonalisation.Checked -AutomaticallyApply:$CHECKBOX_AutomaticallyRunWinUtil.Checked }
::New-Button 'WinUtil' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_WinUtilPersonalisation = New-CheckBox '+ Personalisation settings'
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_AutomaticallyRunWinUtil = New-CheckBox 'Auto apply tweaks'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-OoShutUp10 -Execute:$CHECKBOX_StartOoShutUp10.Checked -Silent:($CHECKBOX_StartOoShutUp10.Checked -and $CHECKBOX_SilentlyRunOoShutUp10.Checked) }
::New-Button 'OOShutUp10++ privacy' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartOoShutUp10 = New-CheckBoxRunAfterDownload -Checked
::$CHECKBOX_StartOoShutUp10.Add_CheckStateChanged( {
::        Set-CheckboxState -Control:$CHECKBOX_StartOoShutUp10 -Dependant:$CHECKBOX_SilentlyRunOoShutUp10
::    } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunOoShutUp10 = New-CheckBox 'Silently apply tweaks'
::
::#endregion ui > Configuration > Configure and debloat Windows
::
::
::#region ui > Configuration > Remove Windows components
::
::New-GroupBox 'Remove Windows components'
::
::
::[Switch]$BUTTON_DISABLED = $PS_VERSION -lt 5
::[ScriptBlock]$BUTTON_FUNCTION = { Remove-WindowsFeatures }
::New-Button 'Feature cleanup' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
::
::#endregion ui > Configuration > Remove Windows components
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
::[System.Windows.Forms.CheckBox]$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
::$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( {
::        Set-CheckboxState -Control:$CHECKBOX_CloudFlareAntiMalware -Dependant:$CHECKBOX_CloudFlareFamilyFriendly
::    } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'
::
::#endregion ui > Configuration > Alternative DNS
::
::
::#region ui > Diagnostics and recovery > Tab
::
::Set-Variable -Option Constant TAB_DIAGNOSTICS (New-TabPage 'Diagnostics and recovery')
::
::#endregion ui > Diagnostics and recovery > Tab
::
::
::#region ui > Diagnostics and recovery > Hardware info
::
::New-GroupBox 'Hardware info'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartCpuZ.Checked 'https://download.cpuid.com/cpu-z/cpu-z_2.16-en.zip' }
::New-Button 'CPU-Z' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartCpuZ = New-CheckBoxRunAfterDownload -Checked
::
::#endregion ui > Diagnostics and recovery > Hardware info
::
::
::#region ui > Diagnostics and recovery > HDD diagnostics
::
::New-GroupBox 'HDD diagnostics'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartVictoria.Checked 'https://hdd.by/Victoria/Victoria537.zip' }
::New-Button 'Victoria' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Checked
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
::Set-Variable -Option Constant CONFIG_7ZIP '[HKEY_CURRENT_USER\Software\7-Zip]
::"LargePages"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\7-Zip\FM]
::"AlternativeSelection"=dword:00000001
::"Columns\RootFolder"=hex:01,00,00,00,00,00,00,00,01,00,00,00,04,00,00,00,01,00,00,00,A0,00,00,00
::"FlatViewArc0"=dword:00000000
::"FlatViewArc1"=dword:00000000
::"FolderHistory"=hex:00,00
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
::'
::
::#endregion configs > Apps > 7zip
::
::
::#region configs > Apps > Chrome local state
::
::Set-Variable -Option Constant CONFIG_CHROME_LOCAL_STATE '{
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
::'
::
::#endregion configs > Apps > Chrome local state
::
::
::#region configs > Apps > Chrome preferences
::
::Set-Variable -Option Constant CONFIG_CHROME_PREFERENCES '{
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
::'
::
::#endregion configs > Apps > Chrome preferences
::
::
::#region configs > Apps > Edge local state
::
::Set-Variable -Option Constant CONFIG_EDGE_LOCAL_STATE '{
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
::'
::
::#endregion configs > Apps > Edge local state
::
::
::#region configs > Apps > Edge preferences
::
::Set-Variable -Option Constant CONFIG_EDGE_PREFERENCES '{
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
::'
::
::#endregion configs > Apps > Edge preferences
::
::
::#region configs > Apps > Microsoft Office
::
::Set-Variable -Option Constant CONFIG_MICROSOFT_OFFICE '[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\General]
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
::'
::
::#endregion configs > Apps > Microsoft Office
::
::
::#region configs > Apps > qBittorrent base
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_BASE '[Appearance]
::Style=Fusion
::
::[Application]
::FileLogger\Age=1
::FileLogger\AgeType=0
::FileLogger\Backup=true
::FileLogger\DeleteOld=true
::FileLogger\Enabled=true
::FileLogger\MaxSizeBytes=1024
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
::Session\RefreshInterval=500
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
::[RSS]
::AutoDownloader\DownloadRepacks=true
::Session\MaxArticlesPerFeed=9999999
::Session\RefreshInterval=1
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
::'
::
::#endregion configs > Apps > qBittorrent base
::
::
::#region configs > Apps > qBittorrent English
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_ENGLISH 'General\Locale=en_GB
::
::[GUI]
::DownloadTrackerFavicon=true
::Log\Enabled=false
::MainWindow\FiltersSidebarWidth=155
::Qt6\TorrentProperties\FilesListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x6\xd1\0\0\0\x6\x1\x1\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\x6\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0\x7f\0\0\0\x1\0\0\0\0\0\0\0U\0\0\0\x1\0\0\0\0\0\0\x5)\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0W\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TorrentProperties\PeerListState=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\xf\0@\0\0\0\x1\0\0\0\xe\0\0\0\x64\0\0\x4Y\0\0\0\xf\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\xf\0\0\0r\0\0\0\x1\0\0\0\0\0\0\0V\0\0\0\x1\0\0\0\0\0\0\0\x32\0\0\0\x1\0\0\0\0\0\0\0Y\0\0\0\x1\0\0\0\0\0\0\0\x35\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0g\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0\x61\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0`\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0T\0\0\0\x1\0\0\0\0\0\0\0\x32\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)
::Qt6\TorrentProperties\TrackerListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x3\xce\0\0\0\v\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\v\0\0\0\xa2\0\0\0\x1\0\0\0\0\0\0\0\x30\0\0\0\x1\0\0\0\0\0\0\0[\0\0\0\x1\0\0\0\0\0\0\0=\0\0\0\x1\0\0\0\0\0\0\0\x39\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0G\0\0\0\x1\0\0\0\0\0\0\0\x84\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0q\0\0\0\x1\0\0\0\0\0\0\0j\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TransferList\HeaderState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0%\0\xf8\x8f\x66\x1f\0\0\0\x13\0\0\0!\0\0\0\x64\0\0\0\x10\0\0\0\x64\0\0\0\v\0\0\0\x64\0\0\0$\0\0\0\x64\0\0\0\x11\0\0\0\x64\0\0\0\x1e\0\0\0\x64\0\0\0\x13\0\0\0\x64\0\0\0\"\0\0\0\x64\0\0\0\x19\0\0\0\x64\0\0\0\r\0\0\0\x64\0\0\0\x1d\0\0\0\x64\0\0\0\x1a\0\0\0\x64\0\0\0\xe\0\0\0\x64\0\0\0\x12\0\0\0\x64\0\0\0\x17\0\0\0\x64\0\0\0\f\0\0\0\x64\0\0\0\xf\0\0\0\x64\0\0\0#\0\0\0\x64\0\0\0 \0\0\0\x64\0\0\x5<\0\0\0%\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0%\0\0\0!\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0\x31\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0=\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0\x39\0\0\0\x1\0\0\0\0\0\0\0\x61\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0.\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0`\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0~\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0U\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0V\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::StartUpWindowState=Normal
::'
::
::#endregion configs > Apps > qBittorrent English
::
::
::#region configs > Apps > qBittorrent Russian
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_RUSSIAN 'General\Locale=ru
::
::[GUI]
::DownloadTrackerFavicon=true
::Log\Enabled=false
::MainWindow\FiltersSidebarWidth=153
::Qt6\TorrentProperties\FilesListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x6\xd1\0\0\0\x6\x1\x1\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\x6\0\0\0\x33\0\0\0\x1\0\0\0\0\0\0\0r\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0\x8f\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\x4\xfe\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0P\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TorrentProperties\PeerListState=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\xf\0@\0\0\0\x1\0\0\0\xe\0\0\0\x64\0\0\x4:\0\0\0\xf\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\xf\0\0\0n\0\0\0\x1\0\0\0\0\0\0\0K\0\0\0\x1\0\0\0\0\0\0\0\x36\0\0\0\x1\0\0\0\0\0\0\0\x62\0\0\0\x1\0\0\0\0\0\0\0>\0\0\0\x1\0\0\0\0\0\0\0\x44\0\0\0\x1\0\0\0\0\0\0\0^\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0L\0\0\0\x1\0\0\0\0\0\0\0\x42\0\0\0\x1\0\0\0\0\0\0\0X\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0M\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)
::Qt6\TorrentProperties\TrackerListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x4\x19\0\0\0\v\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\v\0\0\0\xb9\0\0\0\x1\0\0\0\0\0\0\0K\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0<\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0q\0\0\0\x1\0\0\0\0\0\0\0^\0\0\0\x1\0\0\0\0\0\0\0]\0\0\0\x1\0\0\0\0\0\0\0~\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TransferList\HeaderState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0%\0\xf8\x8f\x66\x1f\0\0\0\x13\0\0\0\x11\0\0\0\x64\0\0\0\x12\0\0\0\x64\0\0\0\x10\0\0\0\x64\0\0\0\x1a\0\0\0\x64\0\0\0\x17\0\0\0\x64\0\0\0\v\0\0\0\x64\0\0\0\x1e\0\0\0\x64\0\0\0\x13\0\0\0\x64\0\0\0!\0\0\0\x64\0\0\0\x1d\0\0\0\x64\0\0\0 \0\0\0\x64\0\0\0\xf\0\0\0\x64\0\0\0$\0\0\0\x64\0\0\0\x19\0\0\0\x64\0\0\0\f\0\0\0\x64\0\0\0\"\0\0\0\x64\0\0\0\r\0\0\0\x64\0\0\0\xe\0\0\0\x64\0\0\0#\0\0\0\x64\0\0\x5\xfb\0\0\0%\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0%\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x33\0\0\0\x1\0\0\0\0\0\0\0\x44\0\0\0\x1\0\0\0\0\0\0\0\x65\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0<\0\0\0\x1\0\0\0\0\0\0\0L\0\0\0\x1\0\0\0\0\0\0\0\x42\0\0\0\x1\0\0\0\0\0\0\0_\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0X\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0\x8a\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0x\0\0\0\x1\0\0\0\0\0\0\0u\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::StartUpWindowState=Normal
::'
::
::#endregion configs > Apps > qBittorrent Russian
::
::
::#region configs > Apps > TeamViewer
::
::Set-Variable -Option Constant CONFIG_TEAMVIEWER '[HKEY_CURRENT_USER\Software\TeamViewer]
::"AutoHideServerControl"=dword:00000001
::"ColorScheme"=dword:00000001
::"CustomInvitationSubject"=" "
::"CustomInvitationText"=" "
::"Pres_Compression"=dword:00000064
::"Pres_DisableGuiAnimations"=dword:00000000
::"Pres_QualityMode"=dword:00000003
::"Remote_Colors"=dword:00000020
::"Remote_DisableGuiAnimations"=dword:00000000
::"Remote_QualityMode"=dword:00000003
::"Remote_RemoteCursor"=dword:00000001
::"Remote_RemoveWallpaper"=dword:00000000
::"RemotePrintingPreferPDFFormat"=dword:00000001
::"SsoKmsEnabled"=dword:00000002
::'
::
::#endregion configs > Apps > TeamViewer
::
::
::#region configs > Apps > VLC
::
::Set-Variable -Option Constant CONFIG_VLC '[qt]
::qt-system-tray=0
::qt-updates-days=1
::qt-privacy-ask=0
::
::[core]
::video-title-show=0
::metadata-network-access=1
::'
::
::#endregion configs > Apps > VLC
::
::
::#region configs > Installs > Office Installer
::
::Set-Variable -Option Constant CONFIG_OFFICE_INSTALLER '[Configurations]
::NOSOUND = 1
::PosR = 1
::ArchR = 1
::DlndArch = 1
::CBBranch = 1
::Word = 1
::Excel = 1
::Access = 0
::Publisher = 0
::Teams = 0
::Groove = 0
::Lync = 0
::OneNote = 0
::OneDrive = 0
::Outlook = 0
::PowerPoint = 1
::Project = 0
::ProjectPro = 0
::ProjectMondo = 0
::Visio = 0
::VisioPro = 0
::VisioMondo = 0
::ProofingTools = 0
::OnOff = 1
::langs = en-GB|lv-LV|
::'
::
::#endregion configs > Installs > Office Installer
::
::
::#region configs > Windows > File associations
::
::Set-Variable -Option Constant CONFIG_FILE_ASSOCIATIONS @(
::    @{Method = 'Registry'; Application = '7-Zip.rar'; Extension = '.rar' },
::    @{Method = 'Registry'; Application = '7-Zip.tbz2'; Extension = '.tbz2' },
::    @{Method = 'Registry'; Application = '7-Zip.tgz'; Extension = '.tgz' },
::    @{Method = 'Registry'; Application = '7-Zip.txz'; Extension = '.txz' },
::    @{Method = 'Registry'; Application = 'ArchiveFolder'; Extension = '.7z' },
::    @{Method = 'Registry'; Application = 'ArchiveFolder'; Extension = '.bz2' },
::    @{Method = 'Registry'; Application = 'ArchiveFolder'; Extension = '.gz' },
::    @{Method = 'Registry'; Application = 'ArchiveFolder'; Extension = '.tar' },
::    @{Method = 'Registry'; Application = 'ArchiveFolder'; Extension = '.xz' },
::    @{Method = 'Registry'; Application = 'CABFolder'; Extension = '.cab' },
::    @{Method = 'Registry'; Application = 'contact_wab_auto_file'; Extension = '.contact' },
::    @{Method = 'Registry'; Application = 'group_wab_auto_file'; Extension = '.group' },
::    @{Method = 'Registry'; Application = 'PhotoViewer.FileAssoc.Bitmap'; Extension = '.bmp' },
::    @{Method = 'Registry'; Application = 'PhotoViewer.FileAssoc.Bitmap'; Extension = '.dib' },
::    @{Method = 'Registry'; Application = 'qBittorrent.File.Torrent'; Extension = '.torrent' },
::    @{Method = 'Registry'; Application = 'TIFImage.Document'; Extension = '.cr2' },
::    @{Method = 'Registry'; Application = 'vcard_wab_auto_file'; Extension = '.vcf' },
::    @{Method = 'Registry'; Application = 'VLC.3g2'; Extension = '.3g2' },
::    @{Method = 'Registry'; Application = 'VLC.3gp'; Extension = '.3gp' },
::    @{Method = 'Registry'; Application = 'VLC.3gp2'; Extension = '.3gp2' },
::    @{Method = 'Registry'; Application = 'VLC.3gpp'; Extension = '.3gpp' },
::    @{Method = 'Registry'; Application = 'VLC.aac'; Extension = '.aac' },
::    @{Method = 'Registry'; Application = 'VLC.adt'; Extension = '.adt' },
::    @{Method = 'Registry'; Application = 'VLC.adts'; Extension = '.adts' },
::    @{Method = 'Registry'; Application = 'VLC.aif'; Extension = '.aif' },
::    @{Method = 'Registry'; Application = 'VLC.aifc'; Extension = '.aifc' },
::    @{Method = 'Registry'; Application = 'VLC.aiff'; Extension = '.aiff' },
::    @{Method = 'Registry'; Application = 'VLC.asf'; Extension = '.asf' },
::    @{Method = 'Registry'; Application = 'VLC.asx'; Extension = '.asx' },
::    @{Method = 'Registry'; Application = 'VLC.au'; Extension = '.au' },
::    @{Method = 'Registry'; Application = 'VLC.avi'; Extension = '.avi' },
::    @{Method = 'Registry'; Application = 'VLC.cda'; Extension = '.cda' },
::    @{Method = 'Registry'; Application = 'VLC.dvr-ms'; Extension = '.dvr-ms' },
::    @{Method = 'Registry'; Application = 'VLC.flac'; Extension = '.flac' },
::    @{Method = 'Registry'; Application = 'VLC.m1v'; Extension = '.m1v' },
::    @{Method = 'Registry'; Application = 'VLC.m2t'; Extension = '.m2t' },
::    @{Method = 'Registry'; Application = 'VLC.m2ts'; Extension = '.m2ts' },
::    @{Method = 'Registry'; Application = 'VLC.m2v'; Extension = '.m2v' },
::    @{Method = 'Registry'; Application = 'VLC.m3u'; Extension = '.m3u' },
::    @{Method = 'Registry'; Application = 'VLC.m4a'; Extension = '.m4a' },
::    @{Method = 'Registry'; Application = 'VLC.m4v'; Extension = '.m4v' },
::    @{Method = 'Registry'; Application = 'VLC.mid'; Extension = '.mid' },
::    @{Method = 'Registry'; Application = 'VLC.mka'; Extension = '.mka' },
::    @{Method = 'Registry'; Application = 'VLC.mkv'; Extension = '.mkv' },
::    @{Method = 'Registry'; Application = 'VLC.mod'; Extension = '.mod' },
::    @{Method = 'Registry'; Application = 'VLC.mov'; Extension = '.mov' },
::    @{Method = 'Registry'; Application = 'VLC.mp2'; Extension = '.mp2' },
::    @{Method = 'Registry'; Application = 'VLC.mp2v'; Extension = '.mp2v' },
::    @{Method = 'Registry'; Application = 'VLC.mp3'; Extension = '.mp3' },
::    @{Method = 'Registry'; Application = 'VLC.mp4'; Extension = '.mp4' },
::    @{Method = 'Registry'; Application = 'VLC.mp4v'; Extension = '.mp4v' },
::    @{Method = 'Registry'; Application = 'VLC.mpa'; Extension = '.mpa' },
::    @{Method = 'Registry'; Application = 'VLC.mpe'; Extension = '.mpe' },
::    @{Method = 'Registry'; Application = 'VLC.mpeg'; Extension = '.mpeg' },
::    @{Method = 'Registry'; Application = 'VLC.mpg'; Extension = '.mpg' },
::    @{Method = 'Registry'; Application = 'VLC.mpv2'; Extension = '.mpv2' },
::    @{Method = 'Registry'; Application = 'VLC.mts'; Extension = '.mts' },
::    @{Method = 'Registry'; Application = 'VLC.rmi'; Extension = '.rmi' },
::    @{Method = 'Registry'; Application = 'VLC.snd'; Extension = '.snd' },
::    @{Method = 'Registry'; Application = 'VLC.ts'; Extension = '.ts' },
::    @{Method = 'Registry'; Application = 'VLC.tts'; Extension = '.tts' },
::    @{Method = 'Registry'; Application = 'VLC.vlt'; Extension = '.vlt' },
::    @{Method = 'Registry'; Application = 'VLC.wav'; Extension = '.wav' },
::    @{Method = 'Registry'; Application = 'VLC.wma'; Extension = '.wma' },
::    @{Method = 'Registry'; Application = 'VLC.wmv'; Extension = '.wmv' },
::    @{Method = 'Registry'; Application = 'VLC.wpl'; Extension = '.wpl' },
::    @{Method = 'Registry'; Application = 'VLC.wsz'; Extension = '.wsz' },
::    @{Method = 'Registry'; Application = 'VLC.wtv'; Extension = '.wtv' },
::    @{Method = 'Registry'; Application = 'VLC.wvx'; Extension = '.wvx' },
::    @{Method = 'Registry'; Application = 'wdpfile'; Extension = '.jxr' },
::    @{Method = 'Registry'; Application = 'wdpfile'; Extension = '.wdp' },
::    @{Method = 'Registry'; Application = 'Windows.IsoFile'; Extension = '.iso' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.gif' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.htm' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.html' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.mhtml' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.shtml' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.svg' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.webp' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.xht' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.xhtml' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = 'http' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = 'https' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = 'mailto' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = 'mms' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = 'tel' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = 'webcal' },
::    @{Method = 'Sophia'; Application = 'ChromePDF'; Extension = '.pdf' },
::    @{Method = 'Sophia'; Application = 'ChromeHTML'; Extension = '.url' },
::    @{Method = 'Sophia'; Application = 'VLC.mp2'; Extension = '.mp2' }
::)
::
::#endregion configs > Windows > File associations
::
::
::#region configs > Windows > Power settings
::
::Set-Variable -Option Constant CONFIG_POWER_SETTINGS @(
::    @{SubGroup = '0d7dbae2-4294-402a-ba8e-26777e8488cd'; Setting = '309dce9b-bef4-4119-9921-a851fb12f0f4'; Value = 0 },
::    @{SubGroup = '02f815b5-a5cf-4c84-bf20-649d1f75d3d8'; Setting = '4c793e7d-a264-42e1-87d3-7a0d2f523ccd'; Value = 1 },
::    @{SubGroup = '19cbb8fa-5279-450e-9fac-8a3d5fedd0c1'; Setting = '12bbebe6-58d6-4636-95bb-3217ef867c1a'; Value = 0 },
::    @{SubGroup = '9596fb26-9850-41fd-ac3e-f7c3c00afd4b'; Setting = '34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4'; Value = 0 },
::    @{SubGroup = '9596fb26-9850-41fd-ac3e-f7c3c00afd4b'; Setting = '03680956-93bc-4294-bba6-4e0f09bb717f'; Value = 1 },
::    @{SubGroup = '9596fb26-9850-41fd-ac3e-f7c3c00afd4b'; Setting = '10778347-1370-4ee0-8bbd-33bdacaade49'; Value = 1 },
::    @{SubGroup = 'de830923-a562-41af-a086-e3a2c6bad2da'; Setting = 'e69653ca-cf7f-4f05-aa73-cb833fa90ad4'; Value = 0 },
::    @{SubGroup = 'SUB_PCIEXPRESS'; Setting = 'ASPM'; Value = 0 },
::    @{SubGroup = 'SUB_PROCESSOR'; Setting = 'SYSCOOLPOL'; Value = 1 },
::    @{SubGroup = 'SUB_SLEEP'; Setting = 'HYBRIDSLEEP'; Value = 1 },
::    @{SubGroup = 'SUB_SLEEP'; Setting = 'RTCWAKE'; Value = 1 }
::)
::
::#endregion configs > Windows > Power settings
::
::
::#region configs > Windows > Base > Windows English
::
::Set-Variable -Option Constant CONFIG_WINDOWS_ENGLISH '[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager]
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
::'
::
::#endregion configs > Windows > Base > Windows English
::
::
::#region configs > Windows > Base > Windows HKEY_CLASSES_ROOT
::
::Set-Variable -Option Constant CONFIG_WINDOWS_HKEY_CLASSES_ROOT '; Disable "Share" context menu
::[-HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing]
::
::; Disable "Give access to" context menu
::[-HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\Sharing]
::[-HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\Sharing]
::[-HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\Sharing]
::[-HKEY_CLASSES_ROOT\Directory\shellex\CopyHookHandlers\Sharing]
::[-HKEY_CLASSES_ROOT\Directory\shellex\PropertySheetHandlers\Sharing]
::[-HKEY_CLASSES_ROOT\Drive\shellex\ContextMenuHandlers\Sharing]
::[-HKEY_CLASSES_ROOT\Drive\shellex\PropertySheetHandlers\Sharing]
::[-HKEY_CLASSES_ROOT\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing]
::[-HKEY_CLASSES_ROOT\UserLibraryFolder\shellex\ContextMenuHandlers\Sharing]
::
::; Disable "Include in library" context menu
::[-HKEY_CLASSES_ROOT\Folder\ShellEx\ContextMenuHandlers\Library Location]
::
::[HKEY_CLASSES_ROOT\icofile\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\jpegfile\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\pngfile\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap]
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,36,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-70"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open]
::"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\
::  69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\
::  00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\
::  72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\
::  00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::'
::
::#endregion configs > Windows > Base > Windows HKEY_CLASSES_ROOT
::
::
::#region configs > Windows > Base > Windows HKEY_CURRENT_USER
::
::Set-Variable -Option Constant CONFIG_WINDOWS_HKEY_CURRENT_USER '; Disable sticky keys shortcut
::[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
::"Flags"="506"
::
::[HKEY_CURRENT_USER\Control Panel\Desktop]
::"JPEGImportQuality"=dword:00000064
::
::[HKEY_CURRENT_USER\Control Panel\International\User Profile]
::"HttpAcceptLanguageOptOut"=dword:00000001
::
::[HKEY_CURRENT_USER\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
::"ShowCmd"=dword:00000003
::"WFlags"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64]
::@=""
::
::[HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]
::"DoNotTrack"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]
::"EnableCortana"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
::"ShowCmd"=dword:00000003
::"WFlags"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Microsoft\Clipboard]
::"EnableClipboardHistory"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Edge\SmartScreenPuaEnabled]
::@=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Feeds]
::"DefaultInterval"=dword:0000000F
::"SyncStatus"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
::"EnableHwkbTextPrediction"=dword:00000001
::"MultilingualEnabled"=dword:00000001
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
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\ContinuousBrowsing]
::"Enabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main]
::"DoNotTrack"=dword:00000001
::"Isolation"="PMEM"
::"Isolation64Bit"=dword:00000001
::"Start Page"="about:blank"
::"Use FormSuggest"="yes"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\PhishingFilter]
::"EnabledV9"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Privacy]
::"CleanDownloadHistory"=dword:00000001
::"CleanForms"=dword:00000001
::"CleanPassword"=dword:00000001
::"ClearBrowsingHistoryOnExit"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Preferences]
::"AcceptedPrivacyStatement"=dword:00000001
::"FirstRun"=dword:00000000
::"MetadataRetrieval"=dword:00000003
::"SilentAcquisition"=dword:00000001
::"UsageTracking"=dword:00000000
::"Volume"=dword:00000064
::
::[HKEY_CURRENT_USER\Software\Microsoft\Notepad]
::"iWindowPosX"=dword:FFFFFFF8
::"iWindowPosY"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\LinkedIn]
::"OfficeLinkedIn"=dword:00000000
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
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\View]
::"WindowPlacement"=hex:2C,00,00,00,02,00,00,00,03,00,00,00,00,83,FF,FF,00,83,\
::  FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,00,00,00,00,00,00,00,00,80,07,00,00,93,03,00,00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics]
::"value"="Deny"
::
::[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
::"Value"="Allow"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation]
::"value"="Deny"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
::"ContentDeliveryAllowed"=dword:00000000
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
::"SubscribedContent-353694Enabled"=dword:00000000 ; Show me suggested content in the Settings app
::"SubscribedContent-353696Enabled"=dword:00000000 ; Show me suggested content in the Settings app
::"SubscribedContent-353698Enabled"=dword:00000000 ; Show me suggested content in the Settings app
::"SubscribedContent-88000045Enabled"=dword:00000000
::"SubscribedContent-88000161Enabled"=dword:00000000
::"SubscribedContent-88000163Enabled"=dword:00000000
::"SubscribedContent-88000165Enabled"=dword:00000000
::"SystemPaneSuggestionsEnabled"=dword:00000000 ; Occasionally show suggestions in Start
::
::; Disable "Tailored experiences with diagnostic data"
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CPSS\Store]
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CrossDeviceResume\Configuration]
::"IsResumeAllowed"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization]
::"SystemSettingsDownloadMode"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack]
::"ShowedToastAtLevel"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
::"MaximizeApps"=dword:00000001
::"ShowRecommendations"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"NavPaneShowAllCloudStates"=dword:00000001
::"SeparateProcess"=dword:00000001
::"ShowCopilotButton"=dword:00000000 ; Disable Copilot button on the taskbar
::"ShowSyncProviderNotifications"=dword:00000000 ; Sync provider ads
::"Start_AccountNotifications"=dword:00000000 ; Disable Show account-related notifications
::"Start_IrisRecommendations"=dword:00000000 ; Show recommendations for tips, shortcuts, new apps, and more in start
::"Start_TrackProgs"=dword:00000000 ; Disable "Let Windows improve Start and search results by tracking app launches"
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
::"{20D04FE0-3AEA-1069-A2D8-08002B30309D}"=dword:00000000
::"MSEdge"=dword:00000001
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
::"SystemFolders"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
::"VisualFXSetting"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
::"AppCaptureEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings]
::"SecureProtocols"=dword:00002820
::"SyncMode5"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache]
::"ContentLimit"=dword:00000008
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content]
::"CacheLimit"=dword:00002000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache]
::"Persistent"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Url History]
::"DaysToKeep"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen]
::"RotatingLockScreenOverlayEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Mobility]
::"CrossDeviceEnabled"=dword:00000000
::"OptedIn"=dword:00000000 ; Disable Show me suggestions for using my mobile device with Windows (Phone Link suggestions)
::"PhoneLinkEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings]
::"NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK"=dword:00000000
::
::; Disable Windows Backup reminder notifications
::[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackupReminder]
::"Enabled"=dword:00000000
::
::; Disable "Suggested" app notifications (Ads for MS services)
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested]
::"Enabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"NoDriveTypeAutoRun"=dword:00000091
::
::; Disable "Tailored experiences with diagnostic data"
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Privacy]
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
::"BingSearchEnabled"=dword:00000000 ; Disable Bing search
::"SearchboxTaskbarMode"=dword:00000003 ; Show search icon and label
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
::"IsDynamicSearchBoxEnabled"=dword:00000000
::
::; Disable Show mobile device in Start
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start\Companions\Microsoft.YourPhone_8wekyb3d8bbwe]
::"IsEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications]
::"EnableAccountNotifications"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy]
::"01"=dword:00000001
::"2048"=dword:0000001E
::
::; Suggest ways I can finish setting up my device to get the most out of Windows
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
::"ScoobeSystemSettingEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy]
::"256"=dword:0000003C
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
::"VideoQualityOnBattery"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WindowsCopilot]
::"AllowCopilotRuntime"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Windows Search]
::"CortanaConsent"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows Security Health\State]
::"AccountProtection_MicrosoftAccount_Disconnected"=dword:00000001
::"Hardware_DataEncryption_AddMsa"=dword:00000000
::
::; Disable personalization of ads, Microsoft Edge, search, news and other Microsoft services by sending browsing history, favorites and collections, usage and other browsing data to Microsoft
::; Disable required and optional diagnostic data about browser usage
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge]
::"AutofillCreditCardEnabled"=dword:00000000
::"ConfigureDoNotTrack"=dword:00000001
::"EdgeShoppingAssistantEnabled"=dword:00000000
::"PaymentMethodQueryEnabled"=dword:00000000
::"PersonalizationReportingEnabled"=dword:00000000
::"UserFeedbackAllowed"=dword:00000000
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
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent]
::"DisableTailoredExperiencesWithDiagnosticData"=dword:00000001
::"DisableWindowsSpotlightOnLockScreen"=dword:00000001
::
::; Disable Bing in search
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
::"DisableSearchBoxSuggestions"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Windows Feeds]
::"EnableFeeds"=dword:00000000
::
::; Disable AI recall
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
::"DisableAIDataAnalysis"=dword:00000001
::
::; Disable Copilot service
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
::"TurnOffWindowsCopilot"=dword:00000001
::
::[HKEY_CURRENT_USER\System\GameConfigStore]
::"GameDVR_EFSEFeatureFlags"=dword:00000000
::"GameDVR_Enabled"=dword:00000000 ; Disable game DVR
::"GameDVR_FSEBehavior"=dword:00000002
::"GameDVR_HonorUserFSEBehaviorMode"=dword:00000001
::'
::
::#endregion configs > Windows > Base > Windows HKEY_CURRENT_USER
::
::
::#region configs > Windows > Base > Windows HKEY_LOCAL_MACHINE
::
::Set-Variable -Option Constant CONFIG_WINDOWS_HKEY_LOCAL_MACHINE '; Disable "Include in library" context menu
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location]
::
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Performance Toolkit\v5\WPRControl\DiagTrackMiniLogger\Boot\RunningProfile]
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CABFolder\Shell\RunAs\Command]
::@="cmd /c DISM.exe /Online /Add-Package /PackagePath:"%1" /NoRestart & pause""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CABFolder\Shell\RunAs]
::"HasLUAShield"=""
::"MUIVerb"="@shell32.dll,-10210"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Msi.Package\shell\Extract\Command]
::@="msiexec.exe /a "%1" /qb TARGETDIR"="%1 extracted""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Msi.Package\shell\Extract]
::"Icon"="shell32.dll,-16817"
::"MUIVerb"="@shell32.dll,-37514"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\Wintrust\Config]
::"EnableCertPaddingCheck"="1"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\TaskSettings]
::"fAllVolumes"=dword:00000001
::"fDeadlineEnabled"=dword:00000001
::"fExclude"=dword:00000000
::"fTaskEnabled"=dword:00000001
::"TaskFrequency"=dword:00000002
::"Volumes"=" "
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\OneDrive]
::"PreventNetworkTrafficPreUserSignIn"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth]
::"AllowAdvertising"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Browser]
::"AllowAddressBarDropdown"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Education]
::"IsEducationEnvironment"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start]
::"HideRecommendedSection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Wifi]
::"AllowAutoConnectToWiFiSenseHotspots"=dword:00000000
::"AllowWiFiHotSpotReporting"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech_OneCore\Preferences]
::"ModelDownloadAllowed"=dword:00000000
::
::; Disable "Let Apps use Advertising ID for Relevant Ads" (Windows 10)
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
::"Enabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics]
::"value"="Deny"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
::"Value"="Allow"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation]
::"value"="Deny"
::
::; Disable "Tailored experiences with diagnostic data"
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store]
::"AllowTelemetry"=dword:00000000
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config]
::"DODownloadMode"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup]
::"CostedNetworkPolicy"=dword:00000001
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
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag]
::"ThisPCPolicy"="Hide"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
::"SecurityHealth"=hex:05,00,00,00,88,26,66,6D,84,2A,DC,01
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
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files]
::"StateFlags"=dword:00000001
::
::; Send only Required Diagnostic and Usage Data
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
::"AllowTelemetry"=dword:00000000
::"MaxTelemetryAllowed"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
::"ConsentPromptBehaviorUser"=dword:00000000
::"FilterAdministratorToken"=dword:00000001
::"PromptOnSecureDesktop"=dword:00000000
::"TypeOfAdminApprovalMode"=dword:00000002
::
::; Disable "Tailored experiences with diagnostic data"
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy]
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::; Disable Windows Backup reminder notifications
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup]
::"DisableMonitoring"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update]
::"AUOptions"=dword:00000004
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971F918-A847-4430-9279-4A52D1EFE18D]
::"RegisteredWithAU"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services]
::"DefaultService"="7971f918-a847-4430-9279-4a52d1efe18d"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Shell\Copilot]
::"CopilotDisabledReason"="IsEnabledForGeographicRegionFailed"
::"IsCopilotAvailable"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Shell\Copilot\BingChat]
::"IsUserEligible"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting]
::"Disabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Search\Preferences]
::"AllowIndexingEncryptedStoresOrItems"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection]
::"SummaryNotificationDisabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\NoExecuteState]
::"LastNoExecuteRadioButtonState"=dword:000036BD
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Acrobat.exe]
::"MitigationOptions"=hex:00,03,00,01,00,00,11,01,10,00,11,00,00,10,00,10,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\AppControlManager.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,11,01,00,00,11,10,01,01,00,30,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\clview.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\excel.exe]
::"MitigationOptions"=hex:00,01,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\excelcnv.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\explorer.exe]
::"MitigationOptions"=hex:00,00,00,01,01,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ExtExport.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\graph.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ie4uinit.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ieinstal.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ielowutil.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ieUnatt.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\iexplore.exe]
::"DisableExceptionChainValidation"=dword:00000000
::"DisableUserModeCallbackFilter"=dword:00000001
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe]
::"AuditLevel"=dword:00000008
::"MitigationOptions"=hex:00,00,00,00,11,10,10,00,00,00,00,00,10,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MicrosoftEdgeUpdate.exe]
::"DisableExceptionChainValidation"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MRT.exe]
::"CFGOptions"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MSACCESS.EXE]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mscorsvw.exe]
::"MitigationOptions"=hex(b):00,00,00,00,01,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe]
::"MitigationOptions"=hex:00,00,00,00,01,31,10,01,10,00,00,00,00,10,00,30,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedgewebview2.exe]
::"MitigationOptions"=hex:00,00,00,00,01,01,00,00,10,01,00,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msfeedssync.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mshta.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsMpEng.exe]
::"CFGOptions"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msoadfsb.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msoasb.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msohtmed.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msosrec.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msoxmled.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MSPUB.EXE]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msqry32.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ngen.exe]
::"MitigationOptions"=hex(b):00,00,00,00,01,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ngentask.exe]
::"MitigationOptions"=hex(b):00,00,00,00,01,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\NisSrv.exe]
::"MitigationOptions"=hex:00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe]
::"UseFilter"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\0]
::"AppExecutionAliasRedirect"=dword:00000001
::"AppExecutionAliasRedirectPackages"="*"
::"FilterFullPath"="C:\\Windows\\System32\\notepad.exe"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\1]
::"AppExecutionAliasRedirect"=dword:00000001
::"AppExecutionAliasRedirectPackages"="*"
::"FilterFullPath"="C:\\Windows\\SysWOW64\\notepad.exe"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\2]
::"AppExecutionAliasRedirect"=dword:00000001
::"AppExecutionAliasRedirectPackages"="*"
::"FilterFullPath"="C:\\Windows\\notepad.exe"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\OneDrive.exe]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ONENOTE.EXE]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\orgchart.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\OUTLOOK.EXE]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\powerpnt.exe]
::"MitigationOptions"=hex:00,01,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\PresentationHost.exe]
::"MitigationOptions"=hex(b):11,11,11,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\PrintIsolationHost.exe]
::"MitigationOptions"=hex(b):00,00,20,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\QuickAssist.exe]
::"MitigationOptions"=hex:00,00,00,01,11,30,11,01,10,00,11,10,01,11,00,30,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Regsvr32.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,00,01,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\rundll32.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,01,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\runtimebroker.exe]
::"MitigationOptions"=hex:00,00,00,00,01,01,00,00,10,01,00,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sdxhelper.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\selfcert.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\services.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\setlang.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SmartScreen.exe]
::"MitigationOptions"=hex:00,00,00,00,01,11,00,00,00,01,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SMSS.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\splwow64.exe]
::"MitigationOptions"=hex(b):00,00,20,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\spoolsv.exe]
::"MitigationOptions"=hex(b):00,00,20,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe]
::"MinimumStackCommitInBytes"=dword:00008000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SystemSettings.exe]
::"MitigationOptions"=hex(b):00,00,00,00,01,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VBoxHeadless.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VBoxNetDHCP.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VirtualBox.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VirtualBoxVM.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\vmcompute.exe]
::"MitigationOptions"=hex:00,00,00,00,00,01,00,00,00,01,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\vmwp.exe]
::"MitigationOptions"=hex:00,00,00,00,00,01,00,00,00,01,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\windows10universal.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WindowsSandbox.exe]
::"MitigationOptions"=hex:00,00,00,01,01,11,10,01,10,01,00,10,01,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WindowsSandboxClient.exe]
::"MitigationOptions"=hex:00,00,00,01,01,11,10,01,10,01,00,10,01,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Wininit.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\winword.exe]
::"MitigationOptions"=hex:00,01,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wordconv.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wpr.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  10
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wprui.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  10
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile]
::"NetworkThrottlingIndex"=dword:FFFFFFFF
::"SystemResponsiveness"=dword:00000010
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}]
::"SensorPermissionState"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]
::"scremoveoption"="1"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities]
::"ApplicationDescription"="@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3069"
::"ApplicationName"="@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3009"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations]
::".bmp"="PhotoViewer.FileAssoc.Bitmap"
::".cr2"="TIFImage.Document"
::".dib"="PhotoViewer.FileAssoc.Bitmap"
::".ico"="icofile"
::".jfif"="pjpegfile"
::".jpe"="jpegfile"
::".jpeg"="jpegfile"
::".jpg"="jpegfile"
::".jxr"="wdpfile"
::".png"="pngfile"
::".wdp"="wdpfile"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search]
::"EnableFindMyFiles"=dword:00000001
::"SystemIndexNormalization"=dword:00000003
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex]
::"EnableFindMyFiles"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings]
::"AllowAutoWindowsUpdateDownloadOverMeteredNetwork"=dword:00000001
::"AllowMUUpdateService"=dword:00000001
::"IsContinuousInnovationOptedIn"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\StateVariables]
::"AlwaysAllowMeteredNetwork"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\BraveSoftware\Brave]
::"BraveAIChatEnabled"=dword:00000000
::"BraveRewardsDisabled"=dword:00000001
::"BraveVPNDisabled"=dword:00000001
::"BraveWalletDisabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Cryptography]
::"ForceKeyProtection"=dword:00000001
::
::; Disable Microsoft Edge MSN news feed, sponsored links, shopping assistant and more.
::; Disable personalization of ads, Microsoft Edge, search, news and other Microsoft services by sending browsing history, favorites and collections, usage and other browsing data to Microsoft
::; Disable required and optional diagnostic data about browser usage
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
::"AlternateErrorPagesEnabled"=dword:00000000
::"AudioSandboxEnabled"=dword:00000001
::"BasicAuthOverHttpEnabled"=dword:00000000
::"ComposeInlineEnabled"=dword:00000000
::"ConfigureDoNotTrack"=dword:00000001
::"CopilotCDPPageContext"=dword:00000000
::"CopilotPageContext"=dword:00000000
::"CryptoWalletEnabled"=dword:00000000
::"DefaultWebUsbGuardSetting"=dword:00000002
::"DefaultWindowManagementSetting"=dword:00000002
::"DiagnosticData"=dword:00000000
::"DnsOverHttpsMode"="automatic"
::"DynamicCodeSettings"=dword:00000001
::"EdgeAssetDeliveryServiceEnabled"=dword:00000000
::"EdgeCollectionsEnabled"=dword:00000000
::"EdgeEntraCopilotPageContext"=dword:00000000
::"EdgeHistoryAISearchEnabled"=dword:00000000
::"EdgeShoppingAssistantEnabled"=dword:00000000
::"EncryptedClientHelloEnabled"=dword:00000001
::"ExperimentationAndConfigurationServiceControl"=dword:00000002
::"GenAILocalFoundationalModelSettings"=dword:00000001
::"HideFirstRunExperience"=dword:00000001
::"HubsSidebarEnabled"=dword:00000000
::"MicrosoftEdgeInsiderPromotionEnabled"=dword:00000000
::"NewTabPageBingChatEnabled"=dword:00000000
::"NewTabPageContentEnabled"=dword:00000000
::"NewTabPageHideDefaultTopSites"=dword:00000001
::"PersonalizationReportingEnabled"=dword:00000000
::"ShowMicrosoftRewards"=dword:00000000
::"ShowRecommendationsEnabled"=dword:00000000
::"TabServicesEnabled"=dword:00000000
::"UserFeedbackAllowed"=dword:00000000
::"WalletDonationEnabled"=dword:00000000
::"WebWidgetAllowed"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\Recommended]
::"BlockThirdPartyCookies"=dword:00000001
::"DefaultShareAdditionalOSRegionSetting"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\TLSCipherSuiteDenyList]
::"1"="0xc013"
::"2"="0xc014"
::"3"="0x0035"
::"4"="0x002f"
::"5"="0x009c"
::"6"="0x009d"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate]
::"CreateDesktopShortcutDefault"=dword:00000000
::
::; Disable "Inking and Typing Personalization"
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\InputPersonalization]
::"AllowInputPersonalization"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main]
::"AllowPrelaunch"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MRT]
::"DontReportInfectionInformation"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Speech]
::"AllowSpeechModelUpdate"=dword:00000000
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
::"DisableConsumerAccountStateContent"=dword:00000001 ; Disable MS 365 Ads in Settings Home
::"DisableWindowsConsumerFeatures"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection]
::"AllowTelemetry"=dword:00000000 ; Send only Required Diagnostic and Usage Data
::"DisableOneSettingsDownloads"=dword:00000001
::"DoNotShowFeedbackNotifications"=dword:00000001
::"LimitDiagnosticLogCollection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization]
::"DODownloadMode"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
::"HideRecommendedSection"=dword:00000001
::
::; Disable game DVR
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR]
::"AllowGameDVR"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports]
::"PreventHandwritingErrorReports"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors]
::"DisableLocationScripting"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Messaging]
::"AllowMessageSync"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive]
::"DisableFileSyncNGSC"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization]
::"NoLockScreenCamera"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
::"AllowClipboardHistory"=dword:00000000
::"AllowCrossDeviceClipboard"=dword:00000000
::"EnableActivityFeed"=dword:00000000
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
::"AllowCloudSearch"=dword:00000000
::"AllowCortana"=dword:00000000 ; Disable Cortana in search
::"AllowCortanaAboveLock"=dword:00000000 ; Disable Cortana in search
::"AllowSearchToUseLocation"=dword:00000000
::"ConnectedSearchUseWeb"=dword:00000000
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
::; Disable Copilot service
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
::"TurnOffWindowsCopilot"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet]
::"SpyNetReporting"=dword:00000000
::"SubmitSamplesConsent"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services]
::"fAllowToGetHelp"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Cryptography\Wintrust\Config]
::"EnableCertPaddingCheck"="1"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\ClientStateMedium\{0D50BFEC-CD6A-4F9A-964C-C7416E3ACB10}]
::"allowautoupdatesmetered"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\ClientStateMedium\{2CD8A007-E189-409D-A2C8-9AF4EF3C72AA}]
::"allowautoupdatesmetered"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\ClientStateMedium\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}]
::"allowautoupdatesmetered"=dword:00000001
::
::; Send only Required Diagnostic and Usage Data
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
::"AllowTelemetry"=dword:00000000
::"MaxTelemetryAllowed"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System]
::"ConsentPromptBehaviorUser"=dword:00000000
::"FilterAdministratorToken"=dword:00000001
::"PromptOnSecureDesktop"=dword:00000000
::"TypeOfAdminApprovalMode"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Acrobat.exe]
::"MitigationOptions"=hex:00,03,00,01,00,00,11,01,10,00,11,00,00,10,00,10,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\AppControlManager.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,11,01,00,00,11,10,01,01,00,30,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\clview.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\excel.exe]
::"MitigationOptions"=hex:00,01,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\excelcnv.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\explorer.exe]
::"MitigationOptions"=hex:00,00,00,01,01,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ExtExport.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\graph.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ie4uinit.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ieinstal.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ielowutil.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ieUnatt.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\iexplore.exe]
::"DisableExceptionChainValidation"=dword:00000000
::"DisableUserModeCallbackFilter"=dword:00000001
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe]
::"AuditLevel"=dword:00000008
::"MitigationOptions"=hex:00,00,00,00,11,10,10,00,00,00,00,00,10,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MicrosoftEdgeUpdate.exe]
::"DisableExceptionChainValidation"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MRT.exe]
::"CFGOptions"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MSACCESS.EXE]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mscorsvw.exe]
::"MitigationOptions"=hex(b):00,00,00,00,01,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe]
::"MitigationOptions"=hex:00,00,00,00,01,31,10,01,10,00,00,00,00,10,00,30,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedgewebview2.exe]
::"MitigationOptions"=hex:00,00,00,00,01,01,00,00,10,01,00,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msfeedssync.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mshta.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsMpEng.exe]
::"CFGOptions"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msoadfsb.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msoasb.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msohtmed.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msosrec.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msoxmled.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MSPUB.EXE]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msqry32.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ngen.exe]
::"MitigationOptions"=hex(b):00,00,00,00,01,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ngentask.exe]
::"MitigationOptions"=hex(b):00,00,00,00,01,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\NisSrv.exe]
::"MitigationOptions"=hex:00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe]
::"UseFilter"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\0]
::"AppExecutionAliasRedirect"=dword:00000001
::"AppExecutionAliasRedirectPackages"="*"
::"FilterFullPath"="C:\\Windows\\System32\\notepad.exe"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\1]
::"AppExecutionAliasRedirect"=dword:00000001
::"AppExecutionAliasRedirectPackages"="*"
::"FilterFullPath"="C:\\Windows\\SysWOW64\\notepad.exe"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\2]
::"AppExecutionAliasRedirect"=dword:00000001
::"AppExecutionAliasRedirectPackages"="*"
::"FilterFullPath"="C:\\Windows\\notepad.exe"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\OneDrive.exe]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ONENOTE.EXE]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\orgchart.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\OUTLOOK.EXE]
::"MitigationOptions"=hex:00,00,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\powerpnt.exe]
::"MitigationOptions"=hex:00,01,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\PresentationHost.exe]
::"MitigationOptions"=hex(b):11,11,11,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\PrintIsolationHost.exe]
::"MitigationOptions"=hex(b):00,00,20,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\QuickAssist.exe]
::"MitigationOptions"=hex:00,00,00,01,11,30,11,01,10,00,11,10,01,11,00,30,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Regsvr32.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,00,01,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\rundll32.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,01,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\runtimebroker.exe]
::"MitigationOptions"=hex:00,00,00,00,01,01,00,00,10,01,00,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sdxhelper.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\selfcert.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\services.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\setlang.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SmartScreen.exe]
::"MitigationOptions"=hex:00,00,00,00,01,11,00,00,00,01,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SMSS.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\splwow64.exe]
::"MitigationOptions"=hex(b):00,00,20,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\spoolsv.exe]
::"MitigationOptions"=hex(b):00,00,20,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe]
::"MinimumStackCommitInBytes"=dword:00008000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SystemSettings.exe]
::"MitigationOptions"=hex(b):00,00,00,00,01,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VBoxHeadless.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VBoxNetDHCP.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VirtualBox.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VirtualBoxVM.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\vmcompute.exe]
::"MitigationOptions"=hex:00,00,00,00,00,01,00,00,00,01,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\vmwp.exe]
::"MitigationOptions"=hex:00,00,00,00,00,01,00,00,00,01,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\windows10universal.exe]
::"ImageExpansionMitigation"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WindowsSandbox.exe]
::"MitigationOptions"=hex:00,00,00,01,01,11,10,01,10,01,00,10,01,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WindowsSandboxClient.exe]
::"MitigationOptions"=hex:00,00,00,01,01,11,10,01,10,01,00,10,01,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Wininit.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,10,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\winword.exe]
::"MitigationOptions"=hex:00,01,00,01,01,30,00,00,10,00,11,00,00,10,00,00,00,00,\
::  00,00,00,00,00,00
::"MitigationAuditOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  00,00,00,00,00,00,00,00
::"EAFModules"=""
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wordconv.exe]
::"MitigationOptions"=hex(b):00,01,00,00,00,00,00,00
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wpr.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  10
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wprui.exe]
::"MitigationOptions"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
::  10
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows Search]
::"EnableFindMyFiles"=dword:00000001
::"SystemIndexNormalization"=dword:00000003
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows Search\Gather\Windows\SystemIndex]
::"EnableFindMyFiles"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Cryptography]
::"ForceKeyProtection"=dword:00000001
::
::; Disable personalization of ads, Microsoft Edge, search, news and other Microsoft services by sending browsing history, favorites and collections, usage and other browsing data to Microsoft
::; Disable required and optional diagnostic data about browser usage
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge]
::"AlternateErrorPagesEnabled"=dword:00000000
::"AudioSandboxEnabled"=dword:00000001
::"BasicAuthOverHttpEnabled"=dword:00000000
::"ComposeInlineEnabled"=dword:00000000
::"ConfigureDoNotTrack"=dword:00000001
::"CopilotCDPPageContext"=dword:00000000
::"CopilotPageContext"=dword:00000000
::"DefaultWebUsbGuardSetting"=dword:00000002
::"DefaultWindowManagementSetting"=dword:00000002
::"DiagnosticData"=dword:00000000
::"DnsOverHttpsMode"="automatic"
::"DynamicCodeSettings"=dword:00000001
::"EdgeEntraCopilotPageContext"=dword:00000000
::"EdgeHistoryAISearchEnabled"=dword:00000000
::"EdgeShoppingAssistantEnabled"=dword:00000000
::"EncryptedClientHelloEnabled"=dword:00000001
::"ExperimentationAndConfigurationServiceControl"=dword:00000002
::"GenAILocalFoundationalModelSettings"=dword:00000001
::"HubsSidebarEnabled"=dword:00000000
::"NewTabPageBingChatEnabled"=dword:00000000
::"NewTabPageContentEnabled"=dword:00000000
::"NewTabPageHideDefaultTopSites"=dword:00000001
::"PersonalizationReportingEnabled"=dword:00000000
::"TabServicesEnabled"=dword:00000000
::"UserFeedbackAllowed"=dword:00000000
::"WebWidgetAllowed"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\Recommended]
::"BlockThirdPartyCookies"=dword:00000001
::"DefaultShareAdditionalOSRegionSetting"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\TLSCipherSuiteDenyList]
::"1"="0xc013"
::"2"="0xc014"
::"3"="0x0035"
::"4"="0x002f"
::"5"="0x009c"
::"6"="0x009d"
::
::; Disable "Inking and Typing Personalization"
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\InputPersonalization]
::"AllowInputPersonalization"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\MicrosoftEdge\Main]
::"AllowPrelaunch"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\MRT]
::"DontReportInfectionInformation"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Speech]
::"AllowSpeechModelUpdate"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\AppCompat]
::"AITEnable"=dword:00000000
::"DisableInventory"=dword:00000001
::"DisableUAR"=dword:00000001
::
::; Disable MS 365 Ads in Settings Home
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\CloudContent]
::"DisableConsumerAccountStateContent"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\DataCollection]
::"AllowTelemetry"=dword:00000000 ; Send only Required Diagnostic and Usage Data
::"DisableOneSettingsDownloads"=dword:00000001
::"DoNotShowFeedbackNotifications"=dword:00000001
::"LimitDiagnosticLogCollection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\DeliveryOptimization]
::"DODownloadMode"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Explorer]
::"HideRecommendedSection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\HandwritingErrorReports]
::"PreventHandwritingErrorReports"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\LocationAndSensors]
::"DisableLocationScripting"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Messaging]
::"AllowMessageSync"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Personalization]
::"NoLockScreenCamera"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\System]
::"AllowClipboardHistory"=dword:00000000
::"AllowCrossDeviceClipboard"=dword:00000000
::"EnableActivityFeed"=dword:00000000
::"EnableMmx"=dword:00000000
::"PublishUserActivities"=dword:00000000 ; Disable "Activity History"
::"UploadUserActivities"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\TabletPC]
::"PreventHandwritingDataSharing"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Windows Feeds]
::"EnableFeeds"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Windows Search]
::"AllowCloudSearch"=dword:00000000
::"AllowCortana"=dword:00000000 ; Disable Cortana in search
::"AllowCortanaAboveLock"=dword:00000000 ; Disable Cortana in search
::"AllowSearchToUseLocation"=dword:00000000
::"ConnectedSearchUseWeb"=dword:00000000
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
::; Disable Copilot service
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsCopilot]
::"TurnOffWindowsCopilot"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender\Spynet]
::"SpyNetReporting"=dword:00000000
::"SubmitSamplesConsent"=dword:00000002
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows NT\Terminal Services]
::"fAllowToGetHelp"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control]
::"SvcHostSplitThresholdInKB"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Policy]
::"VerifiedAndReputablePolicyState"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl]
::"DisableEmoticon"=dword:00000001
::"DisplayParameters"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
::"LongPathsEnabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa]
::"LmCompatibilityLevel"=dword:00000005
::"restrictanonymous"=dword:00000001
::"RestrictRemoteSAM"="O:BAG:BAD:(A;;RC;;;BA)"
::"SCENoApplyLegacyAuditPolicy"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0]
::"allownullsessionfallback"=dword:00000000
::"NtlmMinClientSec"=dword:20080000
::"NtlmMinServerSec"=dword:20080000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling]
::"PowerThrottlingOff"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance]
::"fAllowToGetHelp"=dword:00000000
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
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager]
::"EnablePeriodicBackup"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment]
::"MP_FORCE_USE_SANDBOX"="1"
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener]
::"Start"=dword:00000000
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
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters]
::"DefaultTTL"=dword:00000064
::"GlobalMaxTcpWindowSize"=dword:00065535
::"MaxUserPort"=dword:00065534
::"Tcp1323Opts"=dword:00000001
::"TcpMaxDupAcks"=dword:00000002
::"TCPTimedWaitDelay"=dword:00000030
::
::[HKEY_LOCAL_MACHINE\SYSTEM\Maps]
::"AutoUpdateEnabled"=dword:00000000
::"UpdateOnlyOnWifi"=dword:00000000
::'
::
::#endregion configs > Windows > Base > Windows HKEY_LOCAL_MACHINE
::
::
::#region configs > Windows > Base > Windows HKEY_USERS
::
::Set-Variable -Option Constant CONFIG_WINDOWS_HKEY_USERS '[HKEY_USERS\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Usage]
::"CacheServerConnectionCount"=dword:00000000
::"DownlinkUsageBps"=dword:00000000
::"SwarmCount"=dword:00000000
::"UploadCount"=dword:00000000
::"CacheSizeBytes"=hex:00,00,00,00,00,00,00,00
::'
::
::#endregion configs > Windows > Base > Windows HKEY_USERS
::
::
::#region configs > Windows > Base > Windows Russian
::
::Set-Variable -Option Constant CONFIG_WINDOWS_RUSSIAN '[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager]
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
::'
::
::#endregion configs > Windows > Base > Windows Russian
::
::
::#region configs > Windows > Personalisation > Windows personalisation HKEY_CLASSES_ROOT
::
::Set-Variable -Option Constant CONFIG_WINDOWS_PERSONALISATION_HKEY_CLASSES_ROOT '; Hide "OneDrive" folder
::[HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}]
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::; Hide Gallery on Navigation Pane
::[HKEY_CLASSES_ROOT\CLSID\{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}]
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::; Hide Home on Navigation Pane
::[HKEY_CLASSES_ROOT\CLSID\{F874310E-B6B7-47DC-BC84-B9E6B38F5903}]
::@="CLSID_MSGraphHomeFolder"
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::; Hide "OneDrive" folder
::[HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}]
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::'
::
::#endregion configs > Windows > Personalisation > Windows personalisation HKEY_CLASSES_ROOT
::
::
::#region configs > Windows > Personalisation > Windows personalisation HKEY_CURRENT_USER
::
::Set-Variable -Option Constant CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER '; Hide "OneDrive" folder
::[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}]
::
::; Hide "OneDrive" folder
::[HKEY_CURRENT_USER\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}]
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::; Enable classic context menu
::[HKEY_CURRENT_USER\Software\Classes\CLSID\{86CA1AA0-34AA-4E8B-A509-50C905BAE2A2}\InprocServer32]
::@=""
::
::; Hide Gallery on Navigation Pane
::[HKEY_CURRENT_USER\Software\Classes\CLSID\{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}]
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::; Hide Home on Navigation Pane
::[HKEY_CURRENT_USER\Software\Classes\CLSID\{F874310E-B6B7-47DC-BC84-B9E6B38F5903}]
::@="CLSID_MSGraphHomeFolder"
::"System.IsPinnedToNameSpaceTree"=dword:00000000
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
::"Hidden"=dword:00000001 ; Show hidden files
::"LaunchTo"=dword:00000001 ; Launch File Explorer to "This PC"
::"NavPaneExpandToCurrentFolder"=dword:00000001
::"NavPaneShowAllFolders"=dword:00000001
::"ShowTaskViewButton"=dword:00000000 ; Hide Task View in the taskbar
::"Start_Layout"=dword:00000001
::"TaskbarAl"=dword:00000000 ; Align taskbar left
::"TaskbarGlomLevel"=dword:00000001 ; Combine taskbar when full
::"TaskbarMn"=dword:00000000 ; Disable chat taskbar (Windows 11)
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People]
::"PeopleBand"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
::"{2cc5ca98-6485-489a-920e-b3e88a6ccce3}"=dword:00000001
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
::'
::
::#endregion configs > Windows > Personalisation > Windows personalisation HKEY_CURRENT_USER
::
::
::#region configs > Windows > Personalisation > Windows personalisation HKEY_LOCAL_MACHINE
::
::Set-Variable -Option Constant CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE '; Hide "3D objects" folder
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
::
::; Hide "Music" folder
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3DFDF296-DBEC-4FB4-81D1-6A3438BCF4DE}]
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3DFDF296-DBEC-4FB4-81D1-6A3438BCF4DE}]
::
::; Disable widgets service
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests]
::"value"=dword:00000000
::
::; Add `Show Gallery` option to File Explorer folder options, with default set to disabled
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery]
::"CheckedValue"=dword:00000001
::"DefaultValue"=dword:00000000
::"HKeyRoot"=dword:80000001
::"Id"=dword:0000000d
::"RegPath"="Software\\Classes\\CLSID\\{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}"
::"Text"="Show Gallery"
::"Type"="checkbox"
::"UncheckedValue"=dword:00000000
::"ValueName"="System.IsPinnedToNameSpaceTree"
::
::; Add `Show Home` option to File Explorer folder options, with default set to disabled
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome]
::"CheckedValue"=dword:00000001
::"DefaultValue"=dword:00000000
::"HKeyRoot"=dword:80000001
::"Id"=dword:0000000d
::"RegPath"="Software\\Classes\\CLSID\\{F874310E-B6B7-47DC-BC84-B9E6B38F5903}"
::"Text"="Show Home"
::"Type"="checkbox"
::"UncheckedValue"=dword:00000000
::"ValueName"="System.IsPinnedToNameSpaceTree"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"HideSCAMeetNow"=dword:00000001 ; Disable chat taskbar (Windows 10)
::"SettingsPageVisibility"="hide:home" ; Disable Home page in settings
::
::; Disable widgets service
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh]
::"AllowNewsAndInterests"=dword:00000000
::
::; Disable chat taskbar (Windows 10)
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"HideSCAMeetNow"=dword:00000001
::
::; Disable widgets service
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Dsh]
::"AllowNewsAndInterests"=dword:00000000
::'
::
::#endregion configs > Windows > Personalisation > Windows personalisation HKEY_LOCAL_MACHINE
::
::
::#region configs > Windows > Tools > Debloat app list
::
::Set-Variable -Option Constant CONFIG_DEBLOAT_APP_LIST 'ACGMediaPlayer                                 # Media player app
::ActiproSoftwareLLC                             # Potentially UI controls or software components, often bundled by OEMs
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
::Microsoft.549981C3F5F10                        # Cortana app (Voice assistant)
::Microsoft.BingFinance                          # Finance news and tracking via Bing (Discontinued)
::Microsoft.BingFoodAndDrink                     # Recipes and food news via Bing (Discontinued)
::Microsoft.BingHealthAndFitness                 # Health and fitness tracking/news via Bing (Discontinued)
::Microsoft.BingNews                             # News aggregator via Bing (Replaced by Microsoft News/Start)
::Microsoft.BingSearch                           # Web Search from Microsoft Bing (Integrates into Windows Search)
::Microsoft.BingSports                           # Sports news and scores via Bing (Discontinued)
::Microsoft.BingTranslator                       # Translation service via Bing
::Microsoft.BingTravel                           # Travel planning and news via Bing (Discontinued)
::Microsoft.Copilot                              # AI assistant integrated into Windows
::Microsoft.Getstarted                           # Tips and introductory guide for Windows (Cannot be uninstalled in Windows 11)
::Microsoft.Messaging                            # Messaging app, often integrates with Skype (Largely deprecated)
::Microsoft.Microsoft3DViewer                    # Viewer for 3D models
::Microsoft.MicrosoftJournal                     # Digital note-taking app optimized for pen input
::Microsoft.MicrosoftOfficeHub                   # Hub to access Microsoft Office apps and documents (Precursor to Microsoft 365 app)
::Microsoft.MicrosoftPowerBIForWindows           # Business analytics service client
::Microsoft.MicrosoftStickyNotes                 # Digital sticky notes app (Deprecated & replaced by OneNote)
::Microsoft.MixedReality.Portal                  # Portal for Windows Mixed Reality headsets
::Microsoft.NetworkSpeedTest                     # Internet connection speed test utility
::Microsoft.News                                 # News aggregator (Replaced Bing News, now part of Microsoft Start)
::Microsoft.Office.OneNote                       # Digital note-taking app (Universal Windows Platform version)
::Microsoft.Office.Sway                          # Presentation and storytelling app
::Microsoft.OneConnect                           # Mobile Operator management app (Replaced by Mobile Plans)
::Microsoft.OutlookForWindows                    # New mail app: Outlook for Windows
::Microsoft.People                               # Required for & included with Mail & Calendar (Contacts management)
::Microsoft.PowerAutomateDesktop                 # Desktop automation tool (RPA)
::Microsoft.Print3D                              # 3D printing preparation software
::Microsoft.RemoteDesktop                        # Remote Desktop client app
::Microsoft.ScreenSketch                         # Snipping Tool (Screenshot and annotation tool)
::Microsoft.SkypeApp                             # Skype communication app (Universal Windows Platform version)
::Microsoft.StartExperiencesApp                  # This app powers Windows Widgets My Feed
::Microsoft.Todos                                # To-do list and task management app
::Microsoft.Whiteboard                           # Digital collaborative whiteboard app
::Microsoft.Windows.DevHome                      # Developer dashboard and tool configuration utility
::Microsoft.WindowsAlarms                        # Alarms & Clock app
::Microsoft.windowscommunicationsapps            # Mail & Calendar app suite
::Microsoft.WindowsFeedbackHub                   # App for providing feedback to Microsoft on Windows
::Microsoft.WindowsMaps                          # Mapping and navigation app
::Microsoft.WindowsSoundRecorder                 # Basic audio recording app
::Microsoft.WindowsTerminal                      # New default terminal app in windows 11 (Command Prompt, PowerShell, WSL)
::Microsoft.Xbox.TCUI                            # UI framework, seems to be required for MS store, photos and certain games
::Microsoft.XboxApp                              # Old Xbox Console Companion App, no longer supported
::Microsoft.XboxGameOverlay                      # Game overlay, required/useful for some games (Part of Xbox Game Bar)
::Microsoft.XboxSpeechToTextOverlay              # Might be required for some games, WARNING: This app cannot be reinstalled easily! (Accessibility feature)
::Microsoft.YourPhone                            # Phone link (Connects Android/iOS phone to PC)
::Microsoft.ZuneMusic                            # Modern Media Player (Replaced Groove Music, plays local audio/video)
::Microsoft.ZuneVideo                            # Movies & TV app for renting/buying/playing video content (Rebranded as "Films & TV")
::MicrosoftCorporationII.MicrosoftFamily         # Family Safety App for managing family accounts and settings
::MicrosoftCorporationII.QuickAssist             # Remote assistance tool
::MicrosoftTeams                                 # Old MS Teams personal (MS Store version)
::MicrosoftWindows.CrossDevice                   # Phone integration within File Explorer, Camera and more (Part of Phone Link features)
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
::'
::
::#endregion configs > Windows > Tools > Debloat app list
::
::
::#region configs > Windows > Tools > Debloat preset base
::
::Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET_BASE 'CreateRestorePoint#- Create a system restore point
::DisableBing#- Disable & remove Bing web search, Bing AI and Cortana from Windows search
::DisableClickToDo#- Disable Click to Do (AI text & image analysis)
::DisableCopilot#- Disable & remove Microsoft Copilot
::DisableEdgeAds#- Disable ads, suggestions and the MSN news feed in Microsoft Edge
::DisableRecall#- Disable Windows Recall
::DisableSettings365Ads#- Disable Microsoft 365 ads in Settings Home
::DisableStartPhoneLink#- Disable the Phone Link mobile devices integration in the start menu.
::DisableStickyKeys#- Disable the Sticky Keys keyboard shortcut
::DisableSuggestions#- Disable tips, tricks, suggestions and ads in start, settings, notifications and File Explorer
::DisableTelemetry#- Disable telemetry, diagnostic data, activity history, app-launch tracking & targeted ads
::EnableEndTask#- Enable the "End Task" option in the taskbar right click menu
::HideDupliDrive#- Hide duplicate removable drive entries from the File Explorer sidepanel
::HideGallery#- Hide the Gallery section from the File Explorer sidepanel
::HideGiveAccessTo#- Hide the "Give access to" option in the context menu
::HideHome#- Hide the Home section from the File Explorer sidepanel
::HideIncludeInLibrary#- Hide the "Include in library" option in the context menu
::HideShare#- Hide the "Share" option in the context menu
::ShowHiddenFolders#- Show hidden files, folders and drives
::ShowSearchLabelTb#- Show search icon with label on the taskbar
::RemoveAppsCustom#- Remove 101 apps:
::'
::
::#endregion configs > Windows > Tools > Debloat preset base
::
::
::#region configs > Windows > Tools > Debloat preset personalisation
::
::Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET_PERSONALISATION 'CombineTaskbarWhenFull#- Combine taskbar buttons and hide labels when taskbar is full
::DisableLockscreenTips#- Disable tips & tricks on the lockscreen
::DisableStartRecommended#- Disable the recommended section in the start menu.
::DisableWidgets#- Disable widgets on the taskbar & lockscreen
::ExplorerToThisPC#- Change the default location that File Explorer opens to "This PC"
::HideTaskview#- Hide the taskview button from the taskbar
::RevertContextMenu#- Restore the old Windows 10 style context menu
::TaskbarAlignLeft#- Align taskbar icons to the left
::'
::
::#endregion configs > Windows > Tools > Debloat preset personalisation
::
::
::#region configs > Windows > Tools > OOShutUp10
::
::Set-Variable -Option Constant CONFIG_OOSHUTUP10 'P001	+	# Disable sharing of handwriting data (Category: Privacy)
::P002	+	# Disable sharing of handwriting error reports (Category: Privacy)
::P003	+	# Disable Inventory Collector (Category: Privacy)
::P004	+	# Disable camera in logon screen (Category: Privacy)
::P005	+	# Disable and reset Advertising ID and info for the machine (Category: Privacy)
::P006	+	# Disable and reset Advertising ID and info (Category: Privacy)
::P008	+	# Disable transmission of typing information (Category: Privacy)
::P026	+	# Disable advertisements via Bluetooth (Category: Privacy)
::P027	+	# Disable the Windows Customer Experience Improvement Program (Category: Privacy)
::P028	+	# Disable backup of text messages into the cloud (Category: Privacy)
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
::A002	+	# Disable storing users" activity history (Category: Activity History and Clipboard)
::A003	+	# Disable the submission of user activities to Microsoft (Category: Activity History and Clipboard)
::A004	+	# Disable storage of clipboard history for whole machine (Category: Activity History and Clipboard)
::A006	+	# Disable storage of clipboard history (Category: Activity History and Clipboard)
::A005	+	# Disable the transfer of the clipboard to other devices via the cloud (Category: Activity History and Clipboard)
::P007	+	# Disable app access to user account information (Category: App Privacy)
::P036	+	# Disable app access to user account information (Category: App Privacy)
::P025	+	# Disable Windows tracking of app starts (Category: App Privacy)
::P033	+	# Disable app access to diagnostics information (Category: App Privacy)
::P023	+	# Disable app access to diagnostics information (Category: App Privacy)
::P056	-	# Disable app access to device location (Category: App Privacy)
::P057	-	# Disable app access to device location (Category: App Privacy)
::P012	-	# Disable app access to camera (Category: App Privacy)
::P034	-	# Disable app access to camera (Category: App Privacy)
::P013	-	# Disable app access to microphone (Category: App Privacy)
::P035	-	# Disable app access to microphone (Category: App Privacy)
::P062	-	# Disable app access to use voice activation (Category: App Privacy)
::P063	-	# Disable app access to use voice activation when device is locked (Category: App Privacy)
::P081	-	# Disable the standard app for the headset button (Category: App Privacy)
::P047	-	# Disable app access to notifications (Category: App Privacy)
::P019	-	# Disable app access to notifications (Category: App Privacy)
::P048	-	# Disable app access to motion (Category: App Privacy)
::P049	-	# Disable app access to movements (Category: App Privacy)
::P020	-	# Disable app access to contacts (Category: App Privacy)
::P037	-	# Disable app access to contacts (Category: App Privacy)
::P011	-	# Disable app access to calendar (Category: App Privacy)
::P038	-	# Disable app access to calendar (Category: App Privacy)
::P050	-	# Disable app access to phone calls (Category: App Privacy)
::P051	-	# Disable app access to phone calls (Category: App Privacy)
::P018	-	# Disable app access to call history (Category: App Privacy)
::P039	-	# Disable app access to call history (Category: App Privacy)
::P021	-	# Disable app access to email (Category: App Privacy)
::P040	-	# Disable app access to email (Category: App Privacy)
::P022	-	# Disable app access to tasks (Category: App Privacy)
::P041	-	# Disable app access to tasks (Category: App Privacy)
::P014	-	# Disable app access to messages (Category: App Privacy)
::P042	-	# Disable app access to messages (Category: App Privacy)
::P052	-	# Disable app access to radios (Category: App Privacy)
::P053	-	# Disable app access to radios (Category: App Privacy)
::P054	-	# Disable app access to unpaired devices (Category: App Privacy)
::P055	-	# Disable app access to unpaired devices (Category: App Privacy)
::P029	-	# Disable app access to documents (Category: App Privacy)
::P043	-	# Disable app access to documents (Category: App Privacy)
::P030	-	# Disable app access to images (Category: App Privacy)
::P044	-	# Disable app access to images (Category: App Privacy)
::P031	-	# Disable app access to videos (Category: App Privacy)
::P045	-	# Disable app access to videos (Category: App Privacy)
::P032	-	# Disable app access to the file system (Category: App Privacy)
::P046	-	# Disable app access to the file system (Category: App Privacy)
::P058	-	# Disable app access to wireless equipment (Category: App Privacy)
::P059	-	# Disable app access to wireless technology (Category: App Privacy)
::P060	-	# Disable app access to eye tracking (Category: App Privacy)
::P061	-	# Disable app access to eye tracking (Category: App Privacy)
::P071	-	# Disable the ability for apps to take screenshots (Category: App Privacy)
::P072	-	# Disable the ability for apps to take screenshots (Category: App Privacy)
::P073	-	# Disable the ability for desktop apps to take screenshots (Category: App Privacy)
::P074	-	# Disable the ability for apps to take screenshots without borders (Category: App Privacy)
::P075	-	# Disable the ability for apps to take screenshots without borders (Category: App Privacy)
::P076	-	# Disable the ability for desktop apps to take screenshots without margins (Category: App Privacy)
::P077	-	# Disable app access to music libraries (Category: App Privacy)
::P078	-	# Disable app access to music libraries (Category: App Privacy)
::P079	-	# Disable app access to downloads folder (Category: App Privacy)
::P080	-	# Disable app access to downloads folder (Category: App Privacy)
::P024	-	# Prohibit apps from running in the background (Category: App Privacy)
::S001	-	# Disable password reveal button (Category: Security)
::S002	+	# Disable user steps recorder (Category: Security)
::S003	+	# Disable telemetry (Category: Security)
::S008	-	# Disable Internet access of Windows Media Digital Rights Management (DRM) (Category: Security)
::E101	+	# Disable tracking in the web (Category: Microsoft Edge (new version based on Chromium))
::E201	+	# Disable tracking in the web (Category: Microsoft Edge (new version based on Chromium))
::E115	+	# Disable check for saved payment methods by sites (Category: Microsoft Edge (new version based on Chromium))
::E215	-	# Disable check for saved payment methods by sites (Category: Microsoft Edge (new version based on Chromium))
::E118	+	# Disable personalizing advertising, search, news and other services (Category: Microsoft Edge (new version based on Chromium))
::E218	+	# Disable personalizing advertising, search, news and other services (Category: Microsoft Edge (new version based on Chromium))
::E107	-	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (new version based on Chromium))
::E207	-	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (new version based on Chromium))
::E111	+	# Disable user feedback in toolbar (Category: Microsoft Edge (new version based on Chromium))
::E211	+	# Disable user feedback in toolbar (Category: Microsoft Edge (new version based on Chromium))
::E112	+	# Disable storing and autocompleting of credit card data on websites (Category: Microsoft Edge (new version based on Chromium))
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
::E008	+	# Disable Cortana in Microsoft Edge (Category: Microsoft Edge (legacy version))
::E007	+	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (legacy version))
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
::C012	+	# Disable and reset Cortana (Category: Cortana (Personal Assistant))
::C002	+	# Disable Input Personalization (Category: Cortana (Personal Assistant))
::C013	+	# Disable online speech recognition (Category: Cortana (Personal Assistant))
::C007	+	# Cortana and search are disallowed to use location (Category: Cortana (Personal Assistant))
::C008	+	# Disable web search from Windows Desktop Search (Category: Cortana (Personal Assistant))
::C009	+	# Disable display web results in Search (Category: Cortana (Personal Assistant))
::C010	+	# Disable download and updates of speech recognition and speech synthesis models (Category: Cortana (Personal Assistant))
::C011	+	# Disable cloud search (Category: Cortana (Personal Assistant))
::C014	+	# Disable Cortana above lock screen (Category: Cortana (Personal Assistant))
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
::U005	+	# Disable the use of diagnostic data for a tailor-made user experience (Category: User Behavior)
::U006	+	# Disable diagnostic log collection (Category: User Behavior)
::U007	+	# Disable downloading of OneSettings configuration settings (Category: User Behavior)
::W001	+	# Disable Windows Update via peer-to-peer (Category: Windows Update)
::W011	+	# Disable updates to the speech recognition and speech synthesis modules. (Category: Windows Update)
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
::O001	+	# Disable Microsoft OneDrive (Category: Windows Explorer)
::S012	+	# Disable Microsoft SpyNet membership (Category: Microsoft Defender and Microsoft SpyNet)
::S013	+	# Disable submitting data samples to Microsoft (Category: Microsoft Defender and Microsoft SpyNet)
::S014	+	# Disable reporting of malware infection information (Category: Microsoft Defender and Microsoft SpyNet)
::K001	-	# Disable Windows Spotlight (Category: Lock Screen)
::K002	+	# Disable fun facts, tips, tricks, and more on your lock screen (Category: Lock Screen)
::K005	+	# Disable notifications on lock screen (Category: Lock Screen)
::D001	+	# Disable access to mobile devices (Category: Mobile Devices)
::D002	+	# Disable Phone Link app (Category: Mobile Devices)
::D003	+	# Disable showing suggestions for using mobile devices with Windows (Category: Mobile Devices)
::D104	+	# Disable connecting the PC to mobile devices (Category: Mobile Devices)
::M025	+	# Disable search with AI in search box (Category: Search)
::M003	+	# Disable extension of Windows search with Bing (Category: Search)
::M015	+	# Disable People icon in the taskbar (Category: Taskbar)
::M016	-	# Disable search box in task bar (Category: Taskbar)
::M017	+	# Disable "Meet now" in the task bar (Category: Taskbar)
::M018	+	# Disable "Meet now" in the task bar (Category: Taskbar)
::M019	+	# Disable news and interests in the task bar (Category: Taskbar)
::M021	+	# Disable widgets in Windows Explorer (Category: Taskbar)
::M022	+	# Disable feedback reminders (Category: Miscellaneous)
::M001	+	# Disable feedback reminders (Category: Miscellaneous)
::M004	+	# Disable automatic installation of recommended Windows Store Apps (Category: Miscellaneous)
::M005	+	# Disable tips, tricks, and suggestions while using Windows (Category: Miscellaneous)
::M024	+	# Disable Windows Media Player Diagnostics (Category: Miscellaneous)
::M026	+	# Disable remote assistance connections to this computer (Category: Miscellaneous)
::M027	+	# Disable remote connections to this computer (Category: Miscellaneous)
::M028	+	# Disable the desktop icon for information on "Windows Spotlight" (Category: Miscellaneous)
::M012	-	# Disable Key Management Service Online Activation (Category: Miscellaneous)
::M013	-	# Disable automatic download and update of map data (Category: Miscellaneous)
::M014	-	# Disable unsolicited network traffic on the offline maps settings page (Category: Miscellaneous)
::N001	-	# Disable Network Connectivity Status Indicator (Category: Miscellaneous)
::'
::
::#endregion configs > Windows > Tools > OOShutUp10
::
::
::#region configs > Windows > Tools > WinUtil Personalisation
::
::Set-Variable -Option Constant CONFIG_WINUTIL_PERSONALISATION '                      "WPFTweaksRemoveGallery",
::                      "WPFTweaksRemoveHome",
::                      "WPFTweaksRightClickMenu",
::                      "WPFTweaksRemoveOnedrive",
::'
::
::#endregion configs > Windows > Tools > WinUtil Personalisation
::
::
::#region configs > Windows > Tools > WinUtil
::
::Set-Variable -Option Constant CONFIG_WINUTIL '{
::    "WPFTweaks":  [
::                      "WPFTweaksAH",
::                      "WPFTweaksBraveDebloat",
::                      "WPFTweaksConsumerFeatures",
::                      "WPFTweaksDeleteTempFiles",
::                      "WPFTweaksDisableLMS1",
::                      "WPFTweaksDiskCleanup",
::                      "WPFTweaksDVR",
::                      "WPFTweaksEdgeDebloat",
::                      "WPFTweaksEndTaskOnTaskbar",
::                      "WPFTweaksHome",
::                      "WPFTweaksLoc",
::                      "WPFTweaksPowershell7Tele",
::                      "WPFTweaksRecallOff",
::                      "WPFTweaksRemoveCopilot",
::                      "WPFTweaksRestorePoint",
::                      "WPFTweaksTele",
::                      "WPFTweaksWifi"
::                  ],
::    "Install":  [
::
::                ],
::    "WPFInstall":  [
::
::                   ],
::    "WPFFeature":  [
::                       "WPFFeatureDisableSearchSuggestions",
::                       "WPFFeatureRegBackup"
::                   ]
::}
::'
::
::#endregion configs > Windows > Tools > WinUtil
::
::
::#region functions > Common > Exit
::
::function Reset-State {
::    Write-LogInfo 'Cleaning up files on exit...'
::
::    Set-Variable -Option Constant PowerShellScript "$PATH_TEMP_DIR\qiiwexc.ps1"
::
::    Remove-Directory $PATH_WINUTIL -Silent
::    Remove-Directory $PATH_OOSHUTUP10 -Silent
::    Remove-Directory $PATH_APP_DIR -Silent
::
::    Remove-File $PowerShellScript -Silent
::
::    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
::    Write-Host ''
::}
::
::function Exit-App {
::    Write-LogInfo 'Exiting the app...'
::    Reset-State
::    $FORM.Close()
::}
::
::#endregion functions > Common > Exit
::
::
::#region functions > Common > Expand-Zip
::
::function Expand-Zip {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
::        [Switch]$Temp
::    )
::
::    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
::    Set-Variable -Option Constant ExtractionPath $ZipPath.TrimEnd('.zip')
::    Set-Variable -Option Constant ExtractionDir (Split-Path -Leaf $ExtractionPath)
::    Set-Variable -Option Constant TargetPath $(if ($Temp) { $PATH_APP_DIR } else { $PATH_WORKING_DIR })
::
::    Initialize-AppDirectory
::
::    [String]$Executable = switch -Wildcard ($ZipName) {
::        'ActivationProgram.zip' { "ActivationProgram$(if ($OS_64_BIT) {''} else {'_x86'}).exe" }
::        'Office_Installer+.zip' { "Office Installer+$(if ($OS_64_BIT) {''} else {' x86'}).exe" }
::        'cpu-z_*' { "$ExtractionDir\cpuz_x$(if ($OS_64_BIT) {'64'} else {'32'}).exe" }
::        'SDIO_*' { "$ExtractionDir\SDIO_auto.bat" }
::        'ventoy*' { "$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe" }
::        'Victoria*' { "$ExtractionDir\$ExtractionDir\Victoria.exe" }
::        Default { $ZipName.TrimEnd('.zip') + '.exe' }
::    }
::
::    Set-Variable -Option Constant IsDirectory ($ExtractionDir -and $Executable -like "$ExtractionDir\*")
::    Set-Variable -Option Constant TemporaryExe "$ExtractionPath\$Executable"
::    Set-Variable -Option Constant TargetExe "$TargetPath\$Executable"
::
::    Remove-File $TemporaryExe
::
::    Remove-Directory $ExtractionPath
::
::    New-Item -Force -ItemType Directory $ExtractionPath | Out-Null
::
::    Write-LogInfo "Extracting '$ZipPath'..."
::
::    try {
::        if ($ZIP_SUPPORTED) {
::            [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractionPath)
::        } else {
::            foreach ($Item in $SHELL.NameSpace($ZipPath).Items()) {
::                $SHELL.NameSpace($ExtractionPath).CopyHere($Item)
::            }
::        }
::    } catch [Exception] {
::        Write-ExceptionLog $_ "Failed to extract '$ZipPath'"
::        return
::    }
::
::    Remove-File $ZipPath
::
::    if (-not $IsDirectory) {
::        Move-Item -Force $TemporaryExe $TargetExe
::        Remove-Directory $ExtractionPath
::    }
::
::    if (-not $Temp -and $IsDirectory) {
::        Remove-Directory "$TargetPath\$ExtractionDir"
::        Move-Item -Force $ExtractionPath $TargetPath
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
::#region functions > Common > Get-MicrosoftSecurityStatus
::
::function Get-MicrosoftSecurityStatus {
::    if ($PS_VERSION -ge 5) {
::        Set-Variable -Option Constant Status (Get-MpComputerStatus)
::
::        Set-Variable -Option Constant Properties (($Status | Get-Member -MemberType Property).Name)
::
::        Set-Variable -Option Constant Filtered ($Properties | Where-Object { $_ -eq 'BehaviorMonitorEnabled' -or $_ -eq 'IoavProtectionEnabled' -or $_ -eq 'NISEnabled' -or $_ -eq 'OnAccessProtectionEnabled' -or $_ -eq 'RealTimeProtectionEnabled' })
::
::        [Boolean]$IsEnabled = $False
::        foreach ($Property in $Filtered) {
::            if ($Status.$Property) {
::                $IsEnabled = $True
::            }
::            break
::        }
::
::        return $IsEnabled
::    }
::}
::
::#endregion functions > Common > Get-MicrosoftSecurityStatus
::
::
::#region functions > Common > Get-SystemInformation
::
::function Get-SystemInformation {
::    Write-LogInfo 'Current system information:'
::
::    Set-Variable -Option Constant Motherboard (Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property Manufacturer, Product)
::    Set-Variable -Option Constant BIOS (Get-CimInstance -ClassName CIM_BIOSElement | Select-Object -Property Manufacturer, Name, ReleaseDate)
::
::    Set-Variable -Option Constant WindowsRelease ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion)
::
::    Set-Variable -Option Constant -Scope Script OS_64_BIT $(if ($env:PROCESSOR_ARCHITECTURE -like '*64') { $True })
::
::    Set-Variable -Option Constant OfficeYear $(switch ($OFFICE_VERSION) { 16 { '2016 / 2019 / 2021 / 2024' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
::    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })
::
::    Write-LogInfo "    Motherboard: $($Motherboard.Manufacturer) $($Motherboard.Product)"
::    Write-LogInfo "    BIOS: $($BIOS.Manufacturer) $($BIOS.Name) (release date: $($BIOS.ReleaseDate))"
::    Write-LogInfo "    Operation system: $($OPERATING_SYSTEM.Caption)"
::    Write-LogInfo "    $(if ($OS_VERSION -ge 10) {'OS release / '})Build number: $(if ($OS_VERSION -ge 10) {"v$WindowsRelease / "})$($OPERATING_SYSTEM.Version)"
::    Write-LogInfo "    OS architecture: $($OPERATING_SYSTEM.OSArchitecture)"
::    Write-LogInfo "    OS language: $SYSTEM_LANGUAGE"
::    Write-LogInfo "    Office version: $OfficeName $(if ($OFFICE_INSTALL_TYPE) {`"($OFFICE_INSTALL_TYPE installation type)`"})"
::}
::
::#endregion functions > Common > Get-SystemInformation
::
::
::#region functions > Common > Initialize-App
::
::function Initialize-App {
::    $FORM.Activate()
::
::    Write-LogInfo 'Initializing...'
::
::    if ($OS_VERSION -lt 8) {
::        Write-LogWarning "Windows $OS_VERSION detected, some features are not supported."
::    }
::
::    try {
::        Add-Type -AssemblyName System.IO.Compression.FileSystem
::        Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
::    } catch [Exception] {
::        Set-Variable -Option Constant -Scope Script SHELL (New-Object -com Shell.Application)
::        Write-LogWarning "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
::    }
::
::    Get-SystemInformation
::
::    Initialize-AppDirectory
::
::    Update-App
::}
::
::#endregion functions > Common > Initialize-App
::
::
::#region functions > Common > Initialize-AppDirectory
::
::function Initialize-AppDirectory {
::    New-Item -Force -ItemType Directory $PATH_APP_DIR | Out-Null
::}
::
::#endregion functions > Common > Initialize-AppDirectory
::
::
::#region functions > Common > Invoke-CustomCommand
::
::function Invoke-CustomCommand {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Command,
::        [String]$WorkingDirectory,
::        [Switch]$BypassExecutionPolicy,
::        [Switch]$Elevated,
::        [Switch]$HideWindow,
::        [Switch]$Wait
::    )
::
::    Set-Variable -Option Constant ExecutionPolicy $(if ($BypassExecutionPolicy) { '-ExecutionPolicy Bypass' } else { '' })
::    Set-Variable -Option Constant WorkingDir $(if ($WorkingDirectory) { "-WorkingDirectory:$WorkingDirectory" } else { '' })
::    Set-Variable -Option Constant Verb $(if ($Elevated) { 'RunAs' } else { 'Open' })
::    Set-Variable -Option Constant WindowStyle $(if ($HideWindow) { 'Hidden' } else { 'Normal' })
::
::    Set-Variable -Option Constant FullCommand "$ExecutionPolicy $Command $WorkingDir"
::
::    Start-Process PowerShell $FullCommand -Wait:$Wait -Verb:$Verb -WindowStyle:$WindowStyle
::}
::
::#endregion functions > Common > Invoke-CustomCommand
::
::
::#region functions > Common > Logger
::
::function Write-LogDebug {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Message
::    )
::    Write-Log 'DEBUG' $Message
::}
::
::function Write-LogInfo {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Message
::    )
::    Write-Log 'INFO' $Message
::}
::
::function Write-LogWarning {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Message
::    )
::    Write-Log 'WARN' "$(Get-Emoji '26A0') $Message"
::}
::
::function Write-LogError {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Message
::    )
::    Write-Log 'ERROR' "$(Get-Emoji '274C') $Message"
::}
::
::function Write-Log {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR')]$Level,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Message
::    )
::
::    Set-Variable -Option Constant Text "[$((Get-Date).ToString())] $Message"
::
::    $LOG.SelectionStart = $LOG.TextLength
::
::    switch ($Level) {
::        'DEBUG' {
::            $LOG.SelectionColor = 'black'
::            Write-Host -NoNewline "$Text`n"
::        }
::        'INFO' {
::            $LOG.SelectionColor = 'black'
::            Write-Host -NoNewline "$Text`n"
::        }
::        'WARN' {
::            $LOG.SelectionColor = 'blue'
::            Write-Warning $Text
::        }
::        'ERROR' {
::            $LOG.SelectionColor = 'red'
::            Write-Error $Text
::        }
::        Default {
::            $LOG.SelectionColor = 'black'
::            Write-Host -NoNewline "$Text`n"
::        }
::    }
::
::    if ($Level -ne 'DEBUG') {
::        $LOG.AppendText("$Text`n")
::        $LOG.SelectionColor = 'black'
::        $LOG.ScrollToCaret()
::    }
::}
::
::
::function Out-Status {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Status
::    )
::
::    Write-LogInfo "   > $Status"
::}
::
::
::function Out-Success {
::    Out-Status "Done $(Get-Emoji '2705')"
::}
::
::function Out-Failure {
::    Out-Status "Failed $(Get-Emoji '274C')"
::}
::
::
::function Write-ExceptionLog {
::    param(
::        [Object][Parameter(Position = 0, Mandatory = $True)]$Exception,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Message
::    )
::
::    Write-Log 'ERROR' "$($Message): $($Exception.Exception.Message)"
::}
::
::function Get-Emoji {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Code
::    )
::
::    Set-Variable -Option Constant Emoji ([System.Convert]::toInt32($Code, 16))
::
::    return [System.Char]::ConvertFromUtf32($Emoji)
::}
::
::#endregion functions > Common > Logger
::
::
::#region functions > Common > Network
::
::function Get-NetworkAdapter {
::    return (Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
::}
::
::function Test-NetworkConnection {
::    if (-not (Get-NetworkAdapter)) {
::        return 'Computer is not connected to the Internet'
::    }
::}
::
::#endregion functions > Common > Network
::
::
::#region functions > Common > New-RegistryKeyIfMissing
::
::function New-RegistryKeyIfMissing {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$RegistryPath
::    )
::
::    if (-not (Test-Path $RegistryPath)) {
::        Write-LogDebug "Creating registry key '$RegistryPath'"
::        New-Item $RegistryPath
::    }
::}
::
::#endregion functions > Common > New-RegistryKeyIfMissing
::
::
::#region functions > Common > Open-InBrowser
::
::function Open-InBrowser {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$URL
::    )
::
::    Write-LogInfo "Opening URL in the default browser: $URL"
::
::    try {
::        [System.Diagnostics.Process]::Start($URL)
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Could not open the URL'
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
::        [String][Parameter(Position = 0, Mandatory = $True)]$DirectoryPath,
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
::        [String][Parameter(Position = 0, Mandatory = $True)]$FilePath,
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
::#region functions > Common > Set-CheckboxState
::
::function Set-CheckboxState {
::    param(
::        [System.Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory = $True)]$Control,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory = $True)]$Dependant
::    )
::
::    $Dependant.Enabled = $Control.Checked
::
::    if (-not $Dependant.Enabled) {
::        $Dependant.Checked = $False
::    }
::}
::
::#endregion functions > Common > Set-CheckboxState
::
::
::#region functions > Common > Start-Download
::
::function Start-Download {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
::        [String][Parameter(Position = 1)]$SaveAs,
::        [Switch]$Temp
::    )
::
::    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $URL })
::    Set-Variable -Option Constant TempPath "$PATH_APP_DIR\$FileName"
::    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$PATH_WORKING_DIR\$FileName" })
::
::    Initialize-AppDirectory
::
::    Write-LogInfo "Downloading from $URL"
::
::    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
::    if ($NoConnection) {
::        Write-LogError "Download failed: $NoConnection"
::
::        if (Test-Path $SavePath) {
::            Write-LogWarning 'Previous download found, returning it'
::            return $SavePath
::        } else {
::            return
::        }
::    }
::
::    try {
::        Start-BitsTransfer -Source $URL -Destination $TempPath -Dynamic
::
::        if (-not $Temp) {
::            Move-Item -Force $TempPath $SavePath
::        }
::
::        if (Test-Path $SavePath) {
::            Out-Success
::        } else {
::            throw 'Possibly computer is offline or disk is full'
::        }
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Download failed'
::        return
::    }
::
::    return $SavePath
::}
::
::#endregion functions > Common > Start-Download
::
::
::#region functions > Common > Start-DownloadUnzipAndRun
::
::function Start-DownloadUnzipAndRun {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
::        [String][Parameter(Position = 1)]$FileName,
::        [String][Parameter(Position = 2)]$Params,
::        [Switch]$AVWarning,
::        [Switch]$Execute,
::        [Switch]$Silent
::    )
::
::    if ($AVWarning -and (Get-MicrosoftSecurityStatus)) {
::        Write-LogWarning 'Microsoft Security is enabled'
::    }
::
::    if ($AVWarning -and -not $AV_WARNING_SHOWN) {
::        Write-LogWarning 'This file may trigger anti-virus false positive!'
::        Write-LogWarning 'It is recommended to disable anti-virus software for download and subsequent use of this file!'
::        Write-LogWarning 'Click the button again to continue'
::        Set-Variable -Option Constant -Scope Script AV_WARNING_SHOWN $True
::        return
::    }
::
::    Set-Variable -Option Constant UrlEnding $URL.Substring($URL.Length - 4)
::    Set-Variable -Option Constant IsZip ($UrlEnding -eq '.zip')
::    Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp:$($Execute -or $IsZip))
::
::    if ($DownloadedFile) {
::        Set-Variable -Option Constant Executable $(if ($IsZip) { Expand-Zip $DownloadedFile -Temp:$Execute } else { $DownloadedFile })
::
::        if ($Execute) {
::            Start-Executable $Executable $Params -Silent:$Silent
::        }
::    }
::}
::
::#endregion functions > Common > Start-DownloadUnzipAndRun
::
::
::#region functions > Common > Start-Executable
::
::function Start-Executable {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Executable,
::        [String][Parameter(Position = 1)]$Switches,
::        [Switch]$Silent
::    )
::
::    if ($Switches -and $Silent) {
::        Write-LogInfo "Running '$Executable' silently..."
::
::        try {
::            Start-Process -Wait $Executable $Switches
::        } catch [Exception] {
::            Write-ExceptionLog $_ "Failed to run '$Executable'"
::            return
::        }
::
::        Out-Success
::
::        Write-LogDebug "Removing '$Executable'..."
::        Remove-File $Executable
::        Out-Success
::    } else {
::        Write-LogInfo "Running '$Executable'..."
::
::        try {
::            if ($Switches) {
::                Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable)
::            } else {
::                Start-Process $Executable -WorkingDirectory (Split-Path $Executable)
::            }
::        } catch [Exception] {
::            Write-ExceptionLog $_ "Failed to execute '$Executable'"
::            return
::        }
::
::        Out-Success
::    }
::}
::
::#endregion functions > Common > Start-Executable
::
::
::#region functions > Common > Stop-ProcessIfRunning
::
::function Stop-ProcessIfRunning {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$ProcessName
::    )
::
::    if (Get-Process | Where-Object { $_.ProcessName -eq $ProcessName } ) {
::        Write-LogInfo "Stopping process '$AppName'..."
::        Stop-Process -Name $ProcessName
::        Out-Success
::    }
::}
::
::#endregion functions > Common > Stop-ProcessIfRunning
::
::
::#region functions > Common > Updater
::
::function Update-App {
::    Set-Variable -Option Constant AppBatFile "$PATH_WORKING_DIR\qiiwexc.bat"
::
::    Set-Variable -Option Constant IsUpdateAvailable (Get-UpdateAvailability)
::
::    if ($IsUpdateAvailable) {
::        Get-NewVersion $AppBatFile
::
::        Write-LogWarning 'Restarting...'
::
::        try {
::            Invoke-CustomCommand $AppBatFile
::        } catch [Exception] {
::            Write-ExceptionLog $_ 'Failed to start new version'
::            return
::        }
::
::        Exit-App
::    }
::}
::
::
::function Get-UpdateAvailability {
::    Write-LogInfo 'Checking for updates...'
::
::    if ($DevMode) {
::        Out-Status 'Skipping in dev mode'
::        return
::    }
::
::    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
::    if ($NoConnection) {
::        Write-LogError "Failed to check for updates: $NoConnection"
::        return
::    }
::
::    try {
::        Set-Variable -Option Constant VersionFile "$PATH_APP_DIR\version"
::        Start-BitsTransfer -Source 'https://bit.ly/qiiwexc_version' -Destination $VersionFile -Dynamic
::        Set-Variable -Option Constant LatestVersion ([Version](Get-Content $VersionFile -Raw))
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to check for updates'
::        return
::    }
::
::    if ($LatestVersion -gt $VERSION) {
::        Write-LogWarning "Newer version available: v$LatestVersion"
::        return $True
::    } else {
::        Out-Status 'No updates available'
::    }
::}
::
::
::function Get-NewVersion {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppBatFile
::    )
::
::    Write-LogWarning 'Downloading new version...'
::
::    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
::
::    if ($NoConnection) {
::        Write-LogError "Failed to download update: $NoConnection"
::        return
::    }
::
::    try {
::        Start-BitsTransfer -Source 'https://bit.ly/qiiwexc_bat' -Destination $AppBatFile -Dynamic
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to download update'
::        return
::    }
::
::    Out-Success
::}
::
::#endregion functions > Common > Updater
::
::
::#region functions > Configuration > Apps > Set-7zipConfiguration
::
::function Set-7zipConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
::    )
::
::    [String]$ConfigLines = $CONFIG_7ZIP.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
::    $ConfigLines += "`n"
::    $ConfigLines += $CONFIG_7ZIP
::
::    Import-RegistryConfiguration $AppName $ConfigLines
::}
::
::#endregion functions > Configuration > Apps > Set-7zipConfiguration
::
::
::#region functions > Configuration > Apps > Set-AppsConfiguration
::
::function Set-AppsConfiguration {
::    param(
::        [System.Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory = $True)]$7zip,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory = $True)]$VLC,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory = $True)]$TeamViewer,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory = $True)]$qBittorrent,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory = $True)]$Edge,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 5, Mandatory = $True)]$Chrome
::    )
::
::    if ($VLC.Checked) {
::        Set-VlcConfiguration $VLC.Text
::    }
::
::    if ($qBittorrent.Checked) {
::        Set-qBittorrentConfiguration $qBittorrent.Text
::    }
::
::    if ($7zip.Checked) {
::        Set-7zipConfiguration $7zip.Text
::    }
::
::    if ($TeamViewer.Checked) {
::        Set-TeamViewerConfiguration $TeamViewer.Text
::    }
::
::    if ($Edge.Checked) {
::        Set-MicrosoftEdgeConfiguration $Edge.Text
::    }
::
::    if ($Chrome.Checked) {
::        Set-GoogleChromeConfiguration $Chrome.Text
::    }
::}
::
::#endregion functions > Configuration > Apps > Set-AppsConfiguration
::
::
::#region functions > Configuration > Apps > Set-GoogleChromeConfiguration
::
::function Set-GoogleChromeConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
::    )
::
::    Set-Variable -Option Constant ProcessName 'chrome'
::
::    Update-JsonFile $AppName $ProcessName $CONFIG_CHROME_LOCAL_STATE "$env:LocalAppData\Google\Chrome\User Data\Local State"
::    Update-JsonFile $AppName $ProcessName $CONFIG_CHROME_PREFERENCES "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"
::}
::
::#endregion functions > Configuration > Apps > Set-GoogleChromeConfiguration
::
::
::#region functions > Configuration > Apps > Set-MicrosoftEdgeConfiguration
::
::function Set-MicrosoftEdgeConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
::    )
::
::    Set-Variable -Option Constant ProcessName 'msedge'
::
::    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_LOCAL_STATE "$env:LocalAppData\Microsoft\Edge\User Data\Local State"
::    Update-JsonFile $AppName $ProcessName $CONFIG_EDGE_PREFERENCES "$env:LocalAppData\Microsoft\Edge\User Data\Default\Preferences"
::}
::
::#endregion functions > Configuration > Apps > Set-MicrosoftEdgeConfiguration
::
::
::#region functions > Configuration > Apps > Set-qBittorrentConfiguration
::
::function Set-qBittorrentConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
::    )
::
::    Set-Variable -Option Constant Content ($CONFIG_QBITTORRENT_BASE + $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_QBITTORRENT_RUSSIAN } else { $CONFIG_QBITTORRENT_ENGLISH }))
::    Write-ConfigurationFile $AppName $Content "$env:AppData\$AppName\$AppName.ini"
::}
::
::#endregion functions > Configuration > Apps > Set-qBittorrentConfiguration
::
::
::#region functions > Configuration > Apps > Set-TeamViewerConfiguration
::
::function Set-TeamViewerConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
::    )
::
::    [String]$ConfigLines = $CONFIG_TEAMVIEWER.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
::    $ConfigLines += "`n"
::    $ConfigLines += $CONFIG_TEAMVIEWER
::
::    Import-RegistryConfiguration $AppName $ConfigLines
::}
::
::#endregion functions > Configuration > Apps > Set-TeamViewerConfiguration
::
::
::#region functions > Configuration > Apps > Set-VlcConfiguration
::
::function Set-VlcConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
::    )
::
::    Write-ConfigurationFile $AppName $CONFIG_VLC "$env:AppData\vlc\vlcrc"
::}
::
::#endregion functions > Configuration > Apps > Set-VlcConfiguration
::
::
::#region functions > Configuration > Helpers > Get-UsersRegistryKeys
::
::function Get-UsersRegistryKeys {
::    return ((Get-Item 'Registry::HKEY_USERS\*').Name | Where-Object { $_ -match '^S-1-5-21' -and $_ -notmatch '_Classes$' })
::}
::
::#endregion functions > Configuration > Helpers > Get-UsersRegistryKeys
::
::
::#region functions > Configuration > Helpers > Import-RegistryConfiguration
::
::function Import-RegistryConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Content
::    )
::
::    Write-LogInfo "Importing $AppName configuration into registry..."
::
::    Set-Variable -Option Constant RegFilePath "$PATH_APP_DIR\$AppName.reg"
::
::    Initialize-AppDirectory
::
::    "Windows Registry Editor Version 5.00`n`n" + $Content | Out-File $RegFilePath
::
::    try {
::        Start-Process -Verb RunAs -Wait 'regedit' "/s `"$RegFilePath`""
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to import file into registry'
::        return
::    }
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Helpers > Import-RegistryConfiguration
::
::
::#region functions > Configuration > Helpers > Merge-JsonObject
::
::function Merge-JsonObject {
::    param(
::        [Parameter(Position = 0, Mandatory = $True)]$Source,
::        [Parameter(Position = 1, Mandatory = $True)]$Extend
::    )
::
::    if ($Source -is [PSCustomObject] -and $Extend -is [PSCustomObject]) {
::        [PSCustomObject]$Merged = [Ordered] @{}
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
::        $Merged
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
::        , $Merged
::    } else {
::        $Extend
::    }
::}
::
::#endregion functions > Configuration > Helpers > Merge-JsonObject
::
::
::#region functions > Configuration > Helpers > Set-FileAssociation
::
::function Set-FileAssociation {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Application,
::        [String][Parameter(Position = 1, Mandatory = $True)]$RegistryPath,
::        [Switch][Parameter(Position = 2)]$SetDefault
::    )
::
::    New-RegistryKeyIfMissing $RegistryPath
::
::    if ($SetDefault) {
::        Set-Variable -Option Constant DefaultAssociation (Get-ItemProperty -Path $RegistryPath).'(Default)'
::        if ($DefaultAssociation -ne $Application) {
::            Set-ItemProperty -Path $RegistryPath -Name '(Default)' -Value $Application
::        }
::    }
::
::    Set-Variable -Option Constant OpenWithProgidsPath "$RegistryPath\OpenWithProgids"
::    New-RegistryKeyIfMissing $OpenWithProgidsPath
::
::    Set-Variable -Option Constant OpenWithProgids (Get-ItemProperty -Path $OpenWithProgidsPath)
::    if ($OpenWithProgids) {
::        Set-Variable -Option Constant OpenWithProgidsNames ($OpenWithProgids | Get-Member -MemberType NoteProperty).Name
::        Set-Variable -Option Constant Progids ($OpenWithProgidsNames | Where-Object { $_ -ne 'PSDrive' -and $_ -ne 'PSProvider' -and $_ -ne 'PSPath' -and $_ -ne 'PSParentPath' -and $_ -ne 'PSChildName' })
::
::        foreach ($Progid in $Progids) {
::            if ($Progid -ne $Application) {
::                Remove-ItemProperty -Path $OpenWithProgidsPath -Name $Progid
::            }
::        }
::
::        if (-not ($Progids -contains $Application)) {
::            New-ItemProperty -Path $OpenWithProgidsPath -Name $Application -Value ''
::        }
::    } else {
::        New-ItemProperty -Path $OpenWithProgidsPath -Name $Application -Value ''
::    }
::}
::
::#endregion functions > Configuration > Helpers > Set-FileAssociation
::
::
::#region functions > Configuration > Helpers > Update-JsonFile
::
::function Update-JsonFile {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
::        [String][Parameter(Position = 1, Mandatory = $True)]$ProcessName,
::        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
::        [String][Parameter(Position = 3, Mandatory = $True)]$Path
::    )
::
::    Stop-ProcessIfRunning $ProcessName
::
::    Write-LogInfo "Writing $AppName configuration to '$Path'..."
::
::    if (-not (Test-Path $Path)) {
::        Write-LogInfo "'$AppName' profile does not exist. Launching '$AppName' to create it"
::
::        try {
::            Start-Process $ProcessName -ErrorAction Stop
::        } catch [Exception] {
::            Write-ExceptionLog $_ "Couldn't start '$AppName'"
::            return
::        }
::
::        for ([Int]$i = 0; $i -lt 5; $i++) {
::            Start-Sleep -Seconds 10
::            if (Test-Path $Path) {
::                break
::            }
::        }
::    }
::
::    Set-Variable -Option Constant CurrentConfig (Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json)
::    Set-Variable -Option Constant PatchConfig ($Content | ConvertFrom-Json)
::
::    Set-Variable -Option Constant UpdatedConfig (Merge-JsonObject $CurrentConfig $PatchConfig | ConvertTo-Json -Depth 100 -Compress)
::
::    $UpdatedConfig | Out-File $Path -Encoding UTF8
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Helpers > Update-JsonFile
::
::
::#region functions > Configuration > Helpers > Write-ConfigurationFile
::
::function Write-ConfigurationFile {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Content,
::        [String][Parameter(Position = 2, Mandatory = $True)]$Path,
::        [String][Parameter(Position = 3)]$ProcessName = $AppName
::    )
::
::    Stop-ProcessIfRunning $ProcessName
::
::    Write-LogInfo "Writing $AppName configuration to '$Path'..."
::
::    New-Item -Force -ItemType Directory (Split-Path -Parent $Path) | Out-Null
::
::    $Content | Out-File $Path -Encoding UTF8
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Helpers > Write-ConfigurationFile
::
::
::#region functions > Configuration > Windows > Remove-WindowsFeatures
::
::function Remove-WindowsFeatures {
::    Write-LogInfo 'Starting miscellaneous Windows features cleanup...'
::
::    Set-Variable -Option Constant FeaturesToRemove @('App.StepsRecorder',
::        'App.Support.QuickAssist',
::        'MathRecognizer',
::        'Media.WindowsMediaPlayer',
::        'Microsoft.Windows.WordPad',
::        'OpenSSH.Client'
::    )
::
::    try {
::        Set-Variable -Option Constant InstalledCapabilities (Get-WindowsCapability -Online | Where-Object { $_.State -eq 'Installed' })
::        Set-Variable -Option Constant CapabilitiesToRemove ($InstalledCapabilities | Where-Object { $_.Name.Split('~')[0] -in $FeaturesToRemove })
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to collect the features to remove'
::    }
::
::    foreach ($Capability in $CapabilitiesToRemove) {
::        [String]$Name = $Capability.Name
::        try {
::            Write-LogInfo "Removing '$Name'..."
::            Remove-WindowsCapability -Online -Name "$Name"
::            Out-Success
::        } catch [Exception] {
::            Write-ExceptionLog $_ "Failed to remove '$Name'"
::        }
::    }
::
::    if ($CapabilitiesToRemove.Count -eq 0) {
::        Write-LogInfo 'Nothing to remove'
::    }
::
::    if (Test-Path 'mstsc.exe') {
::        Write-LogInfo "Removing 'mstsc'..."
::        Start-Process 'mstsc' '/uninstall'
::        Out-Success
::    }
::}
::
::#endregion functions > Configuration > Windows > Remove-WindowsFeatures
::
::
::#region functions > Configuration > Windows > Set-CloudFlareDNS
::
::function Set-CloudFlareDNS {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$MalwareProtection,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$FamilyFriendly
::    )
::
::    Set-Variable -Option Constant PreferredDnsServer $(if ($FamilyFriendly) { '1.1.1.3' } else { if ($MalwareProtection) { '1.1.1.2' } else { '1.1.1.1' } })
::    Set-Variable -Option Constant AlternateDnsServer $(if ($FamilyFriendly) { '1.0.0.3' } else { if ($MalwareProtection) { '1.0.0.2' } else { '1.0.0.1' } })
::
::    Write-LogInfo "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."
::    Write-LogWarning 'Internet connection may get interrupted briefly'
::
::    if (-not (Get-NetworkAdapter)) {
::        Write-LogError 'Could not determine network adapter used to connect to the Internet'
::        Write-LogError 'This could mean that computer is not connected'
::        return
::    }
::
::    try {
::        Set-Variable -Option Constant Status (Get-NetworkAdapter | Invoke-CimMethod -MethodName 'SetDNSServerSearchOrder' -Arguments @{ DNSServerSearchOrder = @($PreferredDnsServer, $AlternateDnsServer) }).ReturnValue
::
::        if ($Status -ne 0) {
::            Write-LogError 'Failed to change DNS server'
::        }
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to change DNS server'
::        return
::    }
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > Set-CloudFlareDNS
::
::
::#region functions > Configuration > Windows > Set-FileAssociations
::
::function Set-FileAssociations {
::    Write-LogInfo 'Setting file associations...'
::
::    Set-Variable -Option Constant SophiaScriptUrl "https://raw.githubusercontent.com/farag2/Sophia-Script-for-Windows/master/src/Sophia_Script_for_Windows_$OS_VERSION/Module/Sophia.psm1"
::    Set-Variable -Option Constant SophiaScriptPath "$PATH_TEMP_DIR\Sophia.ps1"
::
::    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
::    if (-not $NoConnection) {
::        Start-BitsTransfer -Source $SophiaScriptUrl -Destination $SophiaScriptPath -Dynamic
::
::        (Get-Content -Path $SophiaScriptPath -Force) | Set-Content -Path $SophiaScriptPath -Encoding UTF8 -Force
::
::        . $SophiaScriptPath
::    }
::
::    foreach ($FileAssociation in $CONFIG_FILE_ASSOCIATIONS) {
::        [String]$Extension = $FileAssociation.Extension
::        [String]$Application = $FileAssociation.Application
::
::        Set-FileAssociation $Application "Registry::HKEY_CLASSES_ROOT\$Extension"
::        Set-FileAssociation $Application "HKCU:\Software\Classes\$Extension" -SetDefault
::        Set-FileAssociation $Application "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension"
::
::        [String]$OriginalAssociation = $(& cmd.exe /c assoc $Extension 2`>`&1).Replace("$Extension=", '')
::        if ($OriginalAssociation -ne $Application) {
::            & cmd.exe /c assoc $Extension=$Application
::        }
::
::        if (-not $NoConnection -and $FileAssociation.Method -eq 'Sophia') {
::            Set-Association -ProgramPath $Application -Extension $Extension
::        }
::    }
::
::    Remove-File $SophiaScriptPath
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > Set-FileAssociations
::
::
::#region functions > Configuration > Windows > Set-PowerSchemeConfiguration
::
::function Set-PowerSchemeConfiguration {
::    Write-LogInfo 'Setting power scheme overlay...'
::
::    powercfg /OverlaySetActive OVERLAY_SCHEME_MAX
::
::    Out-Success
::
::    Write-LogInfo 'Applying Windows power scheme settings...'
::
::    foreach ($PowerSetting in $CONFIG_POWER_SETTINGS) {
::        powercfg /SetAcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
::        powercfg /SetDcValueIndex SCHEME_BALANCED $PowerSetting.SubGroup $PowerSetting.Setting $PowerSetting.Value
::    }
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > Set-PowerSchemeConfiguration
::
::
::#region functions > Configuration > Windows > Set-SearchConfiguration
::
::function Set-SearchConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
::    )
::
::    Write-LogInfo 'Applying Windows search index configuration...'
::
::    [String]$ConfigLines = "Windows Registry Editor Version 5.00`n"
::
::    try {
::        Set-Variable -Option Constant FileExtensionRegistries ((Get-Item 'Registry::HKEY_CLASSES_ROOT\*' -ErrorAction Ignore).Name | Where-Object { $_ -match '^HKEY_CLASSES_ROOT\\\.' })
::        foreach ($Registry in $FileExtensionRegistries) {
::            [Object]$PersistentHandlers = (Get-Item "Registry::$Registry\*").Name | Where-Object { $_ -match 'PersistentHandler' }
::
::            foreach ($PersistentHandler in $PersistentHandlers) {
::                [String]$DefaultHandler = (Get-ItemProperty "Registry::$PersistentHandler").'(default)'
::
::                if ($DefaultHandler -and -not ($DefaultHandler -eq '{098F2470-BAE0-11CD-B579-08002B30BFEB}')) {
::                    $ConfigLines += "`n[$Registry\PersistentHandler]`n"
::                    $ConfigLines += "@=`"{098F2470-BAE0-11CD-B579-08002B30BFEB}`"`n"
::                    $ConfigLines += "`"OriginalPersistentHandler`"=`"$DefaultHandler`"`n"
::                }
::
::            }
::        }
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to read the registry'
::    }
::
::    if ($ConfigLines) {
::        Import-RegistryConfiguration $FileName $ConfigLines
::    } else {
::        Out-Success
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-SearchConfiguration
::
::
::#region functions > Configuration > Windows > Set-WindowsBaseConfiguration
::
::function Set-WindowsBaseConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
::    )
::
::    Write-LogInfo 'Applying Windows configuration...'
::
::    if ($PS_VERSION -ge 5) {
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
::        Set-MpPreference -IntelTDTEnabled $True
::        Set-MpPreference -BruteForceProtectionLocalNetworkBlocking $True
::    }
::
::    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sCurrency' -Value ([Char]0x20AC)
::    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value 3
::
::    Set-Variable -Option Constant UnelevatedExplorerTaskName 'CreateExplorerShellUnelevatedTask'
::    if (Get-ScheduledTask | Where-Object { $_.TaskName -eq $UnelevatedExplorerTaskName } ) {
::        Unregister-ScheduledTask -TaskName $UnelevatedExplorerTaskName -Confirm:$False
::    }
::
::    Set-Variable -Option Constant LocalisedConfig $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_WINDOWS_RUSSIAN } else { $CONFIG_WINDOWS_ENGLISH })
::
::    [String]$ConfigLines = $CONFIG_WINDOWS_HKEY_CURRENT_USER.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
::    $ConfigLines += "`n"
::    $ConfigLines += $CONFIG_WINDOWS_HKEY_CLASSES_ROOT
::    $ConfigLines += "`n"
::    $ConfigLines += $CONFIG_WINDOWS_HKEY_CURRENT_USER
::    $ConfigLines += "`n"
::    $ConfigLines += $CONFIG_WINDOWS_HKEY_LOCAL_MACHINE
::    $ConfigLines += "`n"
::    $ConfigLines += $LocalisedConfig.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
::    $ConfigLines += "`n"
::    $ConfigLines += $LocalisedConfig
::
::    try {
::        foreach ($Registry in (Get-UsersRegistryKeys)) {
::            [String]$User = $Registry.Replace('HKEY_USERS\', '')
::            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n"
::            $ConfigLines += "`"RotatingLockScreenOverlayEnabled`"=dword:00000000`n"
::
::            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\InstallService\Stubification\$User]`n"
::            $ConfigLines += "`"EnableAppOffloading`"=dword:00000000`n"
::
::            $ConfigLines += "`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main]`n"
::            $ConfigLines += "`"DoNotTrack`"=dword:00000001`n"
::
::            $ConfigLines += "`n[HKEY_USERS\$($User)_Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI]`n"
::            $ConfigLines += "`"EnableCortana`"=dword:00000000`n"
::        }
::
::        Set-Variable -Option Constant VolumeRegistries ((Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\*').Name)
::        foreach ($Registry in $VolumeRegistries) {
::            $ConfigLines += "`n[$Registry]`n"
::            $ConfigLines += "`"MaxCapacity`"=dword:000FFFFF`n"
::        }
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to read the registry'
::    }
::
::    Import-RegistryConfiguration $FileName $ConfigLines
::}
::
::#endregion functions > Configuration > Windows > Set-WindowsBaseConfiguration
::
::
::#region functions > Configuration > Windows > Set-WindowsConfiguration
::
::function Set-WindowsConfiguration {
::    param(
::        [System.Windows.Forms.CheckBox][Parameter(Position = 0, Mandatory = $True)]$Base,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 1, Mandatory = $True)]$PowerScheme,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 2, Mandatory = $True)]$Search,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 3, Mandatory = $True)]$FileAssociations,
::        [System.Windows.Forms.CheckBox][Parameter(Position = 4, Mandatory = $True)]$Personalisation
::    )
::
::    if ($Base.Checked) {
::        Set-WindowsBaseConfiguration $Base.Text
::    }
::
::    if ($PowerScheme.Checked) {
::        Set-PowerSchemeConfiguration
::    }
::
::    if ($Search.Checked) {
::        Set-SearchConfiguration $Search.Text
::    }
::
::    if ($FileAssociations.Checked) {
::        Set-FileAssociations
::    }
::
::    if ($Personalisation.Checked) {
::        Set-WindowsPersonalisationConfig $Personalisation.Text
::    }
::}
::
::#endregion functions > Configuration > Windows > Set-WindowsConfiguration
::
::
::#region functions > Configuration > Windows > Set-WindowsPersonalisationConfig
::
::function Set-WindowsPersonalisationConfig {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
::    )
::
::    Write-LogInfo 'Applying Windows personalisation configuration...'
::
::    Set-WinHomeLocation -GeoId 140
::
::    Set-Variable -Option Constant LanguageList (Get-WinUserLanguageList)
::    if (-not ($LanguageList | Where-Object LanguageTag -Like 'lv')) {
::        $LanguageList.Add('lv-LV')
::        Set-WinUserLanguageList $LanguageList -Force
::    }
::
::    [String]$ConfigLines = $CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER.Replace('HKEY_CURRENT_USER', 'HKEY_USERS\.DEFAULT')
::    $ConfigLines += "`n"
::    $ConfigLines += $CONFIG_WINDOWS_PERSONALISATION_HKEY_CLASSES_ROOT
::    $ConfigLines += "`n"
::    $ConfigLines += $CONFIG_WINDOWS_PERSONALISATION_HKEY_CURRENT_USER
::    $ConfigLines += "`n"
::    $ConfigLines += $CONFIG_WINDOWS_PERSONALISATION_HKEY_LOCAL_MACHINE
::
::    try {
::        if ($OS_VERSION -gt 10) {
::            Set-Variable -Option Constant NotificationRegistries ((Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*').Name)
::            foreach ($Registry in $NotificationRegistries) {
::                $ConfigLines += "`n[$Registry]`n"
::                $ConfigLines += "`"IsPromoted`"=dword:00000001`n"
::            }
::        }
::
::        foreach ($User in (Get-UsersRegistryKeys)) {
::            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]`n"
::            $ConfigLines += "`"RotatingLockScreenEnabled`"=dword:00000001`n"
::        }
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to read the registry'
::    }
::
::    Import-RegistryConfiguration $FileName $ConfigLines
::}
::
::#endregion functions > Configuration > Windows > Set-WindowsPersonalisationConfig
::
::
::#region functions > Configuration > Windows > Tools > Start-OoShutUp10
::
::function Start-OoShutUp10 {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
::    )
::
::    Write-LogInfo 'Starting OOShutUp10++ utility...'
::
::    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
::    if ($NoConnection) {
::        Write-LogError "Failed to start: $NoConnection"
::        return
::    }
::
::    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_OOSHUTUP10 } else { $PATH_WORKING_DIR })
::    Set-Variable -Option Constant ConfigFile "$TargetPath\ooshutup10.cfg"
::
::    New-Item -Force -ItemType Directory $TargetPath | Out-Null
::
::    $CONFIG_OOSHUTUP10 | Out-File $ConfigFile -Encoding UTF8
::
::    if ($Silent) {
::        Start-DownloadUnzipAndRun -Execute:$Execute 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe' -Params $ConfigFile
::    } else {
::        Start-DownloadUnzipAndRun -Execute:$Execute 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
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
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$UsePreset,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$Personalisation,
::        [Switch][Parameter(Position = 2, Mandatory = $True)]$Silent
::    )
::
::    Write-LogInfo 'Starting Windows 10/11 debloat utility...'
::
::    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
::    if ($NoConnection) {
::        Write-LogError "Failed to start: $NoConnection"
::        return
::    }
::
::    Set-Variable -Option Constant TargetPath "$PATH_TEMP_DIR\Win11Debloat"
::
::    New-Item -Force -ItemType Directory $TargetPath | Out-Null
::
::    Set-Variable -Option Constant CustomAppsListFile "$TargetPath\CustomAppsList"
::    Set-Variable -Option Constant AppsList ($CONFIG_DEBLOAT_APP_LIST + $(if ($Personalisation) { 'Microsoft.OneDrive' } else { '' }))
::    $AppsList | Out-File $CustomAppsListFile -Encoding UTF8
::
::    Set-Variable -Option Constant SavedSettingsFile "$TargetPath\SavedSettings"
::    Set-Variable -Option Constant Configuration ($CONFIG_DEBLOAT_PRESET_BASE + $(if ($Personalisation) { $CONFIG_DEBLOAT_PRESET_PERSONALISATION } else { '' }))
::    $Configuration | Out-File $SavedSettingsFile -Encoding UTF8
::
::    Set-Variable -Option Constant UsePresetParam $(if ($UsePreset) { '-RunSavedSettings' } else { '' })
::    Set-Variable -Option Constant SilentParam $(if ($Silent) { '-Silent' } else { '' })
::    Set-Variable -Option Constant SysprepParam $(if ($OS_VERSION -gt 10) { '-Sysprep' } else { '' })
::    Set-Variable -Option Constant Params "$SysprepParam $UsePresetParam $SilentParam"
::
::    Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > Tools > Start-WindowsDebloat
::
::
::#region functions > Configuration > Windows > Tools > Start-WinUtil
::
::function Start-WinUtil {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Personalisation,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$AutomaticallyApply
::    )
::
::    Write-LogInfo 'Starting WinUtil utility...'
::
::    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
::    if ($NoConnection) {
::        Write-LogError "Failed to start: $NoConnection"
::        return
::    }
::
::    New-Item -Force -ItemType Directory $PATH_WINUTIL | Out-Null
::
::    Set-Variable -Option Constant ConfigFile "$PATH_WINUTIL\WinUtil.json"
::
::    [String]$Configuration = $CONFIG_WINUTIL
::    if ($Personalisation) {
::        $Configuration = $CONFIG_WINUTIL.Replace('    "WPFTweaks":  [
::', '    "WPFTweaks":  [
::' + $CONFIG_WINUTIL_PERSONALISATION)
::    }
::
::    $Configuration | Out-File $ConfigFile -Encoding UTF8
::
::    Set-Variable -Option Constant ConfigParam "-Config $ConfigFile"
::    Set-Variable -Option Constant RunParam $(if ($AutomaticallyApply) { '-Run' } else { '' })
::
::    Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) $ConfigParam $RunParam"
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > Tools > Start-WinUtil
::
::
::#region functions > Diagnostics and recovery > Get-BatteryReport
::
::function Get-BatteryReport {
::    Write-LogInfo 'Exporting battery report...'
::
::    Set-Variable -Option Constant ReportPath "$PATH_APP_DIR\battery_report.html"
::
::    Initialize-AppDirectory
::
::    powercfg /BatteryReport /Output $ReportPath
::
::    Open-InBrowser $ReportPath
::
::    Out-Success
::}
::
::#endregion functions > Diagnostics and recovery > Get-BatteryReport
::
::
::#region functions > Home > Start-Activator
::
::function Start-Activator {
::    Write-LogInfo 'Starting MAS activator...'
::
::    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
::    if ($NoConnection) {
::        Write-LogError "Failed to start: $NoConnection"
::        return
::    }
::
::    if ($OS_VERSION -eq 7) {
::        Invoke-CustomCommand -HideWindow "iex ((New-Object Net.WebClient).DownloadString('https://get.activated.win'))"
::    } else {
::        Invoke-CustomCommand -HideWindow "irm 'https://get.activated.win' | iex"
::    }
::
::    Out-Success
::}
::
::#endregion functions > Home > Start-Activator
::
::
::#region functions > Home > Start-Cleanup
::
::function Start-Cleanup {
::    Write-LogInfo 'Cleaning up the system...'
::
::    Write-LogInfo 'Clearing delivery optimization cache...'
::    Delete-DeliveryOptimizationCache -Force
::    Out-Success
::
::    Write-LogInfo 'Clearing software distribution folder...'
::    Set-Variable -Option Constant SoftwareDistributionPath "$env:SystemRoot\SoftwareDistribution\Download"
::    Get-ChildItem -Path $SoftwareDistributionPath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Ignore
::    Out-Success
::
::    Write-LogInfo 'Clearing Windows temp folder...'
::    Set-Variable -Option Constant WindowsTemp "$env:SystemRoot\Temp"
::    Get-ChildItem -Path $WindowsTemp -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Ignore
::    Out-Success
::
::    Write-LogInfo 'Clearing user temp folder...'
::    Get-ChildItem -Path $PATH_TEMP_DIR -Recurse -Force -ErrorAction Ignore | Remove-Item -Recurse -Force -ErrorAction Ignore
::    Out-Success
::
::    Write-LogInfo 'Running system cleanup...'
::
::    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
::        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
::    }
::
::    Set-Variable -Option Constant VolumeCaches @(
::        'Active Setup Temp Folders',
::        'BranchCache',
::        'D3D Shader Cache',
::        'Delivery Optimization Files',
::        'Device Driver Packages',
::        'Diagnostic Data Viewer database files',
::        'Downloaded Program Files',
::        'Internet Cache Files',
::        'Language Pack',
::        'Old ChkDsk Files',
::        'Previous Installations',
::        'Recycle Bin',
::        'RetailDemo Offline Content',
::        'Setup Log Files',
::        'System error memory dump files',
::        'System error minidump files',
::        'Temporary Files',
::        'Temporary Setup Files',
::        'Thumbnail Cache',
::        'Update Cleanup',
::        'User file versions',
::        'Windows Error Reporting Files',
::        'Windows ESD installation files',
::        'Windows Defender',
::        'Windows Upgrade Log Files'
::    )
::
::    foreach ($VolumeCache in $VolumeCaches) {
::        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$VolumeCache" -Name StateFlags3224 -PropertyType DWord -Value 2 -Force
::    }
::
::    Start-Process 'cleanmgr.exe' -ArgumentList '/sagerun:3224' -Wait
::
::    Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches | ForEach-Object -Process {
::        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
::    }
::
::    Out-Success
::}
::
::#endregion functions > Home > Start-Cleanup
::
::
::#region functions > Home > Update-MicrosoftOffice
::
::function Update-MicrosoftOffice {
::    Write-LogInfo 'Starting Microsoft Office update...'
::
::    try {
::        Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user'
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to update Microsoft Office'
::        return
::    }
::
::    Out-Success
::}
::
::#endregion functions > Home > Update-MicrosoftOffice
::
::
::#region functions > Home > Update-MicrosoftStoreApps
::
::function Update-MicrosoftStoreApps {
::    Write-LogInfo 'Starting Microsoft Store apps update...'
::
::    try {
::        Invoke-CustomCommand -Elevated -HideWindow "Get-CimInstance MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap' | Invoke-CimMethod -MethodName 'UpdateScanMethod'"
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to update Microsoft Store apps'
::        return
::    }
::
::    Out-Success
::}
::
::#endregion functions > Home > Update-MicrosoftStoreApps
::
::
::#region functions > Home > Update-Windows
::
::function Update-Windows {
::    Write-LogInfo 'Starting Windows Update...'
::
::    try {
::        if ($OS_VERSION -gt 7) {
::            Start-Process 'UsoClient' 'StartInteractiveScan'
::        } else {
::            Start-Process 'wuauclt' '/detectnow /updatenow'
::        }
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to update Windows'
::        return
::    }
::
::    Out-Success
::}
::
::#endregion functions > Home > Update-Windows
::
::
::#region functions > Installs > Install-MicrosoftOffice
::
::function Install-MicrosoftOffice {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute
::    )
::
::    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_APP_DIR } else { $PATH_WORKING_DIR })
::    Set-Variable -Option Constant Config $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_OFFICE_INSTALLER.Replace('en-GB', 'ru-RU') } else { $CONFIG_OFFICE_INSTALLER })
::
::    Initialize-AppDirectory
::
::    $Config | Out-File "$TargetPath\Office Installer+.ini" -Encoding UTF8
::
::    if ($Execute -and $AV_WARNING_SHOWN) {
::        Import-RegistryConfiguration 'Microsoft Office' $CONFIG_MICROSOFT_OFFICE
::    }
::
::    Start-DownloadUnzipAndRun -AVWarning -Execute:$Execute 'https://qiiwexc.github.io/d/Office_Installer+.zip'
::}
::
::#endregion functions > Installs > Install-MicrosoftOffice
::
::
::#region functions > Installs > Install-Unchecky
::
::function Install-Unchecky {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
::    )
::
::    Set-Variable -Option Constant Registry_Key 'HKCU:\Software\Unchecky'
::    New-RegistryKeyIfMissing $Registry_Key
::
::    Set-ItemProperty -Path $Registry_Key -Name 'HideTrayIcon' -Value 1
::
::    Set-Variable -Option Constant Params $(if ($Silent) { '-install -no_desktop_icon' })
::    Start-DownloadUnzipAndRun -Execute:$Execute 'https://fi.softradar.com/static/products/unchecky/distr/1.2/unchecky_softradar-com.exe' -Params:$Params -Silent:$Silent
::}
::
::#endregion functions > Installs > Install-Unchecky
::
::
::#region functions > Installs > Ninite
::
::function Set-NiniteButtonState {
::    $CHECKBOX_StartNinite.Enabled = $NINITE_CHECKBOXES.Where({ $_.Checked })
::}
::
::
::function Get-NiniteInstaller {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$OpenInBrowser,
::        [Switch][Parameter(Position = 1)]$Execute
::    )
::
::    [String[]]$AppIds = @()
::
::    foreach ($Checkbox in $NINITE_CHECKBOXES) {
::        if ($Checkbox.Checked) {
::            $AppIds += $Checkbox.Name
::        }
::    }
::
::    Set-Variable -Option Constant Query ($AppIds -join '-')
::
::    if ($OpenInBrowser) {
::        Open-InBrowser "https://ninite.com/?select=$Query"
::    } else {
::        [String[]]$AppNames = @()
::
::        foreach ($Checkbox in $NINITE_CHECKBOXES) {
::            if ($Checkbox.Checked) {
::                $AppNames += $Checkbox.Text
::            }
::        }
::
::        Set-Variable -Option Constant FileName "Ninite $($AppNames -Join ' ') Installer.exe"
::        Set-Variable -Option Constant DownloadUrl "https://ninite.com/$Query/ninite.exe"
::
::        Start-DownloadUnzipAndRun -Execute:$Execute $DownloadUrl $FileName
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
