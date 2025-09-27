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
  powershell -ExecutionPolicy Bypass "%psfile%" -CallerPath "%cd%"
) else (
  powershell -ExecutionPolicy Bypass "%psfile%" -CallerPath "%cd%" -HideConsole
)

::#region init > Parameters
::
::param(
::    [String][Parameter(Position = 0)]$CallerPath,
::    [Switch]$HideConsole
::)
::
::#endregion init > Parameters
::
::
::#region init > Version
::
::Set-Variable -Option Constant VERSION ([Version]'25.9.28')
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
::#Requires -PSEdition Desktop
::#Requires -Version 3
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
::if ($HideConsole) {
::    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
::                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
::    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
::}
::
::[System.Windows.Forms.Application]::EnableVisualStyles()
::
::
::Set-Variable -Option Constant PATH_CURRENT_DIR $CallerPath
::Set-Variable -Option Constant PATH_TEMP_DIR ([System.IO.Path]::GetTempPath())
::Set-Variable -Option Constant PATH_APP_DIR "$($PATH_TEMP_DIR)qiiwexc"
::Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
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
::Set-Variable -Option Constant OS_VERSION $(if ($IsWindows11) { 11 } else { switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } } })
::
::Set-Variable -Option Constant WordRegPath (Get-ItemProperty 'Registry::HKEY_CLASSES_ROOT\Word.Application\CurVer' -ErrorAction SilentlyContinue)
::Set-Variable -Option Constant OFFICE_VERSION $(if ($WordRegPath) { ($WordRegPath.'(default)') -replace '\D+', '' })
::Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if ($OFFICE_VERSION) { if (Test-Path $PATH_OFFICE_C2R_CLIENT_EXE) { 'C2R' } else { 'MSI' } })
::
::New-Item -Force -ItemType Directory $PATH_APP_DIR | Out-Null
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
::    $CheckBox.Size = "150, $CHECKBOX_HEIGHT"
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
::$FORM.Add_Shown( { Initialize-Script } )
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
::[Boolean]$BUTTON_DISABLED = $OS_VERSION -lt 7
::[ScriptBlock]$BUTTON_FUNCTION = { Update-Windows }
::New-Button 'Windows update' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
::
::
::[Boolean]$BUTTON_DISABLED = $OS_VERSION -lt 8
::[ScriptBlock]$BUTTON_FUNCTION = { Update-MicrosoftStoreApps }
::New-Button 'Microsoft Store updates' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED
::
::
::[Boolean]$BUTTON_DISABLED = $OFFICE_INSTALL_TYPE -ne 'C2R'
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
::[Boolean]$BUTTON_DISABLED = $OS_VERSION -lt 7
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
::[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartRufus.Checked 'https://github.com/pbatard/rufus/releases/download/v4.10/rufus-4.10p.exe' -Params:'-g' }
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
::[Boolean]$PAD_CHECKBOXES = $False
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
::[ScriptBlock]$BUTTON_FUNCTION = { Install-Unchecky -Execute:$CHECKBOX_StartOfficeInstaller.Checked -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked }
::New-Button 'Unchecky' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Checked
::$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
::        $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked
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
::[Boolean]$PAD_CHECKBOXES = $False
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
::[ScriptBlock]$BUTTON_FUNCTION = { Set-AppsConfiguration }
::New-Button 'Apply configuration' $BUTTON_FUNCTION
::
::#endregion ui > Configuration > Apps configuration
::
::
::#region ui > Configuration > Windows configuration
::
::New-GroupBox 'Windows configuration'
::
::[Boolean]$PAD_CHECKBOXES = $False
::
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsBase = New-CheckBox 'Base config and privacy' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_PowerScheme = New-CheckBox 'Set power scheme' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsSearch = New-CheckBox 'Configure search index' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_FileAssociations = New-CheckBox 'Set file associations' -Checked
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Set-WindowsConfiguration }
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
::[ScriptBlock]$BUTTON_FUNCTION = { Start-WindowsDebloat -UsePreset:$CHECKBOX_UseDebloatPreset.Checked -Silent:$CHECKBOX_SilentlyRunDebloat.Checked }
::New-Button 'Windows 10/11 debloat' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_UseDebloatPreset = New-CheckBox 'Use custom preset' -Checked
::$CHECKBOX_UseDebloatPreset.Add_CheckStateChanged( {
::        $CHECKBOX_SilentlyRunDebloat.Enabled = $CHECKBOX_UseDebloatPreset.Checked
::    } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunDebloat = New-CheckBox 'Silently apply tweaks'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-WinUtil -Apply:$CHECKBOX_SilentlyRunWinUtil.Checked }
::New-Button 'WinUtil' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunWinUtil = New-CheckBox 'Auto apply tweaks'
::
::
::[ScriptBlock]$BUTTON_FUNCTION = { Start-ShutUp10 -Execute:$CHECKBOX_StartShutUp10.Checked -Silent:($CHECKBOX_StartShutUp10.Checked -and $CHECKBOX_SilentlyRunShutUp10.Checked) }
::New-Button 'ShutUp10++ privacy' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_StartShutUp10 = New-CheckBoxRunAfterDownload -Checked
::$CHECKBOX_StartShutUp10.Add_CheckStateChanged( {
::        $CHECKBOX_SilentlyRunShutUp10.Enabled = $CHECKBOX_StartShutUp10.Checked
::    } )
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunShutUp10 = New-CheckBox 'Silently apply tweaks'
::
::#endregion ui > Configuration > Configure and debloat Windows
::
::
::#region ui > Configuration > Remove Windows components
::
::New-GroupBox 'Remove Windows components'
::
::
::[Boolean]$BUTTON_DISABLED = $PS_VERSION -lt 5
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
::[ScriptBlock]$BUTTON_FUNCTION = { Set-CloudFlareDNS }
::New-Button 'Setup CloudFlare DNS' $BUTTON_FUNCTION
::
::[System.Windows.Forms.CheckBox]$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
::$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( {
::        $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked
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
::Set-Variable -Option Constant CONFIG_7ZIP 'Windows Registry Editor Version 5.00
::
::[HKEY_CURRENT_USER\Software\7-Zip]
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
::  "smartscreen": {
::    "enabled": true,
::    "pua_protection_enabled": true
::  },
::  "startup_boost": {
::    "enabled": false
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
::    "show_hubapps_personalization": false,
::    "show_prompt_before_closing_tabs": true,
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
::    "hide_default_top_sites": true,
::    "layout_mode": 3,
::    "news_feed_display": "off",
::    "next_site_suggestions_available": false,
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
::    ]
::  },
::  "spellcheck": {
::    "dictionaries": ["lv", "ru", "en-GB"]
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
::Set-Variable -Option Constant CONFIG_TEAMVIEWER 'Windows Registry Editor Version 5.00
::
::[HKEY_CURRENT_USER\Software\TeamViewer]
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
::    @{Extension = '.bmp'; Application = 'PhotoViewer.FileAssoc.Bitmap' },
::    @{Extension = '.cab'; Application = 'CABFolder' },
::    @{Extension = '.cr2'; Application = 'PhotoViewer.FileAssoc.Tiff' },
::    @{Extension = '.dib'; Application = 'PhotoViewer.FileAssoc.Bitmap' },
::    @{Extension = '.gif'; Application = 'Applications\msedge.exe' },
::    @{Extension = '.htm'; Application = 'ChromeHTML' },
::    @{Extension = '.html'; Application = 'ChromeHTML' },
::    @{Extension = '.iso'; Application = 'Windows.IsoFile' },
::    @{Extension = '.jfif'; Application = 'PhotoViewer.FileAssoc.JFIF' },
::    @{Extension = '.jpe'; Application = 'PhotoViewer.FileAssoc.Jpeg' },
::    @{Extension = '.jpeg'; Application = 'PhotoViewer.FileAssoc.Jpeg' },
::    @{Extension = '.jpg'; Application = 'PhotoViewer.FileAssoc.Jpeg' },
::    @{Extension = '.jxr'; Application = 'PhotoViewer.FileAssoc.Wdp' },
::    @{Extension = '.mht'; Application = 'MSEdgeMHT' },
::    @{Extension = '.mhtml'; Application = 'ChromeHTML' },
::    @{Extension = '.oqy'; Application = 'Applications\EXCEL.EXE' },
::    @{Extension = '.pdf'; Application = 'ChromePDF' },
::    @{Extension = '.png'; Application = 'PhotoViewer.FileAssoc.Png' },
::    @{Extension = '.rar'; Application = '7-Zip.rar' },
::    @{Extension = '.rqy'; Application = 'Applications\EXCEL.EXE' },
::    @{Extension = '.shtml'; Application = 'ChromeHTML' },
::    @{Extension = '.svg'; Application = 'ChromeHTML' },
::    @{Extension = '.tif'; Application = 'TIFImage.Document' },
::    @{Extension = '.tiff'; Application = 'TIFImage.Document' },
::    @{Extension = '.torrent'; Application = 'qBittorrent.File.Torrent' },
::    @{Extension = '.url'; Application = 'InternetShortcut' },
::    @{Extension = '.vlt'; Application = 'VLC.vlt' },
::    @{Extension = '.webp'; Application = 'ChromeHTML' },
::    @{Extension = '.wsz'; Application = 'VLC.wsz' },
::    @{Extension = '.xht'; Application = 'ChromeHTML' },
::    @{Extension = '.xhtml'; Application = 'ChromeHTML' },
::    @{Extension = '.xml'; Application = 'MSEdgeHTM' },
::    @{Extension = '.zip'; Application = 'CompressedFolder' },
::    @{Extension = 'ftp'; Application = 'MSEdgeHTM' },
::    @{Extension = 'http'; Application = 'ChromeHTML' },
::    @{Extension = 'https'; Application = 'ChromeHTML' },
::    @{Extension = 'mailto'; Application = 'ChromeHTML' },
::    @{Extension = 'microsoft-edge'; Application = 'MSEdgeHTM' },
::    @{Extension = 'microsoft-edge-holographic'; Application = 'MSEdgeHTM' },
::    @{Extension = 'ms-xbl-3d8b930f'; Application = 'MSEdgeHTM' },
::    @{Extension = 'read'; Application = 'MSEdgeHTM' },
::    @{Extension = 'tel'; Application = 'ChromeHTML' },
::    @{Extension = 'webcal'; Application = 'ChromeHTML' }
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
::    @{SubGroup = 'SUB_SLEEP'; Setting = 'HYBRIDSLEEP'; Value = 1 },
::    @{SubGroup = 'SUB_SLEEP'; Setting = 'RTCWAKE'; Value = 1 }
::)
::
::#endregion configs > Windows > Power settings
::
::
::#region configs > Windows > Windows base
::
::Set-Variable -Option Constant CONFIG_WINDOWS_BASE 'Windows Registry Editor Version 5.00
::
::[-HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing]
::
::[-HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\Directory\shellex\CopyHookHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\Directory\shellex\PropertySheetHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\Drive\shellex\ContextMenuHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\Drive\shellex\PropertySheetHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\Folder\ShellEx\ContextMenuHandlers\Library Location]
::
::[-HKEY_CLASSES_ROOT\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\UserLibraryFolder\shellex\ContextMenuHandlers\Sharing]
::
::[-HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}]
::"System.IsPinnedToNameSpaceTree"=dword:0
::
::[-HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}]
::"System.IsPinnedToNameSpaceTree"=dword:0
::
::[HKEY_CLASSES_ROOT\jpegfile\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\pngfile\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open]
::"MuiVerb"="@photoviewer.dll,-3043"
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command]
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
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print]
::"NeverDefault"=""
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command]
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
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget]
::"Clsid"="{60fd46de-f830-4894-a628-6fa81bc0190d}"
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
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF]
::"EditFlags"=dword:00010000
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,35,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-72"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open]
::"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\
::  69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\
::  00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\
::  72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\
::  00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\command]
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
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg]
::"EditFlags"=dword:00010000
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,35,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-72"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open]
::"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\
::  69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\
::  00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\
::  72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\
::  00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\command]
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
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif]
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,37,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-83"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\command]
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
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png]
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,37,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-71"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\command]
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
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp]
::"EditFlags"=dword:00010000
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\DefaultIcon]
::@="%SystemRoot%\\System32\\wmphoto.dll,-400"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open]
::"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\
::  69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\
::  00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\
::  72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\
::  00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\command]
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
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget]
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
::
::[HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\DropTarget]
::"{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"=""
::
::[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
::"Flags"="506"
::
::[HKEY_CURRENT_USER\Control Panel\Desktop]
::"JPEGImportQuality"=dword:00000064
::
::[HKEY_CURRENT_USER\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
::"ShowCmd"=dword:00000003
::"WFlags"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
::@=""
::
::[HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}]
::@="CLSID_MSGraphHomeFolder"
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64]
::@=""
::
::[HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
::"ShowCmd"=dword:00000003
::"WFlags"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Microsoft\Edge\SmartScreenPuaEnabled]
::@=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Feeds]
::"DefaultInterval"=dword:0000000F
::"SyncStatus"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Input\TIPC]
::"Enabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization]
::"RestrictImplicitInkCollection"=dword:00000001
::"RestrictImplicitTextCollection"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore]
::"HarvestContacts"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main]
::"DoNotTrack"=dword:00000001
::"Use FormSuggest"="yes"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Privacy]
::"CleanDownloadHistory"=dword:00000001
::"CleanForms"=dword:00000001
::"CleanPassword"=dword:00000001
::"ClearBrowsingHistoryOnExit"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Preferences]
::"AcceptedPrivacyStatement"=dword:00000001
::"FirstRun"=dword:00000000
::"MetadataRetrieval"=dword:00000003
::"SilentAcquisition"=dword:00000001
::"UsageTracking"=dword:00000000
::"Volume"=dword:00000064
::
::[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\LinkedIn]
::"OfficeLinkedIn"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings]
::"AcceptedPrivacyPolicy"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules]
::"NumberOfSIUFInPeriod"=dword:00000000
::"PeriodInNanoSeconds"=-
::
::[HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy]
::"HasAccepted"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
::"Enabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack]
::"ShowedToastAtLevel"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
::"MaximizeApps"=dword:00000001
::"ShowRecommendations"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"Hidden"=dword:00000001
::"LaunchTo"=dword:00000001
::"NavPaneShowAllCloudStates"=dword:00000001
::"SeparateProcess"=dword:00000001
::"ShowCopilotButton"=dword:00000000
::"ShowTaskViewButton"=dword:00000000
::"Start_IrisRecommendations"=dword:00000000
::"Start_Layout"=dword:00000001
::"Start_TrackProgs"=dword:00000000
::"TaskbarMn"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings]
::"TaskbarEndTask"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\CIDSizeMRU]
::"0"=hex:4E,00,4F,00,54,00,45,00,50,00,41,00,44,00,2E,00,45,00,58,00,45,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,F8,FF,FF, \
::  FF,F8,FF,FF,FF,88,07,00,00,93,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,2B,00,00,00,C0,03,00,00,0B,02,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,FF,FF,FF,FF
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
::"PreviewPaneSizer"=hex:8D,00,00,00,01,00,00,00,00,00,00,00,3D,03,00,00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\PerExplorerSettings\3\Sizer]
::"PreviewPaneSizer"=hex:8D,00,00,00,01,00,00,00,00,00,00,00,3D,03,00,00
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
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content]
::"CacheLimit"=dword:00002000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache]
::"ContentLimit"=dword:00000008
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache]
::"Persistent"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Url History]
::"DaysToKeep"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"HideSCAMeetNow"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Privacy]
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start]
::"VisiblePlaces"=hex:2F,B3,67,E3,DE,89,55,43,BF,CE,61,F3,7B,18,A9,37,86,08,73, \
::  52,AA,51,43,42,9F,7B,27,76,58,46,59,D4
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start\Companions\Microsoft.YourPhone_8wekyb3d8bbwe]
::"IsEnabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy]
::"256"=dword:0000003C
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
::"VideoQualityOnBattery"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows Security Health\State]
::"AccountProtection_MicrosoftAccount_Disconnected"=dword:00000001
::"Hardware_DataEncryption_AddMsa"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
::"DisableSearchBoxSuggestions"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
::"DisableAIDataAnalysis"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
::"TurnOffWindowsCopilot"=dword:00000001
::
::[HKEY_CURRENT_USER\System\GameConfigStore]
::"GameDVR_Enabled"=dword:00000000
::
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location]
::
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
::
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}]
::
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
::
::[-HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}]
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
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\TaskSettings]
::"fAllVolumes"=dword:00000001
::"fDeadlineEnabled"=dword:00000001
::"fExclude"=dword:00000000
::"fTaskEnabled"=dword:00000001
::"TaskFrequency"=dword:00000002
::"Volumes"=" "
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests]
::"value"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup]
::"CostedNetworkPolicy"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery]
::"CheckedValue"=dword:00000001
::"DefaultValue"=dword:00000000
::"HKeyRoot"=dword:80000001
::"Id"=dword:0000000d
::"RegPath"="Software\\Classes\\CLSID\\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
::"Text"="Show Gallery"
::"Type"="checkbox"
::"UncheckedValue"=dword:00000000
::"ValueName"="System.IsPinnedToNameSpaceTree"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome]
::"CheckedValue"=dword:00000001
::"DefaultValue"=dword:00000000
::"HKeyRoot"=dword:80000001
::"Id"=dword:0000000d
::"RegPath"="Software\\Classes\\CLSID\\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
::"Text"="Show Home"
::"Type"="checkbox"
::"UncheckedValue"=dword:00000000
::"ValueName"="System.IsPinnedToNameSpaceTree"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag]
::"ThisPCPolicy"="Hide"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
::"SecurityHealth"=hex:05,00,00,00,88,26,66,6D,84,2A,DC,01
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Device Driver Packages]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Language Pack]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations]
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
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files]
::"StateFlags"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
::"AllowTelemetry"=dword:00000000
::"MaxTelemetryAllowed"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
::"PromptOnSecureDesktop"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971F918-A847-4430-9279-4A52D1EFE18D]
::"RegisteredWithAU"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services]
::"DefaultService"="7971f918-a847-4430-9279-4a52d1efe18d"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection]
::"EnableNetworkProtection"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection]
::"SummaryNotificationDisabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\NoExecuteState]
::"LastNoExecuteRadioButtonState"=dword:000036BD
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities]
::"ApplicationDescription"="@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3069"
::"ApplicationName"="@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3009"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations]
::".bmp"="PhotoViewer.FileAssoc.Bitmap"
::".cr2"="PhotoViewer.FileAssoc.Tiff"
::".dib"="PhotoViewer.FileAssoc.Bitmap"
::".gif"="PhotoViewer.FileAssoc.Gif"
::".jfif"="PhotoViewer.FileAssoc.JFIF"
::".jpe"="PhotoViewer.FileAssoc.Jpeg"
::".jpeg"="PhotoViewer.FileAssoc.Jpeg"
::".jpg"="PhotoViewer.FileAssoc.Jpeg"
::".jxr"="PhotoViewer.FileAssoc.Wdp"
::".png"="PhotoViewer.FileAssoc.Png"
::".tif"="PhotoViewer.FileAssoc.Tiff"
::".tiff"="PhotoViewer.FileAssoc.Tiff"
::".wdp"="PhotoViewer.FileAssoc.Wdp"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search]
::"EnableFindMyFiles"=dword:00000001
::"SystemIndexNormalization"=dword:00000003
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Search\Preferences]
::"AllowIndexingEncryptedStoresOrItems"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings]
::"AllowMUUpdateService"=dword:00000001
::"IsContinuousInnovationOptedIn"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh]
::"AllowNewsAndInterests"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
::"AlternateErrorPagesEnabled"=dword:00000000
::"ComposeInlineEnabled"=dword:00000000
::"CopilotCDPPageContext"=dword:00000000
::"CopilotPageContext"=dword:00000000
::"DiagnosticData"=dword:00000000
::"EdgeEntraCopilotPageContext"=dword:00000000
::"EdgeHistoryAISearchEnabled"=dword:00000000
::"EdgeShoppingAssistantEnabled"=dword:00000000
::"GenAILocalFoundationalModelSettings"=dword:00000001
::"HubsSidebarEnabled"=dword:00000000
::"NewTabPageBingChatEnabled"=dword:00000000
::"NewTabPageContentEnabled"=dword:00000000
::"NewTabPageHideDefaultTopSites"=dword:00000001
::"PersonalizationReportingEnabled"=dword:00000000
::"TabServicesEnabled"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent]
::"DisableConsumerAccountStateContent"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR]
::"AllowGameDVR"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
::"PublishUserActivities"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds]
::"EnableFeeds"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
::"AllowCortana"=dword:00000000
::"CortanaConsent"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsAI]
::"AllowRecallEnablement"=dword:00000000
::"DisableAIDataAnalysis"=dword:00000001
::"TurnOffSavingSnapshots"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
::"TurnOffWindowsCopilot"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows Search]
::"EnableFindMyFiles"=dword:00000001
::"SystemIndexNormalization"=dword:00000003
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System]
::"PromptOnSecureDesktop"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
::"MaxTelemetryAllowed"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\Windows Feeds]
::"EnableFeeds"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage]
::"ACP"="65001"
::"MACCP"="65001"
::"OEMCP"="65001"
::
::[HKEY_LOCAL_MACHINE\SYSTEM\Maps]
::"AutoUpdateEnabled"=dword:00000001
::"UpdateOnlyOnWifi"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Control Panel\Accessibility\StickyKeys]
::"Flags"="506"
::
::[HKEY_USERS\.DEFAULT\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
::@=""
::
::[HKEY_USERS\.DEFAULT\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}]
::@="CLSID_MSGraphHomeFolder"
::"System.IsPinnedToNameSpaceTree"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Input\TIPC]
::"Enabled"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\InputPersonalization]
::"RestrictImplicitInkCollection"=dword:00000001
::"RestrictImplicitTextCollection"=dword:00000001
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\InputPersonalization\TrainedDataStore]
::"HarvestContacts"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Personalization\Settings]
::"AcceptedPrivacyPolicy"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Siuf\Rules]
::"NumberOfSIUFInPeriod"=dword:00000000
::"PeriodInNanoSeconds"=-
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy]
::"HasAccepted"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
::"Enabled"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"Hidden"=dword:00000001
::"LaunchTo"=dword:00000001
::"ShowCopilotButton"=dword:00000000
::"ShowTaskViewButton"=dword:00000000
::"Start_TrackProgs"=dword:00000000
::"TaskbarMn"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings]
::"TaskbarEndTask"=dword:00000001
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
::"HideSCAMeetNow"=dword:00000001
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Privacy]
::"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce]
::"HideGalleryExplorer"="reg add HKCU\\Software\\Classes\\CLSID\\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c} /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f"
::"HideHomeExplorer1"="reg add HKCU\\Software\\Classes\\CLSID\\{f874310e-b6b7-47dc-bc84-b9e6b38f5903} /d CLSID_MSGraphHomeFolder /f /ve"
::"HideHomeExplorer2"="reg add HKCU\\Software\\Classes\\CLSID\\{f874310e-b6b7-47dc-bc84-b9e6b38f5903} /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f"
::"RestoreWin10ContextMenu"="reg add HKCU\\Software\\Classes\\CLSID\\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\\InprocServer32 /f /ve"
::
::[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Start\Companions\Microsoft.YourPhone_8wekyb3d8bbwe]
::"IsEnabled"=dword:00000000
::
::[HKEY_USERS\.DEFAULT\Software\Policies\Microsoft\Windows\Explorer]
::"DisableSearchBoxSuggestions"=dword:00000001
::
::[HKEY_USERS\.DEFAULT\Software\Policies\Microsoft\Windows\WindowsAI]
::"DisableAIDataAnalysis"=dword:00000001
::
::[HKEY_USERS\.DEFAULT\Software\Policies\Microsoft\Windows\WindowsCopilot]
::"TurnOffWindowsCopilot"=dword:00000001
::
::[HKEY_USERS\.DEFAULT\System\GameConfigStore]
::"GameDVR_Enabled"=dword:00000000
::'
::
::#endregion configs > Windows > Windows base
::
::
::#region configs > Windows > Windows personalisation
::
::Set-Variable -Option Constant CONFIG_WINDOWS_PERSONALISATION 'Windows Registry Editor Version 5.00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications]
::"GlobalUserDisabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
::"ContentDeliveryAllowed"=dword:00000001
::"RotatingLockScreenEnabled"=dword:00000001
::"RotatingLockScreenOverlayEnabled"=dword:00000001
::"RotatingLockScreenOverlayVisible"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"NavPaneExpandToCurrentFolder"=dword:00000001
::"NavPaneShowAllFolders"=dword:00000001
::"TaskbarGlomLevel"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers]
::"BackgroundType"=dword:00000006
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen]
::"CreativeId"=""
::"RotatingLockScreenEnabled"=dword:00000001
::"RotatingLockScreenOverlayEnabled"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent]
::"DisableSpotlightCollectionOnDesktop"=dword:00000000
::'
::
::#endregion configs > Windows > Windows personalisation
::
::
::#region configs > Windows > Tools > Debloat app list
::
::Set-Variable -Option Constant CONFIG_DEBLOAT_APP_LIST 'ACGMediaPlayer
::ActiproSoftwareLLC
::AdobeSystemsIncorporated.AdobePhotoshopExpress
::Amazon.com.Amazon
::AmazonVideo.PrimeVideo
::Asphalt8Airborne
::AutodeskSketchBook
::CaesarsSlotsFreeCasino
::Clipchamp.Clipchamp
::COOKINGFEVER
::CyberLinkMediaSuiteEssentials
::Disney
::DisneyMagicKingdoms
::DrawboardPDF
::Duolingo-LearnLanguagesforFree
::EclipseManager
::Facebook
::FarmVille2CountryEscape
::fitbit
::Flipboard
::HiddenCity
::HULULLC.HULUPLUS
::iHeartRadio
::Instagram
::king.com.BubbleWitch3Saga
::king.com.CandyCrushSaga
::king.com.CandyCrushSodaSaga
::LinkedInforWindows
::MarchofEmpires
::Microsoft.3DBuilder
::Microsoft.549981C3F5F10
::Microsoft.BingFinance
::Microsoft.BingFoodAndDrink
::Microsoft.BingHealthAndFitness
::Microsoft.BingNews
::Microsoft.BingSports
::Microsoft.BingTranslator
::Microsoft.BingTravel
::Microsoft.Copilot
::Microsoft.Getstarted
::Microsoft.Messaging
::Microsoft.Microsoft3DViewer
::Microsoft.MicrosoftJournal
::Microsoft.MicrosoftOfficeHub
::Microsoft.MicrosoftPowerBIForWindows
::Microsoft.MicrosoftSolitaireCollection
::Microsoft.MicrosoftStickyNotes
::Microsoft.MixedReality.Portal
::Microsoft.NetworkSpeedTest
::Microsoft.News
::Microsoft.Office.OneNote
::Microsoft.Office.Sway
::Microsoft.OneConnect
::Microsoft.People
::Microsoft.PowerAutomateDesktop
::Microsoft.Print3D
::Microsoft.RemoteDesktop
::Microsoft.ScreenSketch
::Microsoft.SkypeApp
::Microsoft.StartExperiencesApp
::Microsoft.Todos
::Microsoft.Whiteboard
::Microsoft.Windows.DevHome
::Microsoft.WindowsAlarms
::Microsoft.windowscommunicationsapps
::Microsoft.WindowsFeedbackHub
::Microsoft.WindowsMaps
::Microsoft.WindowsSoundRecorder
::Microsoft.WindowsTerminal
::Microsoft.Xbox.TCUI
::Microsoft.XboxApp
::Microsoft.XboxSpeechToTextOverlay
::Microsoft.YourPhone
::Microsoft.ZuneMusic
::Microsoft.ZuneVideo
::MicrosoftCorporationII.MicrosoftFamily
::MicrosoftCorporationII.QuickAssist
::MicrosoftTeams
::MicrosoftWindows.CrossDevice
::Netflix
::NYTCrossword
::OneCalendar
::PandoraMediaInc
::PhototasticCollage
::PicsArt-PhotoStudio
::Plex
::PolarrPhotoEditorAcademicEdition
::Royal Revolt
::Shazam
::Sidia.LiveWallpaper
::SlingTV
::Spotify
::TikTok
::TuneInRadio
::Twitter
::Viber
::WinZipUniversal
::Wunderlist
::XING
::'
::
::#endregion configs > Windows > Tools > Debloat app list
::
::
::#region configs > Windows > Tools > Debloat preset
::
::Set-Variable -Option Constant CONFIG_DEBLOAT_PRESET 'CreateRestorePoint#- Create a system restore point
::DisableTelemetry#- Disable telemetry, diagnostic data, activity history, app-launch tracking & targeted ads
::RemoveAppsCustom#- Remove 101 apps:
::DisableTelemetry#- Disable telemetry, diagnostic data, activity history, app-launch tracking & targeted ads
::DisableSuggestions#- Disable tips, tricks, suggestions and ads in start, settings, notifications and File Explorer
::DisableEdgeAds#- Disable ads, suggestions and the MSN news feed in Microsoft Edge
::DisableSettings365Ads#- Disable Microsoft 365 ads in Settings Home
::DisableLockscreenTips#- Disable tips & tricks on the lockscreen
::DisableBing#- Disable & remove Bing web search, Bing AI and Cortana from Windows search
::DisableCopilot#- Disable & remove Microsoft Copilot
::DisableRecall#- Disable Windows Recall snapshots
::RevertContextMenu#- Restore the old Windows 10 style context menu
::DisableStickyKeys#- Disable the Sticky Keys keyboard shortcut
::HideIncludeInLibrary#- Hide the "Include in library" option in the context menu
::HideGiveAccessTo#- Hide the "Give access to" option in the context menu
::HideShare#- Hide the "Share" option in the context menu
::DisableStartPhoneLink#- Disable the Phone Link mobile devices integration in the start menu.
::TaskbarAlignLeft#- Align taskbar icons to the left
::HideSearchTb#- Hide search icon from the taskbar
::HideTaskview#- Hide the taskview button from the taskbar
::DisableWidgets#- Disable widgets on the taskbar & lockscreen
::EnableEndTask#- Enable the "End Task" option in the taskbar right click menu
::EnableLastActiveClick#- Enable the "Last Active Click" behavior in the taskbar app area
::ExplorerToThisPC#- Change the default location that File Explorer opens to "This PC"
::ShowHiddenFolders#- Show hidden files, folders and drives
::HideHome#- Hide the Home section from the File Explorer sidepanel
::HideGallery#- Hide the Gallery section from the File Explorer sidepanel
::HideDupliDrive#- Hide duplicate removable drive entries from the File Explorer sidepanel
::'
::
::#endregion configs > Windows > Tools > Debloat preset
::
::
::#region configs > Windows > Tools > ShutUp10
::
::Set-Variable -Option Constant CONFIG_SHUTUP10 'P001	+	# Disable sharing of handwriting data (Category: Privacy)
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
::A002	+	# Disable storing users` activity history (Category: Activity History and Clipboard)
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
::F001	+	# Disable inline text prediction in mails (Category: Microsoft Office)
::F003	+	# Disable logging for Microsoft Office Telemetry Agent (Category: Microsoft Office)
::F004	+	# Disable upload of data for Microsoft Office Telemetry Agent (Category: Microsoft Office)
::F005	+	# Obfuscate file names when uploading telemetry data (Category: Microsoft Office)
::F007	+	# Disable Microsoft Office surveys (Category: Microsoft Office)
::F008	+	# Disable feedback to Microsoft (Category: Microsoft Office)
::F009	+	# Disable Microsoft`s feedback tracking (Category: Microsoft Office)
::F017	+	# Disable Microsoft`s feedback tracking (Category: Microsoft Office)
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
::W005	-	# Disable automatic downloading manufacturers` apps and icons for devices (Category: Windows Update)
::W010	-	# Disable automatic driver updates through Windows Update (Category: Windows Update)
::W009	-	# Disable automatic app updates through Windows Update (Category: Windows Update)
::P017	-	# Disable Windows dynamic configuration and update rollouts (Category: Windows Update)
::W006	-	# Disable automatic Windows Updates (Category: Windows Update)
::W008	-	# Disable Windows Updates for other products (e.g. Microsoft Office) (Category: Windows Update)
::M006	+	# Disable occasionally showing app suggestions in Start menu (Category: Windows Explorer)
::M011	-	# Do not show recently opened items in Jump Lists on `Start` or the taskbar (Category: Windows Explorer)
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
::M016	+	# Disable search box in task bar (Category: Taskbar)
::M017	+	# Disable `Meet now` in the task bar (Category: Taskbar)
::M018	+	# Disable `Meet now` in the task bar (Category: Taskbar)
::M019	+	# Disable news and interests in the task bar (Category: Taskbar)
::M021	+	# Disable widgets in Windows Explorer (Category: Taskbar)
::M022	+	# Disable feedback reminders (Category: Miscellaneous)
::M001	+	# Disable feedback reminders (Category: Miscellaneous)
::M004	+	# Disable automatic installation of recommended Windows Store Apps (Category: Miscellaneous)
::M005	+	# Disable tips, tricks, and suggestions while using Windows (Category: Miscellaneous)
::M024	+	# Disable Windows Media Player Diagnostics (Category: Miscellaneous)
::M026	+	# Disable remote assistance connections to this computer (Category: Miscellaneous)
::M027	+	# Disable remote connections to this computer (Category: Miscellaneous)
::M028	+	# Disable the desktop icon for information on `Windows Spotlight` (Category: Miscellaneous)
::M012	-	# Disable Key Management Service Online Activation (Category: Miscellaneous)
::M013	-	# Disable automatic download and update of map data (Category: Miscellaneous)
::M014	-	# Disable unsolicited network traffic on the offline maps settings page (Category: Miscellaneous)
::N001	-	# Disable Network Connectivity Status Indicator (Category: Miscellaneous)
::'
::
::#endregion configs > Windows > Tools > ShutUp10
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
::                      "WPFTweaksHome",
::                      "WPFTweaksLoc",
::                      "WPFTweaksPowershell7Tele",
::                      "WPFTweaksRecallOff",
::                      "WPFTweaksRemoveCopilot",
::                      "WPFTweaksRemoveGallery",
::                      "WPFTweaksRestorePoint",
::                      "WPFTweaksRightClickMenu",
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
::#region functions > Common > Download file
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
::    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$PATH_CURRENT_DIR\$FileName" })
::
::    New-Item -Force -ItemType Directory $PATH_APP_DIR | Out-Null
::
::    Write-LogInfo "Downloading from $URL"
::
::    Set-Variable -Option Constant IsNotConnected (Test-NetworkConnection)
::    if ($IsNotConnected) {
::        Write-LogError "Download failed: $IsNotConnected"
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
::        Remove-Item -Force -ErrorAction SilentlyContinue $SavePath
::        (New-Object System.Net.WebClient).DownloadFile($URL, $TempPath)
::
::        if (-not $Temp) {
::            Move-Item -Force -ErrorAction SilentlyContinue $TempPath $SavePath
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
::#endregion functions > Common > Download file
::
::
::#region functions > Common > Download unzip and run
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
::        Set-Variable -Option Constant Executable $(if ($IsZip) { Expand-Zip $DownloadedFile -Execute:$Execute } else { $DownloadedFile })
::
::        if ($Execute) {
::            Start-Executable $Executable $Params -Silent:$Silent
::        }
::    }
::}
::
::#endregion functions > Common > Download unzip and run
::
::
::#region functions > Common > Exit
::
::function Reset-State {
::    Write-LogInfo "Cleaning up '$PATH_APP_DIR'"
::    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_APP_DIR
::    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
::    Write-Host ''
::}
::
::function Exit-Script {
::    Reset-State
::    $FORM.Close()
::}
::
::#endregion functions > Common > Exit
::
::
::#region functions > Common > Extract ZIP
::
::function Expand-Zip {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
::        [Switch]$Execute
::    )
::
::    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
::    Set-Variable -Option Constant ExtractionPath $ZipPath.TrimEnd('.zip')
::    Set-Variable -Option Constant ExtractionDir (Split-Path -Leaf $ExtractionPath)
::    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_APP_DIR } else { $PATH_CURRENT_DIR })
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
::    Remove-Item -Force -ErrorAction SilentlyContinue $TemporaryExe
::    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath
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
::    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath
::
::    if (-not $IsDirectory) {
::        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryExe $TargetExe
::        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath
::    }
::
::    if (-not $Execute -and $IsDirectory) {
::        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse "$TargetPath\$ExtractionDir"
::        Move-Item -Force -ErrorAction SilentlyContinue $ExtractionPath $TargetPath
::    }
::
::    Out-Success
::    Write-LogInfo "Files extracted to '$TargetPath'"
::
::    return $TargetExe
::}
::
::#endregion functions > Common > Extract ZIP
::
::
::#region functions > Common > Invoke command
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
::    Set-Variable -Option Constant CallerPath $(if ($WorkingDirectory) { "-CallerPath:$WorkingDirectory" } else { '' })
::    Set-Variable -Option Constant Verb $(if ($Elevated) { 'RunAs' } else { 'Open' })
::    Set-Variable -Option Constant WindowStyle $(if ($HideWindow) { 'Hidden' } else { 'Normal' })
::
::    Set-Variable -Option Constant FullCommand "$ExecutionPolicy $Command $CallerPath"
::
::    Start-Process PowerShell $FullCommand -Wait:$Wait -Verb:$Verb -WindowStyle:$WindowStyle
::}
::
::#endregion functions > Common > Invoke command
::
::
::#region functions > Common > Logger
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
::    Write-Log 'WARN' $Message
::}
::
::function Write-LogError {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Message
::    )
::    Write-Log 'ERROR' $Message
::}
::
::function Write-Log {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INFO', 'WARN', 'ERROR')]$Level,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Message
::    )
::
::    Set-Variable -Option Constant Text "[$((Get-Date).ToString())] $Message"
::
::    $LOG.SelectionStart = $LOG.TextLength
::
::    switch ($Level) {
::        'INFO' {
::            $LOG.SelectionColor = 'black'
::            Write-Host $Text
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
::            Write-Host $Text
::        }
::    }
::
::    $LOG.AppendText("$Text`n")
::    $LOG.SelectionColor = 'black'
::    $LOG.ScrollToCaret()
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
::    Out-Status 'Done'
::}
::
::function Out-Failure {
::    Out-Status 'Failed'
::}
::
::
::function Write-ExceptionLog {
::    param(
::        [System.Object][Parameter(Position = 0, Mandatory = $True)]$Exception,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Message
::    )
::
::    Write-LogError "$($Message): $($Exception.Exception.Message)"
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
::#region functions > Common > Open in a browser
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
::#endregion functions > Common > Open in a browser
::
::
::#region functions > Common > Run executable
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
::        Write-LogInfo "Removing '$Executable'..."
::        Remove-Item -Force $Executable
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
::#endregion functions > Common > Run executable
::
::
::#region functions > Common > Startup
::
::function Initialize-Script {
::    $FORM.Activate()
::
::    Write-LogInfo 'Initializing...'
::
::    Set-Variable -Option Constant IE_Registry_Key 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main'
::
::    New-Item $IE_Registry_Key -ErrorAction SilentlyContinue
::    Set-ItemProperty -Path $IE_Registry_Key -Name 'DisableFirstRunCustomize' -Value 1 -ErrorAction SilentlyContinue
::
::    if ($OS_VERSION -lt 8) {
::        Write-LogWarning "Windows $OS_VERSION detected, some features are not supported."
::    }
::
::    try {
::        [Net.ServicePointManager]::SecurityProtocol = 'Tls12'
::    } catch [Exception] {
::        Write-LogWarning "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)"
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
::
::    Get-CurrentVersion
::}
::
::#endregion functions > Common > Startup
::
::
::#region functions > Common > Updater
::
::function Get-CurrentVersion {
::    Write-LogInfo 'Checking for updates...'
::
::    Set-Variable -Option Constant IsNotConnected (Test-NetworkConnection)
::    if ($IsNotConnected) {
::        Write-LogError "Failed to check for updates: $IsNotConnected"
::        return
::    }
::
::    $ProgressPreference = 'SilentlyContinue'
::    try {
::        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest 'https://bit.ly/qiiwexc_version').ToString())
::        $ProgressPreference = 'Continue'
::    } catch [Exception] {
::        $ProgressPreference = 'Continue'
::        Write-ExceptionLog $_ 'Failed to check for updates'
::        return
::    }
::
::    if ($LatestVersion -gt $VERSION) {
::        Write-LogWarning "Newer version available: v$LatestVersion"
::        Update-Self
::    } else {
::        Out-Status 'No updates available'
::    }
::}
::
::
::function Update-Self {
::    Set-Variable -Option Constant TargetFileBat "$PATH_CURRENT_DIR\qiiwexc.bat"
::
::    Write-LogWarning 'Downloading new version...'
::
::    Set-Variable -Option Constant IsNotConnected (Test-NetworkConnection)
::
::    if ($IsNotConnected) {
::        Write-LogError "Failed to download update: $IsNotConnected"
::        return
::    }
::
::    try {
::        Invoke-WebRequest 'https://bit.ly/qiiwexc_bat' -OutFile $TargetFileBat
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to download update'
::        return
::    }
::
::    Out-Success
::    Write-LogWarning 'Restarting...'
::
::    try {
::        Invoke-CustomCommand $TargetFileBat
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to start new version'
::        return
::    }
::
::    Exit-Script
::}
::
::#endregion functions > Common > Updater
::
::
::#region functions > Configuration > Apps > Apply configuration
::
::function Set-AppsConfiguration {
::    if ($CHECKBOX_Config_VLC.Checked) {
::        Set-VlcConfiguration $CHECKBOX_Config_VLC.Text
::    }
::
::    if ($CHECKBOX_Config_qBittorrent.Checked) {
::        Set-qBittorrentConfiguration $CHECKBOX_Config_qBittorrent.Text
::    }
::
::    if ($CHECKBOX_Config_7zip.Checked) {
::        Import-RegistryConfiguration $CHECKBOX_Config_7zip.Text $CONFIG_7ZIP
::    }
::
::    if ($CHECKBOX_Config_TeamViewer.Checked) {
::        Import-RegistryConfiguration $CHECKBOX_Config_TeamViewer.Text $CONFIG_TEAMVIEWER
::    }
::
::    if ($CHECKBOX_Config_Edge.Checked) {
::        Set-MicrosoftEdgeConfiguration $CHECKBOX_Config_Edge.Text
::    }
::
::    if ($CHECKBOX_Config_Chrome.Checked) {
::        Set-GoogleChromeConfiguration $CHECKBOX_Config_Chrome.Text
::    }
::}
::
::#endregion functions > Configuration > Apps > Apply configuration
::
::
::#region functions > Configuration > Apps > Google Chrome
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
::#endregion functions > Configuration > Apps > Google Chrome
::
::
::#region functions > Configuration > Apps > Microsoft Edge
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
::#endregion functions > Configuration > Apps > Microsoft Edge
::
::
::#region functions > Configuration > Apps > qBittorrent
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
::#endregion functions > Configuration > Apps > qBittorrent
::
::
::#region functions > Configuration > Apps > VLC
::
::function Set-VlcConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName
::    )
::
::    Write-ConfigurationFile $AppName $CONFIG_VLC "$env:AppData\vlc\vlcrc"
::}
::
::#endregion functions > Configuration > Apps > VLC
::
::
::#region functions > Configuration > Helpers > Import registry configuration
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
::    $Content | Out-File $RegFilePath
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
::#endregion functions > Configuration > Helpers > Import registry configuration
::
::
::#region functions > Configuration > Helpers > Merge JSON
::
::function Merge-JsonObjects {
::    param(
::        [Parameter(Position = 0, Mandatory = $True)]$Source,
::        [Parameter(Position = 1, Mandatory = $True)]$Extend
::    )
::
::    if ($Source -is [System.Object] -and $Extend -is [System.Object]) {
::        [System.Object]$Merged = [Ordered] @{}
::
::        foreach ($Property in $Source.PSObject.Properties) {
::            if ($Null -eq $Extend.$($Property.Name)) {
::                $Merged[$Property.Name] = $Property.Value
::            } else {
::                $Merged[$Property.Name] = Merge-JsonObjects $Property.Value $Extend.$($Property.Name)
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
::                Merge-JsonObjects $Source[$i] $Extend[$i]
::            }
::        }
::
::        , $Merged
::    } else {
::        $Extend
::    }
::}
::
::#endregion functions > Configuration > Helpers > Merge JSON
::
::
::#region functions > Configuration > Helpers > Update JSON file
::
::function Update-JsonFile {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
::        [String][Parameter(Position = 1, Mandatory = $True)]$ProcessName,
::        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
::        [String][Parameter(Position = 3, Mandatory = $True)]$Path
::    )
::
::    Write-LogInfo "Writing $AppName configuration to '$Path'..."
::
::    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue
::
::    New-Item -ItemType Directory (Split-Path -Parent $Path) -ErrorAction SilentlyContinue
::
::    if (Test-Path $Path) {
::        Set-Variable -Option Constant CurrentConfig (Get-Content $Path -Raw | ConvertFrom-Json)
::        Set-Variable -Option Constant PatchConfig ($Content | ConvertFrom-Json)
::
::        Set-Variable -Option Constant UpdatedConfig (Merge-JsonObjects $CurrentConfig $PatchConfig | ConvertTo-Json -Depth 100 -Compress)
::
::        $UpdatedConfig | Out-File $Path
::    } else {
::        Write-LogInfo "'$Path' does not exist. Creating new file..."
::        $Content | Out-File $Path
::    }
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Helpers > Update JSON file
::
::
::#region functions > Configuration > Helpers > Write configuration file
::
::function Write-ConfigurationFile {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Content,
::        [String][Parameter(Position = 2, Mandatory = $True)]$Path,
::        [String][Parameter(Position = 3)]$ProcessName = $AppName
::    )
::
::    Write-LogInfo "Writing $AppName configuration to '$Path'..."
::
::    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue
::
::    New-Item -ItemType Directory (Split-Path -Parent $Path) -ErrorAction SilentlyContinue
::    $Content | Out-File $Path
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Helpers > Write configuration file
::
::
::#region functions > Configuration > Windows > Alternative DNS
::
::function Set-CloudFlareDNS {
::    [String]$PreferredDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.1.1.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.1.1.2' } else { '1.1.1.1' } }
::    [String]$AlternateDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.0.0.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.0.0.2' } else { '1.0.0.1' } }
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
::        Invoke-CustomCommand -Elevated -HideWindow "Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' | Invoke-CimMethod -MethodName 'SetDNSServerSearchOrder' -Arguments @{ DNSServerSearchOrder = @('$PreferredDnsServer', '$AlternateDnsServer') }"
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to change DNS server'
::        return
::    }
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > Alternative DNS
::
::
::#region functions > Configuration > Windows > Apply configuration
::
::function Set-WindowsConfiguration {
::    if ($CHECKBOX_Config_WindowsBase.Checked) {
::        Set-WindowsBaseConfiguration $CHECKBOX_Config_WindowsBase.Text
::    }
::
::    if ($CHECKBOX_Config_PowerScheme.Checked) {
::        Set-PowerSchemeConfiguration
::    }
::
::    if ($CHECKBOX_Config_WindowsSearch.Checked) {
::        Set-SearchConfiguration $CHECKBOX_Config_WindowsSearch.Text
::    }
::
::    if ($CHECKBOX_Config_FileAssociations.Checked) {
::        Set-FileAssociations
::    }
::
::    if ($CHECKBOX_Config_WindowsPersonalisation.Checked) {
::        Set-WindowsPersonalisationConfig $CHECKBOX_Config_WindowsPersonalisation.Text
::    }
::}
::
::#endregion functions > Configuration > Windows > Apply configuration
::
::
::#region functions > Configuration > Windows > Base configuration
::
::function Set-WindowsBaseConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
::    )
::
::    Write-LogInfo 'Applying Windows configuration...'
::
::    if ($PS_VERSION -ge 5) {
::        Set-MpPreference -PUAProtection Enabled
::        Set-MpPreference -MeteredConnectionUpdates $True
::    }
::
::    Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sCurrency' -Value ([Char]0x20AC)
::    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value 3
::
::    Unregister-ScheduledTask -TaskName 'CreateExplorerShellUnelevatedTask' -Confirm:$False -ErrorAction SilentlyContinue
::
::    [String]$ConfigLines = ''
::
::    try {
::        Set-Variable -Option Constant UserRegistries ((Get-Item 'Registry::HKEY_USERS\*').Name | Where-Object { $_ -match 'S-1-5-21' -and $_ -notmatch '_Classes$' })
::        foreach ($Registry in $UserRegistries) {
::            Set-Variable -Option Constant User ($Registry.Replace('HKEY_USERS\', ''))
::            $ConfigLines += "`n[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\InstallService\Stubification\$User]`n"
::            $ConfigLines += "`"EnableAppOffloading`"=dword:00000000`n"
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
::    Import-RegistryConfiguration $FileName ($CONFIG_WINDOWS_BASE + $ConfigLines)
::}
::
::#endregion functions > Configuration > Windows > Base configuration
::
::
::#region functions > Configuration > Windows > File associations
::
::function Set-FileAssociations {
::    Write-LogInfo 'Setting file associations...'
::
::    Set-Variable -Option Constant ScriptPath "$PATH_TEMP_DIR\Sophia.ps1"
::
::    $Parameters = @{
::        Uri             = "https://raw.githubusercontent.com/farag2/Sophia-Script-for-Windows/master/src/Sophia_Script_for_Windows_$OS_VERSION/Module/Sophia.psm1"
::        Outfile         = $ScriptPath
::        UseBasicParsing = $true
::    }
::    Invoke-WebRequest @Parameters
::
::    (Get-Content -Path $ScriptPath -Force) | Set-Content -Path $ScriptPath -Encoding UTF8 -Force
::
::    . $ScriptPath
::
::    foreach ($FileAssociation in $CONFIG_FILE_ASSOCIATIONS) {
::        Set-Association -ProgramPath $FileAssociation.Application -Extension $FileAssociation.Extension
::    }
::
::    Remove-Item -Path $ScriptPath -Force
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > File associations
::
::
::#region functions > Configuration > Windows > Personalisation
::
::function Set-WindowsPersonalisationConfig {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
::    )
::
::    Write-LogInfo 'Applying Windows personalisation configuration...'
::
::    [String]$ConfigLines = ''
::
::    try {
::        Set-Variable -Option Constant UserRegistries ((Get-Item 'Registry::HKEY_USERS\*').Name | Where-Object { $_ -match 'S-1-5-21' -and $_ -notmatch '_Classes$' })
::        foreach ($Registry in $UserRegistries) {
::            # [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$User]
::            # `"RotatingLockScreenEnabled`"=dword:00000001
::            # `"RotatingLockScreenOverlayEnabled`"=dword:00000001`n"
::        }
::
::        Set-Variable -Option Constant NotificationRegistries ((Get-Item 'HKCU:\Control Panel\NotifyIconSettings\*').Name)
::        foreach ($Registry in $NotificationRegistries) {
::            $ConfigLines += "`n[$Registry]`n"
::            $ConfigLines += "`"IsPromoted`"=dword:00000001`n"
::        }
::    } catch [Exception] {
::        Write-ExceptionLog $_ 'Failed to read the registry'
::    }
::
::    Import-RegistryConfiguration $FileName ($CONFIG_WINDOWS_PERSONALISATION + $ConfigLines)
::}
::
::#endregion functions > Configuration > Windows > Personalisation
::
::
::#region functions > Configuration > Windows > Power scheme
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
::#endregion functions > Configuration > Windows > Power scheme
::
::
::#region functions > Configuration > Windows > Remove components
::
::function Remove-WindowsFeatures {
::    Write-LogInfo 'Starting miscellaneous Windows features cleanup...'
::
::    Set-Variable -Option Constant FeaturesToRemove @('App.StepsRecorder',
::        'MathRecognizer',
::        'Media.WindowsMediaPlayer',
::        'OpenSSH.Client',
::        'VBSCRIPT'
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
::        Out-Success
::    }
::
::    if (Test-Path 'mstsc.exe') {
::        Write-LogInfo "Removing 'mstsc'..."
::        Start-Process 'mstsc' '/uninstall'
::        Out-Success
::    }
::}
::
::#endregion functions > Configuration > Windows > Remove components
::
::
::#region functions > Configuration > Windows > Search index
::
::function Set-SearchConfiguration {
::    param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
::    )
::
::    Write-LogInfo 'Applying Windows search index configuration...'
::
::    [String]$ConfigLines = ''
::
::    try {
::        Set-Variable -Option Constant FileExtensionRegistries ((Get-Item 'Registry::HKEY_CLASSES_ROOT\*' -ErrorAction SilentlyContinue).Name | Where-Object { $_ -match 'HKEY_CLASSES_ROOT\\\.' })
::        foreach ($Registry in $FileExtensionRegistries) {
::            $PersistentHandlerRegistries = (Get-Item "Registry::$Registry\*").Name | Where-Object { $_ -match 'PersistentHandler' }
::
::            foreach ($Reg in $PersistentHandlerRegistries) {
::                $PersistentHandler = Get-ItemProperty "Registry::$Reg"
::                $DefaultHandler = $PersistentHandler.'(default)'
::
::                if ($DefaultHandler -and -not ($DefaultHandler -eq '{098F2470-BAE0-11CD-B579-08002B30BFEB}')) {
::                    $ConfigLines += "`n[$Reg]`n"
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
::#endregion functions > Configuration > Windows > Search index
::
::
::#region functions > Configuration > Windows > Tools > Debloat Windows
::
::function Start-WindowsDebloat {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$UsePreset,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
::    )
::
::    Write-LogInfo 'Starting Windows 10/11 debloat utility...'
::
::    Set-Variable -Option Constant TargetPath "$PATH_TEMP_DIR\Win11Debloat"
::    New-Item -ItemType Directory $TargetPath -ErrorAction SilentlyContinue
::
::    Set-Variable -Option Constant CustomAppsListFile "$TargetPath\CustomAppsList"
::    $CONFIG_DEBLOAT_APP_LIST | Out-File $CustomAppsListFile
::
::    Set-Variable -Option Constant SavedSettingsFile "$TargetPath\SavedSettings"
::    $CONFIG_DEBLOAT_PRESET | Out-File $SavedSettingsFile
::
::    Set-Variable -Option Constant UsePresetParam $(if ($UsePreset) { '-RunSavedSettings' } else { '' })
::    Set-Variable -Option Constant SilentParam $(if ($Silent) { '-Silent' } else { '' })
::    Set-Variable -Option Constant Params "-Sysprep $UsePresetParam $SilentParam"
::
::    Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > Tools > Debloat Windows
::
::
::#region functions > Configuration > Windows > Tools > ShutUp10
::
::function Start-ShutUp10 {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
::    )
::
::    Write-LogInfo 'Starting ShutUp10++ utility...'
::
::    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_APP_DIR } else { $PATH_CURRENT_DIR })
::    Set-Variable -Option Constant ConfigFile "$TargetPath\ooshutup10.cfg"
::
::    $CONFIG_SHUTUP10 | Out-File $ConfigFile
::
::    if ($Silent) {
::        Start-DownloadUnzipAndRun -Execute:$Execute 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe' -Params $ConfigFile
::    } else {
::        Start-DownloadUnzipAndRun -Execute:$Execute 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
::    }
::}
::
::#endregion functions > Configuration > Windows > Tools > ShutUp10
::
::
::#region functions > Configuration > Windows > Tools > WinUtil
::
::function Start-WinUtil {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Apply
::    )
::
::    Write-LogInfo 'Starting WinUtil utility...'
::
::    Set-Variable -Option Constant ConfigFile "$PATH_APP_DIR\winutil.json"
::
::    $CONFIG_WINUTIL | Out-File $ConfigFile
::
::    Set-Variable -Option Constant ConfigParam "-Config $ConfigFile"
::    Set-Variable -Option Constant RunParam $(if ($Apply) { '-Run' } else { '' })
::
::    Invoke-CustomCommand "& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) $ConfigParam $RunParam"
::
::    Out-Success
::}
::
::#endregion functions > Configuration > Windows > Tools > WinUtil
::
::
::#region functions > Diagnostics and recovery > Battery report
::
::function Get-BatteryReport {
::    Write-LogInfo 'Exporting battery report...'
::
::    Set-Variable -Option Constant ReportPath "$PATH_APP_DIR\battery_report.html"
::
::    powercfg /BatteryReport /Output $ReportPath
::
::    Open-InBrowser $ReportPath
::
::    Out-Success
::}
::
::#endregion functions > Diagnostics and recovery > Battery report
::
::
::#region functions > Home > Activator
::
::function Start-Activator {
::    Write-LogInfo 'Starting MAS activator...'
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
::#endregion functions > Home > Activator
::
::
::#region functions > Home > Cleanup
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
::    New-Item -Force -ItemType Directory $PATH_APP_DIR | Out-Null
::    Out-Success
::
::    Write-LogInfo 'Running system cleanup...'
::
::    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | ForEach-Object -Process {
::        Remove-ItemProperty -Path $_.PsPath -Name StateFlags3224 -Force -ErrorAction Ignore
::    }
::
::    Set-Variable -Option Constant VolumeCaches @(
::        'Delivery Optimization Files',
::        'Device Driver Packages',
::        'Language Pack',
::        'Previous Installations',
::        'Setup Log Files',
::        'System error memory dump files',
::        'System error minidump files',
::        'Temporary Setup Files',
::        'Update Cleanup',
::        'Windows Defender',
::        'Windows ESD installation files',
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
::#endregion functions > Home > Cleanup
::
::
::#region functions > Home > Update Microsoft Office
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
::#endregion functions > Home > Update Microsoft Office
::
::
::#region functions > Home > Update Microsoft Store apps
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
::#endregion functions > Home > Update Microsoft Store apps
::
::
::#region functions > Home > Update Windows
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
::#endregion functions > Home > Update Windows
::
::
::#region functions > Installs > Microsoft Office
::
::function Install-MicrosoftOffice {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute
::    )
::
::    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_APP_DIR } else { $PATH_CURRENT_DIR })
::    Set-Variable -Option Constant Config $(if ($SYSTEM_LANGUAGE -match 'ru') { $CONFIG_OFFICE_INSTALLER.Replace('en-GB', 'ru-RU') } else { $CONFIG_OFFICE_INSTALLER })
::
::    $Config | Out-File "$TargetPath\Office Installer+.ini" -Encoding UTF8
::
::    Start-DownloadUnzipAndRun -AVWarning -Execute:$Execute 'https://qiiwexc.github.io/d/Office_Installer+.zip'
::}
::
::#endregion functions > Installs > Microsoft Office
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
::        [Boolean][Parameter(Position = 0, Mandatory = $True)]$OpenInBrowser,
::        [Boolean][Parameter(Position = 1)]$Execute
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
::#region functions > Installs > Unchecky
::
::function Install-Unchecky {
::    param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
::    )
::
::    Set-Variable -Option Constant Registry_Key 'HKCU:\Software\Unchecky'
::    New-Item $Registry_Key -ErrorAction SilentlyContinue
::    Set-ItemProperty -Path $Registry_Key -Name 'HideTrayIcon' -Value 1 -ErrorAction SilentlyContinue
::
::    Set-Variable -Option Constant Params $(if ($Silent) { '-install -no_desktop_icon' })
::    Start-DownloadUnzipAndRun -Execute:$Execute 'https://fi.softradar.com/static/products/unchecky/distr/1.2/unchecky_softradar-com.exe' -Params:$Params -Silent:$Silent
::}
::
::#endregion functions > Installs > Unchecky
::
::
::#region interface > Show window
::
::[Void]$FORM.ShowDialog()
::
::#endregion interface > Show window
