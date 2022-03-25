Set-Variable -Option Constant Version ([Version]'22.3.25')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Info #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

<#

-=-=-=-=-=-= README =-=-=-=-=-=-

To execute, right-click the file, then select "Run with PowerShell".

Double click will simply open the file in Notepad.


-=-=-=-= TROUBLESHOOTING =-=-=-=-

If a window briefly opens and closes, press Win+R on the keyboard, paste the following and click OK:

    PowerShell -Command "Start-Process 'PowerShell' -Verb RunAs '-Command Set-ExecutionPolicy RemoteSigned -Force'"

Now you can try starting the utility again

#>


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Initialization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Write-Host 'Initializing...'

Set-Variable -Option Constant IS_ELEVATED $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))

Set-Variable -Option Constant OLD_WINDOW_TITLE $($HOST.UI.RawUI.WindowTitle)
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"

Set-Variable -Option Constant StartedFromGUI $($MyInvocation.Line -Match 'if((Get-ExecutionPolicy ) -ne ''AllSigned'')*')
Set-Variable -Option Constant HIDE_CONSOLE ($args[0] -eq '-HideConsole' -or $StartedFromGUI -or -not $MyInvocation.Line)

if ($HIDE_CONSOLE) {
    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

try { Add-Type -AssemblyName System.Windows.Forms } catch { Throw 'System not supported' }

[System.Windows.Forms.Application]::EnableVisualStyles()

Set-Variable -Option Constant PS_VERSION $($PSVersionTable.PSVersion.Major)

Set-Variable -Option Constant SHELL $(New-Object -com Shell.Application)


Write-Host -NoNewline "`n[$((Get-Date).ToString())] StartedFromGUI = $StartedFromGUI"
Write-Host -NoNewline "`n[$((Get-Date).ToString())] args = $($args)"
Write-Host "`n[$((Get-Date).ToString())] MyInvocation = $($MyInvocation.Line)"


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Constants #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'

Set-Variable -Option Constant REQUIRES_ELEVATION $(if (-not $IS_ELEVATED) { '*' })


Set-Variable -Option Constant WIDTH_BUTTON    170
Set-Variable -Option Constant HEIGHT_BUTTON   30

Set-Variable -Option Constant WIDTH_CHECKBOX   145
Set-Variable -Option Constant HEIGHT_CHECKBOX  20

Set-Variable -Option Constant INTERVAL_SHORT     5
Set-Variable -Option Constant INTERVAL_NORMAL    15
Set-Variable -Option Constant INTERVAL_LONG      30
Set-Variable -Option Constant INTERVAL_GROUP_TOP 20


Set-Variable -Option Constant INTERVAL_BUTTON_SHORT    ($HEIGHT_BUTTON + $INTERVAL_SHORT)
Set-Variable -Option Constant INTERVAL_BUTTON_NORMAL   ($HEIGHT_BUTTON + $INTERVAL_NORMAL)
Set-Variable -Option Constant INTERVAL_BUTTON_LONG     ($HEIGHT_BUTTON + $INTERVAL_LONG)

Set-Variable -Option Constant INTERVAL_CHECKBOX_SHORT  ($HEIGHT_CHECKBOX + $INTERVAL_SHORT)
Set-Variable -Option Constant INTERVAL_CHECKBOX_NORMAL ($HEIGHT_CHECKBOX + $INTERVAL_NORMAL)


Set-Variable -Option Constant WIDTH_GROUP ($INTERVAL_NORMAL + $WIDTH_BUTTON + $INTERVAL_NORMAL)

Set-Variable -Option Constant WIDTH_FORM  (($WIDTH_GROUP + $INTERVAL_NORMAL) * 3 + ($INTERVAL_NORMAL * 2))
Set-Variable -Option Constant HEIGHT_FORM ($INTERVAL_BUTTON_NORMAL * 13)

Set-Variable -Option Constant CHECKBOX_SIZE "$WIDTH_CHECKBOX, $HEIGHT_CHECKBOX"

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON "$INTERVAL_NORMAL, $INTERVAL_GROUP_TOP"
Set-Variable -Option Constant INITIAL_LOCATION_GROUP  "$INTERVAL_NORMAL, $INTERVAL_NORMAL"


Set-Variable -Option Constant SHIFT_BUTTON_SHORT      "0, $INTERVAL_BUTTON_SHORT"
Set-Variable -Option Constant SHIFT_BUTTON_NORMAL     "0, $INTERVAL_BUTTON_NORMAL"
Set-Variable -Option Constant SHIFT_BUTTON_LONG       "0, $INTERVAL_BUTTON_LONG"

Set-Variable -Option Constant SHIFT_CHECKBOX          "0, $INTERVAL_CHECKBOX_SHORT"
Set-Variable -Option Constant SHIFT_CHECKBOX_EXECUTE  "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"

Set-Variable -Option Constant SHIFT_GROUP_HORIZONTAL  "$($WIDTH_GROUP + $INTERVAL_NORMAL), 0"

Set-Variable -Option Constant SHIFT_LABEL_BROWSER     "$INTERVAL_LONG, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"


Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"


Set-Variable -Option Constant PATH_PROGRAM_FILES_86 $(if ($OS_64_BIT) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles })
Set-Variable -Option Constant PATH_DEFENDER_EXE "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
Set-Variable -Option Constant PATH_CHROME_EXE "$PATH_PROGRAM_FILES_86\Google\Chrome\Application\chrome.exe"
Set-Variable -Option Constant PATH_MRT_EXE "$env:windir\System32\MRT.exe"
Set-Variable -Option Constant PATH_TEMP_DIR "$env:TMP\qiiwexc"


Set-Variable -Option Constant OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version)

Set-Variable -Option Constant OS_NAME $OperatingSystem.Caption
Set-Variable -Option Constant OS_BUILD $OperatingSystem.Version
Set-Variable -Option Constant OS_64_BIT $(if ($env:PROCESSOR_ARCHITECTURE -Like '*64') { $True })
Set-Variable -Option Constant OS_VERSION $(Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } })


Set-Variable -Option Constant LogicalDisk (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'")
Set-Variable -Option Constant SYSTEM_PARTITION ($LogicalDisk | Select-Object @{L = 'FreeSpace'; E = { '{0:N2}' -f ($_.FreeSpace / 1GB) } }, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })


Set-Variable -Option Constant WordRegPath (Get-ItemProperty "$(New-PSDrive HKCR Registry HKEY_CLASSES_ROOT):\Word.Application\CurVer" -ErrorAction SilentlyContinue)
Set-Variable -Option Constant OFFICE_VERSION $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' })
Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if ($OFFICE_VERSION) { if (Test-Path $PATH_OFFICE_C2R_CLIENT_EXE) { 'C2R' } else { 'MSI' } })


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Texts #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TXT_START_AFTER_DOWNLOAD 'Start after download'
Set-Variable -Option Constant TXT_OPENS_IN_BROWSER 'Opens in the browser'
Set-Variable -Option Constant TXT_UNCHECKY_INFO 'Unchecky clears adware checkboxes when installing software'
Set-Variable -Option Constant TXT_AV_WARNING "This file may trigger anti-virus false positive!`nIt is recommended to disable anti-virus software for download and subsequent use of this file!"

Set-Variable -Option Constant TXT_TIP_START_AFTER_DOWNLOAD "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"


Set-Variable -Option Constant URL_KMS_AUTO_LITE 'qiiwexc.github.io/d/KMSAuto_Lite.zip'
Set-Variable -Option Constant URL_AACT          'qiiwexc.github.io/d/AAct.zip'

Set-Variable -Option Constant URL_WINDOWS_11 'w14.monkrus.ws/2021/10/windows-11-v21h2-rus-eng-26in1-hwid-act_14.html'
Set-Variable -Option Constant URL_WINDOWS_10 'w14.monkrus.ws/2021/12/windows-10-v21h2-rus-eng-x86-x64-40in1.html'
Set-Variable -Option Constant URL_WINDOWS_7  'w14.monkrus.ws/2022/02/windows-7-sp1-rus-eng-x86-x64-18in1.html'
Set-Variable -Option Constant URL_WINDOWS_XP 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'

Set-Variable -Option Constant URL_CCLEANER   'download.ccleaner.com/ccsetup.exe'
Set-Variable -Option Constant URL_RUFUS      'github.com/pbatard/rufus/releases/download/v3.18/rufus-3.18p.exe'
Set-Variable -Option Constant URL_WINDOWS_PE 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'

Set-Variable -Option Constant URL_CHROME_HTTPS   'chrome.google.com/webstore/detail/gcbommkclmclpchllfjekcdonpmejbdp'
Set-Variable -Option Constant URL_CHROME_ADBLOCK 'chrome.google.com/webstore/detail/gighmmpiobklfepjocnamgkkbiglidom'
Set-Variable -Option Constant URL_CHROME_YOUTUBE 'chrome.google.com/webstore/detail/gebbhagfogifgggkldgodflihgfeippi'

Set-Variable -Option Constant URL_SDI      'sdi-tool.org/releases/SDI_R2201.zip'
Set-Variable -Option Constant URL_UNCHECKY 'unchecky.com/files/unchecky_setup.exe'
Set-Variable -Option Constant URL_OFFICE   'qiiwexc.github.io/d/Office_2013-2021.zip'

Set-Variable -Option Constant URL_VICTORIA 'hdd.by/Victoria/Victoria537.zip'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant FORM (New-Object System.Windows.Forms.Form)
$FORM.Text = $HOST.UI.RawUI.WindowTitle
$FORM.ClientSize = "$WIDTH_FORM, $HEIGHT_FORM"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )
$FORM.Add_FormClosing( { Reset-StateOnExit } )


Set-Variable -Option Constant LOG (New-Object System.Windows.Forms.RichTextBox)
$LOG.Height = 200
$LOG.Width = - $INTERVAL_SHORT + $WIDTH_FORM - $INTERVAL_SHORT
$LOG.Location = "$INTERVAL_SHORT, $($HEIGHT_FORM - $LOG.Height - $INTERVAL_SHORT)"
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True
$FORM.Controls.Add($LOG)


Set-Variable -Option Constant TAB_CONTROL (New-Object System.Windows.Forms.TabControl)
$TAB_CONTROL.Size = "$($LOG.Width + $INTERVAL_SHORT - 4), $($HEIGHT_FORM - $LOG.Height - $INTERVAL_SHORT - 4)"
$TAB_CONTROL.Location = "$INTERVAL_SHORT, $INTERVAL_SHORT"
$FORM.Controls.Add($TAB_CONTROL)


Set-Variable -Option Constant TAB_HOME (New-Object System.Windows.Forms.TabPage)
$TAB_HOME.Text = 'Home'
$TAB_HOME.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_HOME)

Set-Variable -Option Constant TAB_DOWNLOADS (New-Object System.Windows.Forms.TabPage)
$TAB_DOWNLOADS.Text = 'Downloads'
$TAB_DOWNLOADS.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_DOWNLOADS)

Set-Variable -Option Constant TAB_MAINTENANCE (New-Object System.Windows.Forms.TabPage)
$TAB_MAINTENANCE.Text = 'Maintenance'
$TAB_MAINTENANCE.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_MAINTENANCE)


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - General #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_General (New-Object System.Windows.Forms.GroupBox)
$GROUP_General.Text = 'General'
$GROUP_General.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 2
$GROUP_General.Width = $WIDTH_GROUP
$GROUP_General.Location = $INITIAL_LOCATION_GROUP
$TAB_HOME.Controls.Add($GROUP_General)


Function New-Button {
    Param(
        [System.Windows.Forms.GroupBox][Parameter(Position = 0)]$Box,
        [String][Parameter(Position = 1)]$Text,
        [String][Parameter(Position = 2)]$Location,
        [Switch]$Enabled,
        [Switch]$UAC = $False,
        [String]$ToolTip
        # [Function]$Click
    )

    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)

    $Button.Font = $BUTTON_FONT
    $Button.Height = $HEIGHT_BUTTON
    $Button.Width = $WIDTH_BUTTON

    $Button.Enabled = $Enabled
    $Button.Location = $Location

    $Button.Text = "$(if (-not $UAC -or $IS_ELEVATED) { $Text } else { "$Text *" })"

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($Button, $ToolTip) }

    $Button.Add_Click( { Start-Elevated } )

    $Box.Controls.Add($Button)

    Return $Button
}

$AdminButtonName = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Run as administrator'})"
$PREVIOUS_BUTTON = New-Button $GROUP_General $AdminButtonName $INITIAL_LOCATION_BUTTON -Enabled:(-not $IS_ELEVATED) -UAC -ToolTip 'Restart this utility with administrator privileges'

# Set-Variable -Option Constant BUTTON_Elevate (New-Object System.Windows.Forms.Button)
# (New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Elevate, 'Restart this utility with administrator privileges')
# $BUTTON_Elevate.Font = $BUTTON_FONT
# $BUTTON_Elevate.Height = $HEIGHT_BUTTON
# $BUTTON_Elevate.Width = $WIDTH_BUTTON
# $BUTTON_Elevate.Text = "$(if ($IS_ELEVATED) {'Running as administrator'} else {"Run as administrator$REQUIRES_ELEVATION"})"
# $BUTTON_Elevate.Location = $INITIAL_LOCATION_BUTTON
# $BUTTON_Elevate.Enabled = -not $IS_ELEVATED
# $BUTTON_Elevate.Add_Click( { Start-Elevated } )
# $GROUP_General.Controls.Add($BUTTON_Elevate)
# $PREVIOUS_BUTTON = $BUTTON_Elevate


Set-Variable -Option Constant BUTTON_SystemInfo (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_SystemInfo, 'Print system information to the log')
$BUTTON_SystemInfo.Font = $BUTTON_FONT
$BUTTON_SystemInfo.Height = $HEIGHT_BUTTON
$BUTTON_SystemInfo.Width = $WIDTH_BUTTON
$BUTTON_SystemInfo.Text = 'System information'
$BUTTON_SystemInfo.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_SystemInfo.Add_Click( { Out-SystemInfo } )
$GROUP_General.Controls.Add($BUTTON_SystemInfo)
$PREVIOUS_BUTTON = $BUTTON_Elevate


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Activators #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Activators (New-Object System.Windows.Forms.GroupBox)
$GROUP_Activators.Text = 'Activators'
$GROUP_Activators.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 2
$GROUP_Activators.Width = $WIDTH_GROUP
$GROUP_Activators.Location = $GROUP_General.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_HOME.Controls.Add($GROUP_Activators)


Set-Variable -Option Constant BUTTON_DownloadKMSAuto (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadKMSAuto, "Download KMSAuto Lite`nActivates Windows 7 - 11 and Office 2010 - 2021`n`n$TXT_AV_WARNING")
$BUTTON_DownloadKMSAuto.Font = $BUTTON_FONT
$BUTTON_DownloadKMSAuto.Height = $HEIGHT_BUTTON
$BUTTON_DownloadKMSAuto.Width = $WIDTH_BUTTON
$BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$REQUIRES_ELEVATION"
$BUTTON_DownloadKMSAuto.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartKMSAuto.Checked $URL_KMS_AUTO_LITE } )
$GROUP_Activators.Controls.Add($BUTTON_DownloadKMSAuto)
$PREVIOUS_BUTTON = $BUTTON_DownloadKMSAuto


Set-Variable -Option Constant CHECKBOX_StartKMSAuto (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartKMSAuto, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartKMSAuto.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartKMSAuto.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartKMSAuto.Size = $CHECKBOX_SIZE
$CHECKBOX_StartKMSAuto.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartKMSAuto.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartKMSAuto.Add_CheckStateChanged( { $BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CHECKBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Activators.Controls.Add($CHECKBOX_StartKMSAuto)
$PREVIOUS_BUTTON = $BUTTON_DownloadKMSAuto


Set-Variable -Option Constant BUTTON_DownloadAAct (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadAAct, "Download AAct`nActivates Windows 7 - 11 and Office 2010 - 2021`n`n$TXT_AV_WARNING")
$BUTTON_DownloadAAct.Font = $BUTTON_FONT
$BUTTON_DownloadAAct.Height = $HEIGHT_BUTTON
$BUTTON_DownloadAAct.Width = $WIDTH_BUTTON
$BUTTON_DownloadAAct.Text = "AAct (Win 7+, Office)$REQUIRES_ELEVATION"
$BUTTON_DownloadAAct.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_DownloadAAct.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked $URL_AACT } )
$GROUP_Activators.Controls.Add($BUTTON_DownloadAAct)
$PREVIOUS_BUTTON = $BUTTON_DownloadAAct


Set-Variable -Option Constant CHECKBOX_StartAAct (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartAAct, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartAAct.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartAAct.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartAAct.Size = $CHECKBOX_SIZE
$CHECKBOX_StartAAct.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartAAct.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartAAct.Add_CheckStateChanged( { $BUTTON_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CHECKBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Activators.Controls.Add($CHECKBOX_StartAAct)
$PREVIOUS_BUTTON = $BUTTON_DownloadAAct


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Windows Images #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_DownloadWindows (New-Object System.Windows.Forms.GroupBox)
$GROUP_DownloadWindows.Text = 'Windows Images'
$GROUP_DownloadWindows.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 4
$GROUP_DownloadWindows.Width = $WIDTH_GROUP
$GROUP_DownloadWindows.Location = $GROUP_Activators.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_HOME.Controls.Add($GROUP_DownloadWindows)


Set-Variable -Option Constant BUTTON_Windows11 (New-Object System.Windows.Forms.Button)
$BUTTON_Windows11.Font = $BUTTON_FONT
$BUTTON_Windows11.Height = $HEIGHT_BUTTON
$BUTTON_Windows11.Width = $WIDTH_BUTTON
$BUTTON_Windows11.Text = 'Windows 11 (v21H2)'
$BUTTON_Windows11.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_Windows11.Add_Click( { Open-InBrowser $URL_WINDOWS_11 } )
$GROUP_DownloadWindows.Controls.Add($BUTTON_Windows11)
$PREVIOUS_BUTTON = $BUTTON_Windows11


Set-Variable -Option Constant LABEL_Windows11 (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Windows11, 'Download Windows 11 (v21H2) RUS-ENG -26in1- HWID-act v2 (AIO) ISO image')
$LABEL_Windows11.Size = $CHECKBOX_SIZE
$LABEL_Windows11.Text = $TXT_OPENS_IN_BROWSER
$LABEL_Windows11.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_DownloadWindows.Controls.Add($LABEL_Windows11)


Set-Variable -Option Constant BUTTON_Windows10 (New-Object System.Windows.Forms.Button)
$BUTTON_Windows10.Font = $BUTTON_FONT
$BUTTON_Windows10.Height = $HEIGHT_BUTTON
$BUTTON_Windows10.Width = $WIDTH_BUTTON
$BUTTON_Windows10.Text = 'Windows 10 (v21H2)'
$BUTTON_Windows10.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_Windows10.Add_Click( { Open-InBrowser $URL_WINDOWS_10 } )
$GROUP_DownloadWindows.Controls.Add($BUTTON_Windows10)
$PREVIOUS_BUTTON = $BUTTON_Windows10


Set-Variable -Option Constant LABEL_Windows10 (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Windows10, 'Download Windows 10 (v21H1) RUS-ENG x86-x64 -28in1- HWID-act (AIO) ISO image')
$LABEL_Windows10.Size = $CHECKBOX_SIZE
$LABEL_Windows10.Text = $TXT_OPENS_IN_BROWSER
$LABEL_Windows10.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_DownloadWindows.Controls.Add($LABEL_Windows10)


Set-Variable -Option Constant BUTTON_Windows7 (New-Object System.Windows.Forms.Button)
$BUTTON_Windows7.Font = $BUTTON_FONT
$BUTTON_Windows7.Height = $HEIGHT_BUTTON
$BUTTON_Windows7.Width = $WIDTH_BUTTON
$BUTTON_Windows7.Text = 'Windows 7 SP1'
$BUTTON_Windows7.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_Windows7.Add_Click( { Open-InBrowser $URL_WINDOWS_7 } )
$GROUP_DownloadWindows.Controls.Add($BUTTON_Windows7)
$PREVIOUS_BUTTON = $BUTTON_Windows7


Set-Variable -Option Constant LABEL_Windows7 (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Windows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v10 (AIO) ISO image')
$LABEL_Windows7.Size = $CHECKBOX_SIZE
$LABEL_Windows7.Text = $TXT_OPENS_IN_BROWSER
$LABEL_Windows7.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_DownloadWindows.Controls.Add($LABEL_Windows7)


Set-Variable -Option Constant BUTTON_WindowsXP (New-Object System.Windows.Forms.Button)
$BUTTON_WindowsXP.Font = $BUTTON_FONT
$BUTTON_WindowsXP.Height = $HEIGHT_BUTTON
$BUTTON_WindowsXP.Width = $WIDTH_BUTTON
$BUTTON_WindowsXP.Text = 'Windows XP SP3 (ENG)'
$BUTTON_WindowsXP.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_WindowsXP.Add_Click( { Open-InBrowser $URL_WINDOWS_XP } )
$GROUP_DownloadWindows.Controls.Add($BUTTON_WindowsXP)
$PREVIOUS_BUTTON = $BUTTON_WindowsXP


Set-Variable -Option Constant LABEL_WindowsXP (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_WindowsXP, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')
$LABEL_WindowsXP.Size = $CHECKBOX_SIZE
$LABEL_WindowsXP.Text = $TXT_OPENS_IN_BROWSER
$LABEL_WindowsXP.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_DownloadWindows.Controls.Add($LABEL_WindowsXP)


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Tools #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Tools (New-Object System.Windows.Forms.GroupBox)
$GROUP_Tools.Text = 'Tools'
$GROUP_Tools.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 3
$GROUP_Tools.Width = $WIDTH_GROUP
$GROUP_Tools.Location = $GROUP_General.Location + "0, $($GROUP_General.Height + $INTERVAL_NORMAL)"
$TAB_HOME.Controls.Add($GROUP_Tools)


Set-Variable -Option Constant BUTTON_DownloadCCleaner (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadCCleaner, 'Download CCleaner installer')
$BUTTON_DownloadCCleaner.Font = $BUTTON_FONT
$BUTTON_DownloadCCleaner.Height = $HEIGHT_BUTTON
$BUTTON_DownloadCCleaner.Width = $WIDTH_BUTTON
$BUTTON_DownloadCCleaner.Text = "CCleaner$REQUIRES_ELEVATION"
$BUTTON_DownloadCCleaner.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_DownloadCCleaner.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartCCleaner.Checked $URL_CCLEANER } )
$GROUP_Tools.Controls.Add($BUTTON_DownloadCCleaner)
$PREVIOUS_BUTTON = $BUTTON_DownloadCCleaner


Set-Variable -Option Constant CHECKBOX_StartCCleaner (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartCCleaner, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartCCleaner.Size = $CHECKBOX_SIZE
$CHECKBOX_StartCCleaner.Checked = $True
$CHECKBOX_StartCCleaner.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartCCleaner.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartCCleaner.Add_CheckStateChanged( { $BUTTON_DownloadCCleaner.Text = "CCleaner$(if ($CHECKBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Tools.Controls.Add($CHECKBOX_StartCCleaner)
$PREVIOUS_BUTTON = $BUTTON_DownloadCCleaner


Set-Variable -Option Constant BUTTON_DownloadRufus (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadRufus, 'Download Rufus - a bootable USB creator')
$BUTTON_DownloadRufus.Font = $BUTTON_FONT
$BUTTON_DownloadRufus.Height = $HEIGHT_BUTTON
$BUTTON_DownloadRufus.Width = $WIDTH_BUTTON
$BUTTON_DownloadRufus.Text = "Rufus (bootable USB)$REQUIRES_ELEVATION"
$BUTTON_DownloadRufus.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' } )
$GROUP_Tools.Controls.Add($BUTTON_DownloadRufus)
$PREVIOUS_BUTTON = $BUTTON_DownloadRufus


Set-Variable -Option Constant CHECKBOX_StartRufus (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartRufus, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartRufus.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartRufus.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartRufus.Size = $CHECKBOX_SIZE
$CHECKBOX_StartRufus.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartRufus.Add_CheckStateChanged( { $BUTTON_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CHECKBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Tools.Controls.Add($CHECKBOX_StartRufus)
$PREVIOUS_BUTTON = $BUTTON_DownloadRufus


Set-Variable -Option Constant BUTTON_WindowsPE (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 10')
$BUTTON_WindowsPE.Font = $BUTTON_FONT
$BUTTON_WindowsPE.Height = $HEIGHT_BUTTON
$BUTTON_WindowsPE.Width = $WIDTH_BUTTON
$BUTTON_WindowsPE.Text = 'Windows PE (Live CD)'
$BUTTON_WindowsPE.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_WindowsPE.Add_Click( { Open-InBrowser $URL_WINDOWS_PE } )
$GROUP_Tools.Controls.Add($BUTTON_WindowsPE)
$PREVIOUS_BUTTON = $BUTTON_WindowsPE


Set-Variable -Option Constant LABEL_WindowsPE (New-Object System.Windows.Forms.Label)
$LABEL_WindowsPE.Size = $CHECKBOX_SIZE
$LABEL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LABEL_WindowsPE.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_Tools.Controls.Add($LABEL_WindowsPE)
$PREVIOUS_BUTTON = $BUTTON_WindowsPE


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Chrome Extension #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_ChromeExtensions (New-Object System.Windows.Forms.GroupBox)
$GROUP_ChromeExtensions.Text = 'Chrome Extensions'
$GROUP_ChromeExtensions.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 3
$GROUP_ChromeExtensions.Width = $WIDTH_GROUP
$GROUP_ChromeExtensions.Location = $GROUP_Activators.Location + "0, $($GROUP_Activators.Height + $INTERVAL_NORMAL)"
$TAB_HOME.Controls.Add($GROUP_ChromeExtensions)


Set-Variable -Option Constant BUTTON_HTTPSEverywhere (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_HTTPSEverywhere, 'Automatically use HTTPS security on many sites')
$BUTTON_HTTPSEverywhere.Enabled = Test-Path $PATH_CHROME_EXE
$BUTTON_HTTPSEverywhere.Font = $BUTTON_FONT
$BUTTON_HTTPSEverywhere.Height = $HEIGHT_BUTTON
$BUTTON_HTTPSEverywhere.Width = $WIDTH_BUTTON
$BUTTON_HTTPSEverywhere.Text = 'HTTPS Everywhere'
$BUTTON_HTTPSEverywhere.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_HTTPSEverywhere.Add_Click( { Start-Process $PATH_CHROME_EXE $URL_CHROME_HTTPS } )
$GROUP_ChromeExtensions.Controls.Add($BUTTON_HTTPSEverywhere)
$PREVIOUS_BUTTON = $BUTTON_HTTPSEverywhere


Set-Variable -Option Constant BUTTON_AdBlock (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_AdBlock, 'Block ads and pop-ups on websites')
$BUTTON_AdBlock.Enabled = Test-Path $PATH_CHROME_EXE
$BUTTON_AdBlock.Font = $BUTTON_FONT
$BUTTON_AdBlock.Height = $HEIGHT_BUTTON
$BUTTON_AdBlock.Width = $WIDTH_BUTTON
$BUTTON_AdBlock.Text = 'AdBlock'
$BUTTON_AdBlock.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_AdBlock.Add_Click( { Start-Process $PATH_CHROME_EXE $URL_CHROME_ADBLOCK } )
$GROUP_ChromeExtensions.Controls.Add($BUTTON_AdBlock)
$PREVIOUS_BUTTON = $BUTTON_AdBlock


Set-Variable -Option Constant BUTTON_YouTube_Dislike (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_YouTube_Dislike, 'Return YouTube Dislike restores the ability to see dislikes on YouTube')
$BUTTON_YouTube_Dislike.Enabled = Test-Path $PATH_CHROME_EXE
$BUTTON_YouTube_Dislike.Font = $BUTTON_FONT
$BUTTON_YouTube_Dislike.Height = $HEIGHT_BUTTON
$BUTTON_YouTube_Dislike.Width = $WIDTH_BUTTON
$BUTTON_YouTube_Dislike.Text = 'Return YouTube Dislike'
$BUTTON_YouTube_Dislike.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_YouTube_Dislike.Add_Click( { Start-Process $PATH_CHROME_EXE $URL_CHROME_YOUTUBE } )
$GROUP_ChromeExtensions.Controls.Add($BUTTON_YouTube_Dislike)
$PREVIOUS_BUTTON = $BUTTON_YouTube_Dislike


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Ninite (New-Object System.Windows.Forms.GroupBox)
$GROUP_Ninite.Text = 'Ninite'
$GROUP_Ninite.Height = $INTERVAL_GROUP_TOP + $INTERVAL_CHECKBOX_SHORT * 6 + $INTERVAL_SHORT + $INTERVAL_BUTTON_LONG * 2
$GROUP_Ninite.Width = $WIDTH_GROUP
$GROUP_Ninite.Location = $INITIAL_LOCATION_GROUP
$TAB_DOWNLOADS.Controls.Add($GROUP_Ninite)


Set-Variable -Option Constant CHECKBOX_Chrome (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_Chrome.Checked = $True
$CHECKBOX_Chrome.Size = $CHECKBOX_SIZE
$CHECKBOX_Chrome.Text = 'Google Chrome'
$CHECKBOX_Chrome.Name = 'chrome'
$CHECKBOX_Chrome.Location = $INITIAL_LOCATION_BUTTON
$CHECKBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_Chrome)
$PREVIOUS_BUTTON = $CHECKBOX_Chrome


Set-Variable -Option Constant CHECKBOX_7zip (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_7zip.Checked = $True
$CHECKBOX_7zip.Size = $CHECKBOX_SIZE
$CHECKBOX_7zip.Text = '7-Zip'
$CHECKBOX_7zip.Name = '7zip'
$CHECKBOX_7zip.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_7zip)
$PREVIOUS_BUTTON = $CHECKBOX_7zip


Set-Variable -Option Constant CHECKBOX_VLC (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_VLC.Checked = $True
$CHECKBOX_VLC.Size = $CHECKBOX_SIZE
$CHECKBOX_VLC.Text = 'VLC'
$CHECKBOX_VLC.Name = 'vlc'
$CHECKBOX_VLC.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_VLC)
$PREVIOUS_BUTTON = $CHECKBOX_VLC


Set-Variable -Option Constant CHECKBOX_TeamViewer (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_TeamViewer.Checked = $True
$CHECKBOX_TeamViewer.Size = $CHECKBOX_SIZE
$CHECKBOX_TeamViewer.Text = 'TeamViewer'
$CHECKBOX_TeamViewer.Name = 'teamviewer15'
$CHECKBOX_TeamViewer.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_TeamViewer)
$PREVIOUS_BUTTON = $CHECKBOX_TeamViewer


Set-Variable -Option Constant CHECKBOX_qBittorrent (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_qBittorrent.Size = $CHECKBOX_SIZE
$CHECKBOX_qBittorrent.Text = 'qBittorrent'
$CHECKBOX_qBittorrent.Name = 'qbittorrent'
$CHECKBOX_qBittorrent.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_qBittorrent)
$PREVIOUS_BUTTON = $CHECKBOX_qBittorrent


Set-Variable -Option Constant CHECKBOX_Malwarebytes (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_Malwarebytes.Size = $CHECKBOX_SIZE
$CHECKBOX_Malwarebytes.Text = 'Malwarebytes'
$CHECKBOX_Malwarebytes.Name = 'malwarebytes'
$CHECKBOX_Malwarebytes.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX
$CHECKBOX_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )
$GROUP_Ninite.Controls.Add($CHECKBOX_Malwarebytes)
$PREVIOUS_BUTTON = $CHECKBOX_Malwarebytes


Set-Variable -Option Constant BUTTON_DownloadNinite (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadNinite, 'Download Ninite universal installer for selected applications')
$BUTTON_DownloadNinite.Font = $BUTTON_FONT
$BUTTON_DownloadNinite.Height = $HEIGHT_BUTTON
$BUTTON_DownloadNinite.Width = $WIDTH_BUTTON
$BUTTON_DownloadNinite.Text = "Download selected$REQUIRES_ELEVATION"
$BUTTON_DownloadNinite.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_SHORT
$BUTTON_DownloadNinite.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) } )
$GROUP_Ninite.Controls.Add($BUTTON_DownloadNinite)
$PREVIOUS_BUTTON = $BUTTON_DownloadNinite


Set-Variable -Option Constant CHECKBOX_StartNinite (New-Object System.Windows.Forms.CheckBox)
$CHECKBOX_StartNinite.Checked = $True
$CHECKBOX_StartNinite.Size = $CHECKBOX_SIZE
$CHECKBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartNinite.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartNinite.Add_CheckStateChanged( { $BUTTON_DownloadNinite.Text = "Download selected$(if ($CHECKBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Ninite.Controls.Add($CHECKBOX_StartNinite)
$PREVIOUS_BUTTON = $CHECKBOX_StartNinite


Set-Variable -Option Constant BUTTON_OpenNiniteInBrowser (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
$BUTTON_OpenNiniteInBrowser.Font = $BUTTON_FONT
$BUTTON_OpenNiniteInBrowser.Height = $HEIGHT_BUTTON
$BUTTON_OpenNiniteInBrowser.Width = $WIDTH_BUTTON
$BUTTON_OpenNiniteInBrowser.Text = 'View other'
$BUTTON_OpenNiniteInBrowser.Location = $PREVIOUS_BUTTON.Location - $SHIFT_CHECKBOX_EXECUTE + $SHIFT_BUTTON_LONG
$BUTTON_OpenNiniteInBrowser.Add_Click( { Open-InBrowser "ninite.com/?select=$(Set-NiniteQuery)" } )
$GROUP_Ninite.Controls.Add($BUTTON_OpenNiniteInBrowser)
$PREVIOUS_BUTTON = $BUTTON_OpenNiniteInBrowser


Set-Variable -Option Constant LABEL_OpenNiniteInBrowser (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartNinite, $TXT_TIP_START_AFTER_DOWNLOAD)
$LABEL_OpenNiniteInBrowser.Size = $CHECKBOX_SIZE
$LABEL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LABEL_OpenNiniteInBrowser.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_Ninite.Controls.Add($LABEL_OpenNiniteInBrowser)
$PREVIOUS_BUTTON = $LABEL_OpenNiniteInBrowser


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Essentials #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Essentials (New-Object System.Windows.Forms.GroupBox)
$GROUP_Essentials.Text = 'Essentials'
$GROUP_Essentials.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 3 + $INTERVAL_CHECKBOX_SHORT - $INTERVAL_SHORT
$GROUP_Essentials.Width = $WIDTH_GROUP
$GROUP_Essentials.Location = $GROUP_Ninite.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_DOWNLOADS.Controls.Add($GROUP_Essentials)


Set-Variable -Option Constant BUTTON_DownloadSDI (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadSDI, 'Download Snappy Driver Installer')
$BUTTON_DownloadSDI.Font = $BUTTON_FONT
$BUTTON_DownloadSDI.Height = $HEIGHT_BUTTON
$BUTTON_DownloadSDI.Width = $WIDTH_BUTTON
$BUTTON_DownloadSDI.Text = "Snappy Driver Installer$REQUIRES_ELEVATION"
$BUTTON_DownloadSDI.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_DownloadSDI.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked $URL_SDI } )
$GROUP_Essentials.Controls.Add($BUTTON_DownloadSDI)
$PREVIOUS_BUTTON = $BUTTON_DownloadSDI


Set-Variable -Option Constant CHECKBOX_StartSDI (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartSDI, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartSDI.Checked = $True
$CHECKBOX_StartSDI.Size = $CHECKBOX_SIZE
$CHECKBOX_StartSDI.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartSDI.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartSDI.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Essentials.Controls.Add($CHECKBOX_StartSDI)


Set-Variable -Option Constant BUTTON_DownloadUnchecky (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadUnchecky, "Download Unchecky installer`n$TXT_UNCHECKY_INFO")
$BUTTON_DownloadUnchecky.Font = $BUTTON_FONT
$BUTTON_DownloadUnchecky.Height = $HEIGHT_BUTTON
$BUTTON_DownloadUnchecky.Width = $WIDTH_BUTTON
$BUTTON_DownloadUnchecky.Text = "Unchecky$REQUIRES_ELEVATION"
$BUTTON_DownloadUnchecky.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_DownloadUnchecky.Add_Click( {
        Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
        Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked $URL_UNCHECKY -Params:$Params -SilentInstall:$CHECKBOX_SilentlyInstallUnchecky.Checked
    } )
$GROUP_Essentials.Controls.Add($BUTTON_DownloadUnchecky)
$PREVIOUS_BUTTON = $BUTTON_DownloadUnchecky


Set-Variable -Option Constant CHECKBOX_StartUnchecky (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartUnchecky, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartUnchecky.Checked = $True
$CHECKBOX_StartUnchecky.Size = $CHECKBOX_SIZE
$CHECKBOX_StartUnchecky.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartUnchecky.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( { $BUTTON_DownloadUnchecky.Text = "Unchecky$(if ($CHECKBOX_StartUnchecky.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Essentials.Controls.Add($CHECKBOX_StartUnchecky)
$PREVIOUS_BUTTON = $CHECKBOX_StartUnchecky


Set-Variable -Option Constant CHECKBOX_SilentlyInstallUnchecky (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_SilentlyInstallUnchecky, 'Perform silent installation with no prompts')
$CHECKBOX_SilentlyInstallUnchecky.Checked = $True
$CHECKBOX_SilentlyInstallUnchecky.Size = $CHECKBOX_SIZE
$CHECKBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CHECKBOX_SilentlyInstallUnchecky.Location = $PREVIOUS_BUTTON.Location + "0, $HEIGHT_CHECKBOX"
$GROUP_Essentials.Controls.Add($CHECKBOX_SilentlyInstallUnchecky)


Set-Variable -Option Constant BUTTON_DownloadOffice (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadOffice, "Download Microsoft Office 2013 - 2021 C2R installer and activator`n`n$TXT_AV_WARNING")
$BUTTON_DownloadOffice.Font = $BUTTON_FONT
$BUTTON_DownloadOffice.Height = $HEIGHT_BUTTON
$BUTTON_DownloadOffice.Width = $WIDTH_BUTTON
$BUTTON_DownloadOffice.Text = "Office 2013 - 2021$REQUIRES_ELEVATION"
$BUTTON_DownloadOffice.Location = $BUTTON_DownloadUnchecky.Location + $SHIFT_BUTTON_SHORT + $SHIFT_BUTTON_NORMAL
$BUTTON_DownloadOffice.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked $URL_OFFICE } )
$GROUP_Essentials.Controls.Add($BUTTON_DownloadOffice)
$PREVIOUS_BUTTON = $BUTTON_DownloadOffice


Set-Variable -Option Constant CHECKBOX_StartOffice (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartOffice, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartOffice.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartOffice.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartOffice.Location = $PREVIOUS_BUTTON.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartOffice.Size = $CHECKBOX_SIZE
$CHECKBOX_StartOffice.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartOffice.Add_CheckStateChanged( { $BUTTON_DownloadOffice.Text = "Office 2013 - 2021$(if ($CHECKBOX_StartOffice.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Essentials.Controls.Add($CHECKBOX_StartOffice)


$CHECKBOX_StartUnchecky.Add_CheckStateChanged( { $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Updates #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Updates (New-Object System.Windows.Forms.GroupBox)
$GROUP_Updates.Text = 'Updates'
$GROUP_Updates.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 3
$GROUP_Updates.Width = $WIDTH_GROUP
$GROUP_Updates.Location = $GROUP_Essentials.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_DOWNLOADS.Controls.Add($GROUP_Updates)


Set-Variable -Option Constant BUTTON_UpdateStoreApps (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_UpdateStoreApps, 'Update Microsoft Store apps')
$BUTTON_UpdateStoreApps.Enabled = $OS_VERSION -gt 7
$BUTTON_UpdateStoreApps.Font = $BUTTON_FONT
$BUTTON_UpdateStoreApps.Height = $HEIGHT_BUTTON
$BUTTON_UpdateStoreApps.Width = $WIDTH_BUTTON
$BUTTON_UpdateStoreApps.Text = "Update Store apps$REQUIRES_ELEVATION"
$BUTTON_UpdateStoreApps.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_UpdateStoreApps.Add_Click( { Start-StoreAppUpdate } )
$GROUP_Updates.Controls.Add($BUTTON_UpdateStoreApps)
$PREVIOUS_BUTTON = $BUTTON_UpdateStoreApps


Set-Variable -Option Constant BUTTON_UpdateOffice (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_UpdateOffice, 'Update Microsoft Office (for C2R installations only)')
$BUTTON_UpdateOffice.Enabled = $OFFICE_INSTALL_TYPE -eq 'C2R'
$BUTTON_UpdateOffice.Font = $BUTTON_FONT
$BUTTON_UpdateOffice.Height = $HEIGHT_BUTTON
$BUTTON_UpdateOffice.Width = $WIDTH_BUTTON
$BUTTON_UpdateOffice.Text = "Update Microsoft Office"
$BUTTON_UpdateOffice.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_UpdateOffice.Add_Click( { Start-OfficeUpdate } )
$GROUP_Updates.Controls.Add($BUTTON_UpdateOffice)
$PREVIOUS_BUTTON = $BUTTON_UpdateOffice


Set-Variable -Option Constant BUTTON_WindowsUpdate (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_WindowsUpdate, 'Check for Windows updates, download and install if available')
$BUTTON_WindowsUpdate.Font = $BUTTON_FONT
$BUTTON_WindowsUpdate.Height = $HEIGHT_BUTTON
$BUTTON_WindowsUpdate.Width = $WIDTH_BUTTON
$BUTTON_WindowsUpdate.Text = 'Start Windows Update'
$BUTTON_WindowsUpdate.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_WindowsUpdate.Add_Click( { Start-WindowsUpdate } )
$GROUP_Updates.Controls.Add($BUTTON_WindowsUpdate)
$PREVIOUS_BUTTON = $BUTTON_WindowsUpdate


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Hardware Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Hardware (New-Object System.Windows.Forms.GroupBox)
$GROUP_Hardware.Text = 'Hardware Diagnostics'
$GROUP_Hardware.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 2 + $INTERVAL_BUTTON_NORMAL
$GROUP_Hardware.Width = $WIDTH_GROUP
$GROUP_Hardware.Location = $INITIAL_LOCATION_GROUP
$TAB_MAINTENANCE.Controls.Add($GROUP_Hardware)


Set-Variable -Option Constant BUTTON_CheckDisk (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CheckDisk, 'Start (C:) disk health check')
$BUTTON_CheckDisk.Font = $BUTTON_FONT
$BUTTON_CheckDisk.Height = $HEIGHT_BUTTON
$BUTTON_CheckDisk.Width = $WIDTH_BUTTON
$BUTTON_CheckDisk.Text = "Check (C:) disk health$REQUIRES_ELEVATION"
$BUTTON_CheckDisk.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_CheckDisk.Add_Click( { Start-DiskCheck $RADIO_FullDiskCheck.Checked } )
$GROUP_Hardware.Controls.Add($BUTTON_CheckDisk)


Set-Variable -Option Constant RADIO_QuickDiskCheck (New-Object System.Windows.Forms.RadioButton)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RADIO_QuickDiskCheck, 'Perform a quick disk scan')
$RADIO_QuickDiskCheck.Checked = $True
$RADIO_QuickDiskCheck.Text = 'Quick scan'
$RADIO_QuickDiskCheck.Location = $BUTTON_CheckDisk.Location + "10, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
$RADIO_QuickDiskCheck.Size = "80, 20"
$GROUP_Hardware.Controls.Add($RADIO_QuickDiskCheck)


Set-Variable -Option Constant RADIO_FullDiskCheck (New-Object System.Windows.Forms.RadioButton)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RADIO_FullDiskCheck, 'Schedule a full disk scan on next restart')
$RADIO_FullDiskCheck.Text = 'Full scan'
$RADIO_FullDiskCheck.Location = $RADIO_QuickDiskCheck.Location + "80, 0"
$RADIO_FullDiskCheck.Size = "80, 20"
$GROUP_Hardware.Controls.Add($RADIO_FullDiskCheck)


Set-Variable -Option Constant BUTTON_DownloadVictoria (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DownloadVictoria, 'Download Victoria HDD scanner')
$BUTTON_DownloadVictoria.Font = $BUTTON_FONT
$BUTTON_DownloadVictoria.Height = $HEIGHT_BUTTON
$BUTTON_DownloadVictoria.Width = $WIDTH_BUTTON
$BUTTON_DownloadVictoria.Text = "Victoria (HDD scan)$REQUIRES_ELEVATION"
$BUTTON_DownloadVictoria.Location = $BUTTON_CheckDisk.Location + $SHIFT_BUTTON_LONG
$BUTTON_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA } )
$GROUP_Hardware.Controls.Add($BUTTON_DownloadVictoria)


Set-Variable -Option Constant CHECKBOX_StartVictoria (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_StartVictoria, $TXT_TIP_START_AFTER_DOWNLOAD)
$CHECKBOX_StartVictoria.Enabled = $PS_VERSION -gt 2
$CHECKBOX_StartVictoria.Checked = $PS_VERSION -gt 2
$CHECKBOX_StartVictoria.Size = $CHECKBOX_SIZE
$CHECKBOX_StartVictoria.Text = $TXT_START_AFTER_DOWNLOAD
$CHECKBOX_StartVictoria.Location = $BUTTON_DownloadVictoria.Location + $SHIFT_CHECKBOX_EXECUTE
$CHECKBOX_StartVictoria.Add_CheckStateChanged( { $BUTTON_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CHECKBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )
$GROUP_Hardware.Controls.Add($CHECKBOX_StartVictoria)


Set-Variable -Option Constant BUTTON_CheckRAM (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CheckRAM, 'Start RAM checking utility')
$BUTTON_CheckRAM.Font = $BUTTON_FONT
$BUTTON_CheckRAM.Height = $HEIGHT_BUTTON
$BUTTON_CheckRAM.Width = $WIDTH_BUTTON
$BUTTON_CheckRAM.Text = 'RAM checking utility'
$BUTTON_CheckRAM.Location = $BUTTON_DownloadVictoria.Location + $SHIFT_BUTTON_LONG
$BUTTON_CheckRAM.Add_Click( { Start-MemoryCheckTool } )
$GROUP_Hardware.Controls.Add($BUTTON_CheckRAM)


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Software Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Software (New-Object System.Windows.Forms.GroupBox)
$GROUP_Software.Text = 'Software Diagnostics'
$GROUP_Software.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 4
$GROUP_Software.Width = $WIDTH_GROUP
$GROUP_Software.Location = $GROUP_Hardware.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_MAINTENANCE.Controls.Add($GROUP_Software)


Set-Variable -Option Constant BUTTON_CheckWindowsHealth (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CheckWindowsHealth, 'Check Windows health')
$BUTTON_CheckWindowsHealth.Font = $BUTTON_FONT
$BUTTON_CheckWindowsHealth.Height = $HEIGHT_BUTTON
$BUTTON_CheckWindowsHealth.Width = $WIDTH_BUTTON
$BUTTON_CheckWindowsHealth.Text = "Check Windows health$REQUIRES_ELEVATION"
$BUTTON_CheckWindowsHealth.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_CheckWindowsHealth.Add_Click( { Test-WindowsHealth } )
$GROUP_Software.Controls.Add($BUTTON_CheckWindowsHealth)


Set-Variable -Option Constant BUTTON_CheckSystemFiles (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CheckSystemFiles, 'Check system file integrity')
$BUTTON_CheckSystemFiles.Font = $BUTTON_FONT
$BUTTON_CheckSystemFiles.Height = $HEIGHT_BUTTON
$BUTTON_CheckSystemFiles.Width = $WIDTH_BUTTON
$BUTTON_CheckSystemFiles.Text = "Check system files$REQUIRES_ELEVATION"
$BUTTON_CheckSystemFiles.Location = $BUTTON_CheckWindowsHealth.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_CheckSystemFiles.Add_Click( { Repair-SystemFiles } )
$GROUP_Software.Controls.Add($BUTTON_CheckSystemFiles)


Set-Variable -Option Constant BUTTON_StartSecurityScan (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_StartSecurityScan, 'Start security scan')
$BUTTON_StartSecurityScan.Enabled = Test-Path $PATH_DEFENDER_EXE
$BUTTON_StartSecurityScan.Font = $BUTTON_FONT
$BUTTON_StartSecurityScan.Height = $HEIGHT_BUTTON
$BUTTON_StartSecurityScan.Width = $WIDTH_BUTTON
$BUTTON_StartSecurityScan.Text = 'Perform a security scan'
$BUTTON_StartSecurityScan.Location = $BUTTON_CheckSystemFiles.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_StartSecurityScan.Add_Click( { Start-SecurityScan } )
$GROUP_Software.Controls.Add($BUTTON_StartSecurityScan)


Set-Variable -Option Constant BUTTON_StartMalwareScan (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_StartMalwareScan, 'Start malware scan')
$BUTTON_StartMalwareScan.Enabled = Test-Path $PATH_DEFENDER_EXE
$BUTTON_StartMalwareScan.Font = $BUTTON_FONT
$BUTTON_StartMalwareScan.Height = $HEIGHT_BUTTON
$BUTTON_StartMalwareScan.Width = $WIDTH_BUTTON
$BUTTON_StartMalwareScan.Text = "Perform a malware scan$REQUIRES_ELEVATION"
$BUTTON_StartMalwareScan.Location = $BUTTON_StartSecurityScan.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_StartMalwareScan.Add_Click( { Start-MalwareScan } )
$GROUP_Software.Controls.Add($BUTTON_StartMalwareScan)


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Cleanup (New-Object System.Windows.Forms.GroupBox)
$GROUP_Cleanup.Text = 'Cleanup'
$GROUP_Cleanup.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 2
$GROUP_Cleanup.Width = $WIDTH_GROUP
$GROUP_Cleanup.Location = $GROUP_Software.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_MAINTENANCE.Controls.Add($GROUP_Cleanup)


Set-Variable -Option Constant BUTTON_FileCleanup (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_FileCleanup, 'Remove temporary files, some log files and empty directories, and some other unnecessary files')
$BUTTON_FileCleanup.Font = $BUTTON_FONT
$BUTTON_FileCleanup.Height = $HEIGHT_BUTTON
$BUTTON_FileCleanup.Width = $WIDTH_BUTTON
$BUTTON_FileCleanup.Text = "File cleanup$REQUIRES_ELEVATION"
$BUTTON_FileCleanup.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_FileCleanup.Add_Click( { Start-FileCleanup } )
$GROUP_Cleanup.Controls.Add($BUTTON_FileCleanup)


Set-Variable -Option Constant BUTTON_DiskCleanup (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DiskCleanup, 'Start Windows built-in disk cleanup utility')
$BUTTON_DiskCleanup.Font = $BUTTON_FONT
$BUTTON_DiskCleanup.Height = $HEIGHT_BUTTON
$BUTTON_DiskCleanup.Width = $WIDTH_BUTTON
$BUTTON_DiskCleanup.Text = 'Start disk cleanup'
$BUTTON_DiskCleanup.Location = $BUTTON_FileCleanup.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_DiskCleanup.Add_Click( { Start-DiskCleanup } )
$GROUP_Cleanup.Controls.Add($BUTTON_DiskCleanup)


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Optimization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GROUP_Optimization (New-Object System.Windows.Forms.GroupBox)
$GROUP_Optimization.Text = 'Optimization'
$GROUP_Optimization.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL + $INTERVAL_BUTTON_LONG + $INTERVAL_CHECKBOX_SHORT - $INTERVAL_SHORT
$GROUP_Optimization.Width = $WIDTH_GROUP
$GROUP_Optimization.Location = $GROUP_Cleanup.Location + "0, $($GROUP_Cleanup.Height + $INTERVAL_NORMAL)"
$TAB_MAINTENANCE.Controls.Add($GROUP_Optimization)


Set-Variable -Option Constant BUTTON_CloudFlareDNS (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CloudFlareDNS, 'Set DNS server to CouldFlare DNS')
$BUTTON_CloudFlareDNS.Font = $BUTTON_FONT
$BUTTON_CloudFlareDNS.Height = $HEIGHT_BUTTON
$BUTTON_CloudFlareDNS.Width = $WIDTH_BUTTON
$BUTTON_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BUTTON_CloudFlareDNS.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_CloudFlareDNS.Add_Click( { Set-CloudFlareDNS } )
$GROUP_Optimization.Controls.Add($BUTTON_CloudFlareDNS)


Set-Variable -Option Constant CHECKBOX_CloudFlareAntiMalware (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_CloudFlareAntiMalware, 'Use CloudFlare DNS variation with malware protection (1.1.1.2)')
$CHECKBOX_CloudFlareAntiMalware.Size = $CHECKBOX_SIZE
$CHECKBOX_CloudFlareAntiMalware.Text = 'Malware protection'
$CHECKBOX_CloudFlareAntiMalware.Checked = $True
$CHECKBOX_CloudFlareAntiMalware.Location = $BUTTON_CloudFlareDNS.Location + "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked } )
$GROUP_Optimization.Controls.Add($CHECKBOX_CloudFlareAntiMalware)


Set-Variable -Option Constant CHECKBOX_CloudFlareFamilyFriendly (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_CloudFlareFamilyFriendly, 'Use CloudFlare DNS variation with malware protection and adult content filtering (1.1.1.3)')
$CHECKBOX_CloudFlareFamilyFriendly.Size = $CHECKBOX_SIZE
$CHECKBOX_CloudFlareFamilyFriendly.Text = 'Adult content filtering'
$CHECKBOX_CloudFlareFamilyFriendly.Location = $CHECKBOX_CloudFlareAntiMalware.Location + "0, $HEIGHT_CHECKBOX"
$GROUP_Optimization.Controls.Add($CHECKBOX_CloudFlareFamilyFriendly)


Set-Variable -Option Constant BUTTON_OptimizeDrive (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$BUTTON_OptimizeDrive.Font = $BUTTON_FONT
$BUTTON_OptimizeDrive.Height = $HEIGHT_BUTTON
$BUTTON_OptimizeDrive.Width = $WIDTH_BUTTON
$BUTTON_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BUTTON_OptimizeDrive.Location = $BUTTON_CloudFlareDNS.Location + $SHIFT_BUTTON_SHORT + $SHIFT_BUTTON_NORMAL
$BUTTON_OptimizeDrive.Add_Click( { Start-DriveOptimization } )
$GROUP_Optimization.Controls.Add($BUTTON_OptimizeDrive)


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Startup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Initialize-Startup {
    $FORM.Activate()
    Write-Log "[$((Get-Date).ToString())] Initializing..."

    if ($IS_ELEVATED) {
        Set-Variable -Option Constant IE_Registry_Key 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'
        if (!(Test-Path $IE_Registry_Key)) { New-Item $IE_Registry_Key -Force | Out-Null }
        Set-ItemProperty -Path $IE_Registry_Key -Name "DisableFirstRunCustomize" -Value 1
    }

    Set-Variable -Option Constant -Scope Script CURRENT_DIR $(Split-Path $MyInvocation.ScriptName)

    if ($PS_VERSION -lt 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, while PowerShell 2 and newer are supported. Some features might not work correctly." }
    elseif ($PS_VERSION -eq 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, some features are not supported and are disabled." }

    if ($OS_VERSION -lt 7) { Add-Log $WRN "Windows $OS_VERSION detected, while Windows 7 and newer are supported. Some features might not work correctly." }
    elseif ($OS_VERSION -lt 8) { Add-Log $WRN "Windows $OS_VERSION detected, some features are not supported and are disabled." }

    if ($PS_VERSION -gt 2) {
        try { [Net.ServicePointManager]::SecurityProtocol = 'Tls12' }
        catch [Exception] { Add-Log $WRN "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)" }

        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
        }
        catch [Exception] {
            Add-Log $WRN "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
        }
    }

    Get-CurrentVersion

    if (-not (Test-Path "$PATH_PROGRAM_FILES_86\Unchecky\unchecky.exe")) {
        Add-Log $WRN 'Unchecky is not installed.'
        Add-Log $INF 'It is highly recommended to install Unchecky (see Downloads -> Essentials -> Unchecky).'
        Add-Log $INF "$TXT_UNCHECKY_INFO."
    }

    if ($OFFICE_INSTALL_TYPE -eq 'MSI' -and $OFFICE_VERSION -ge 15) {
        Add-Log $WRN 'MSI installation of Microsoft Office is detected.'
        Add-Log $INF 'It is highly recommended to install Click-To-Run (C2R) version instead'
        Add-Log $INF '  (see Downloads -> Essentials -> Office 2013 - 2021).'
    }

    Set-Variable -Option Constant NetworkAdapter (Get-NetworkAdapter)
    if ($NetworkAdapter) {
        Set-Variable -Option Constant CurrentDnsServer $NetworkAdapter.DNSServerSearchOrder
        if (-not ($CurrentDnsServer -Match '1.1.1.*' -and $CurrentDnsServer -Match '1.0.0.*')) {
            Add-Log $WRN 'System is not configured to use CouldFlare DNS.'
            Add-Log $INF 'It is recommended to use CouldFlare DNS for faster domain name resolution and improved'
            Add-Log $INF '  privacy online (see Maintenance -> Optimization -> Setup CouldFlare DNS).'
        }
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Logger #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1)]$Message = $(Write-Host -NoNewline "`n$($MyInvocation.MyCommand.Name): Log message missing")
    )
    if (-not $Message) { Return }

    $LOG.SelectionStart = $LOG.TextLength

    Switch ($Level) {
        $WRN { $LOG.SelectionColor = 'blue' }
        $ERR { $LOG.SelectionColor = 'red' }
        Default { $LOG.SelectionColor = 'black' }
    }

    Write-Log "`n[$((Get-Date).ToString())] $Message"
}


Function Write-Log {
    Param([String]$Text = $(Write-Host -NoNewline "`n$($MyInvocation.MyCommand.Name): Log message missing"))
    if (-not $Text) { Return }

    Write-Host -NoNewline $Text
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret()
}


Function Out-Status {
    Param([String]$Status = $(Write-Host -NoNewline "`n$($MyInvocation.MyCommand.Name): No status specified"))
    if (-not $Status) { Return }

    Write-Log ' '

    Set-Variable -Option Constant LogDefaultFont $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)

    Write-Log $Status

    $LOG.SelectionFont = $LogDefaultFont
    $LOG.SelectionColor = 'black'
}


Function Out-Success { Out-Status 'Done' }

Function Out-Failure { Out-Status 'Failed' }


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Self-Update #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Get-CurrentVersion {
    if ($PS_VERSION -le 2) { Add-Log $WRN "Automatic self-update requires PowerShell 3 or higher (currently running on PowerShell $PS_VERSION)"; Return }

    Add-Log $INF 'Checking for updates...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) { Add-Log $ERR "Failed to check for updates: $IsNotConnected"; Return }

    $ProgressPreference = 'SilentlyContinue'
    try {
        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest 'https://bit.ly/qiiwexc_version').ToString())
        $ProgressPreference = 'Continue'
    }
    catch [Exception] {
        $ProgressPreference = 'Continue'
        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
        Return
    }

    if ($LatestVersion -gt $VERSION) { Add-Log $WRN "Newer version available: v$LatestVersion"; Get-Update }
    else { Out-Status 'No updates available' }
}


Function Get-Update {
    Set-Variable -Option Constant DownloadURL 'https://bit.ly/qiiwexc_ps1'
    Set-Variable -Option Constant TargetFile $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) { Add-Log $ERR "Failed to download update: $IsNotConnected"; Return }

    try { Invoke-WebRequest $DownloadURL -OutFile $TargetFile }
    catch [Exception] { Add-Log $ERR "Failed to download update: $($_.Exception.Message)"; Return }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try { Start-ExternalProcess "PowerShell '$TargetFile' '-HideConsole'" }
    catch [Exception] { Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"; Return }

    Exit-Script
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Common #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Get-FreeDiskSpace { Return ($SYSTEM_PARTITION.FreeSpace / $SYSTEM_PARTITION.Size) }

Function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }

Function Get-ConnectionStatus { if (-not (Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

Function Reset-StateOnExit { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_TEMP_DIR; $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

Function Exit-Script { Reset-StateOnExit; $FORM.Close() }


Function Open-InBrowser {
    Param([String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"))
    if (-not $URL) { Return }

    Set-Variable -Option Constant UrlToOpen $(if ($URL -like 'http*') { $URL } else { 'https://' + $URL })
    Add-Log $INF "Opening URL in the default browser: $UrlToOpen"

    try { [System.Diagnostics.Process]::Start($UrlToOpen) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


Function Start-ExternalProcess {
    Param(
        [String[]][Parameter(Position = 0)]$Commands = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No commands specified"),
        [String][Parameter(Position = 1)]$Title,
        [Switch]$Elevated,
        [Switch]$Wait,
        [Switch]$Hidden
    )
    if (-not $Commands) { Return }

    if ($Title) { $Commands = , "(Get-Host).UI.RawUI.WindowTitle = '$Title'" + $Commands }
    Set-Variable -Option Constant FullCommand $([String]$($Commands | ForEach-Object { "$_;" }))

    Start-Process 'PowerShell' "-Command $FullCommand" -Wait:$Wait -Verb:$(if ($Elevated) { 'RunAs' } else { 'Open' }) -WindowStyle:$(if ($Hidden) { 'Hidden' } else { 'Normal' })
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download Extract Execute #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DownloadExtractExecute {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"),
        [String][Parameter(Position = 1)]$FileName,
        [String][Parameter(Position = 2)]$Params,
        [Switch]$AVWarning,
        [Switch]$Execute,
        [Switch]$SilentInstall
    )
    if (-not $URL) { Return }

    if ($AVWarning -and -not $AVWarningShown) {
        Add-Log $WRN $TXT_AV_WARNING
        Add-Log $WRN 'Click the button again to continue'
        Set-Variable -Option Constant -Scope Script AVWarningShown $True
        Return
    }

    if ($PS_VERSION -le 2 -and ($URL -Match 'github.com/*' -or $URL -Match 'github.io/*')) { Open-InBrowser $URL }
    else {
        Set-Variable -Option Constant UrlEnding $URL.Substring($URL.Length - 4)
        Set-Variable -Option Constant IsZip ($UrlEnding -eq '.zip')
        Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp:$($Execute -or $IsZip))

        if ($DownloadedFile) {
            Set-Variable -Option Constant Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -Execute:$Execute } else { $DownloadedFile })
            if ($Execute) { Start-File $Executable $Params -SilentInstall:$SilentInstall }
        }
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download File #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Download {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No download URL specified"),
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )
    if (-not $URL) { Return }

    Set-Variable -Option Constant DownloadURL $(if ($URL -Like 'http*') { $URL } else { 'https://' + $URL })
    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { (Split-Path -Leaf $DownloadURL) -Replace '_zip', '.zip' })
    Set-Variable -Option Constant TempPath "$PATH_TEMP_DIR\$FileName"
    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$CURRENT_DIR\$FileName" })

    New-Item -Force -ItemType Directory $PATH_TEMP_DIR | Out-Null

    Add-Log $INF "Downloading from $DownloadURL"

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        if (Test-Path $SavePath) { Add-Log $WRN "Previous download found, returning it"; Return $SavePath } else { Return }
    }

    try {
        Remove-Item -Force -ErrorAction SilentlyContinue $SavePath
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $TempPath)
        if (-not $Temp) { Move-Item -Force -ErrorAction SilentlyContinue $TempPath $SavePath }

        if (Test-Path $SavePath) { Out-Success }
        else { Throw 'Possibly computer is offline or disk is full' }
    }
    catch [Exception] { Add-Log $ERR "Download failed: $($_.Exception.Message)"; Return }

    Return $SavePath
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Extract ZIP #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0)]$ZipPath = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No file name specified"),
        [Switch]$Execute
    )
    if (-not $ZipPath) { Return }

    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
    Set-Variable -Option Constant MultiFileArchive ($ZipName -eq 'AAct.zip' -or `
            $ZipName -eq 'KMSAuto_Lite.zip' -or $URL -Match 'SDI_R' -or $URL -Match 'Victoria')

    Set-Variable -Option Constant ExtractionPath $(if ($MultiFileArchive) { $ZipPath.TrimEnd('.zip') })
    Set-Variable -Option Constant TemporaryPath $(if ($ExtractionPath) { $ExtractionPath } else { $PATH_TEMP_DIR })
    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $CURRENT_DIR })
    Set-Variable -Option Constant ExtractionDir $(if ($ExtractionPath) { Split-Path -Leaf $ExtractionPath })

    [String]$Executable = Switch -Wildcard ($ZipName) {
        'Office_2013-2021.zip' { 'OInstall.exe' }
        'AAct.zip' { "AAct$(if ($OS_64_BIT) {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { "KMSAuto$(if ($OS_64_BIT) {' x64'}).exe" }
        'Victoria*' { 'Victoria.exe' }
        'SDI_R*' { "$ExtractionDir\$(if ($OS_64_BIT) {"$($ExtractionDir.Split('_') -Join '_x64_').exe"} else {"$ExtractionDir.exe"})" }
        Default { $ZipName.TrimEnd('.zip') + '.exe' }
    }

    Set-Variable -Option Constant IsDirectory ($ExtractionDir -and $Executable -Like "$ExtractionDir\*")
    Set-Variable -Option Constant TemporaryExe "$TemporaryPath\$Executable"
    Set-Variable -Option Constant TargetExe "$TargetPath\$Executable"

    Remove-Item -Force -ErrorAction SilentlyContinue $TemporaryExe
    if ($MultiFileArchive) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $TemporaryPath
        New-Item -Force -ItemType Directory $TemporaryPath | Out-Null
    }

    Add-Log $INF "Extracting $ZipPath..."

    try {
        if ($ZIP_SUPPORTED) { [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $TemporaryPath) }
        else { ForEach ($Item In $SHELL.NameSpace($ZipPath).Items()) { $SHELL.NameSpace($TemporaryPath).CopyHere($Item) } }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $ZipPath': $($_.Exception.Message)"
        Return
    }

    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath

    if (-not $IsDirectory) {
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryExe $TargetExe
        if ($ExtractionPath) { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath }
    }

    if ( -not $Execute -and $IsDirectory) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse "$TargetPath\$ExtractionDir"
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryPath $TargetPath
    }

    Out-Success
    Add-Log $INF "Files extracted to $TemporaryPath"

    Return $TargetExe
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Execute File #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-File {
    Param(
        [String][Parameter(Position = 0)]$Executable = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No executable specified"),
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$SilentInstall
    )
    if (-not $Executable) { Return }

    if ($Switches -and $SilentInstall) {
        Add-Log $INF "Installing '$Executable' silently..."

        try { Start-Process -Wait $Executable $Switches }
        catch [Exception] { Add-Log $ERR "Failed to install '$Executable': $($_.Exception.Message)"; Return }

        Out-Success

        Add-Log $INF "Removing $Executable..."
        Remove-Item -Force $Executable
        Out-Success
    }
    else {
        Add-Log $INF "Starting '$Executable'..."

        try {
            if ($Switches) { Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable) }
            else { Start-Process $Executable -WorkingDirectory (Split-Path $Executable) }
        }
        catch [Exception] { Add-Log $ERR "Failed to execute '$Executable': $($_.Exception.Message)"; Return }

        Out-Success
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Start Elevated #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Elevated {
    if (-not $IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try { Start-ExternalProcess -Elevated "$($MyInvocation.ScriptName)$(if ($HIDE_CONSOLE) {' -HideConsole'})" }
        catch [Exception] { Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"; Return }

        Exit-Script
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# System Information #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Out-SystemInfo {
    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'

    Set-Variable -Option Constant ComputerSystem (Get-WmiObject Win32_ComputerSystem)
    Set-Variable -Option Constant Computer ($ComputerSystem | Select-Object PCSystemType, @{L = 'RAM'; E = { '{0:N2}' -f ($_.TotalPhysicalMemory / 1GB) } })
    if ($Computer) {
        Add-Log $INF "    Computer type:  $(Switch ($Computer.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
        Add-Log $INF "    RAM:  $($Computer.RAM) GB"
    }

    [Array]$Processors = (Get-WmiObject Win32_Processor | Select-Object Name)
    if ($Processors) {
        ForEach ($Item In $Processors) {
            Add-Log $INF "    CPU $([Array]::IndexOf($Processors, $Item)):  $($Item.Name)"
        }
    }

    [Array]$VideoControllers = ((Get-WmiObject Win32_VideoController).Name)
    if ($VideoControllers) { ForEach ($Item In $VideoControllers) { Add-Log $INF "    GPU $([Array]::IndexOf($VideoControllers, $Item)):  $Item" } }

    if ($OS_VERSION -gt 7) {
        [Array]$Storage = (Get-PhysicalDisk | Select-Object BusType, FriendlyName, HealthStatus, MediaType, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })
        if ($Storage) {
            ForEach ($Item In $Storage) {
                $Details = "$($Item.BusType)$(if ($Item.MediaType -ne 'Unspecified') {' ' + $Item.MediaType}), $($Item.Size) GB, $($Item.HealthStatus)"
                Add-Log $INF "    Storage $([Array]::IndexOf($Storage, $Item)):  $($Item.FriendlyName) ($Details)"
            }
        }
    }
    else {
        [Array]$Storage = (Get-WmiObject Win32_DiskDrive | Select-Object Model, Status, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })
        if ($Storage) { ForEach ($Item In $Storage) { Add-Log $INF "    Storage:  $($Item.Model) ($($Item.Size) GB, Health: $($Item.Status))" } }
    }

    if ($SYSTEM_PARTITION) {
        Add-Log $INF "    Free space on system partition: $($SYSTEM_PARTITION.FreeSpace) GB / $($SYSTEM_PARTITION.Size) GB ($((Get-FreeDiskSpace).ToString('P')))"
    }

    Set-Variable -Option Constant OfficeYear $(Switch ($OFFICE_VERSION) { 16 { '2016 / 2019 / 2021' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })
    Set-Variable -Option Constant Win10Release ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId)

    Add-Log $INF '  Software'
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $(if ($OS_64_BIT) { '64-bit' } else { '32-bit' })"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$Win10Release / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OFFICE_INSTALL_TYPE) {`"($OFFICE_INSTALL_TYPE installation type)`"})"
    Add-Log $INF "    PowerShell version:  $PS_VERSION.$($PSVersionTable.PSVersion.Minor)"
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.Enabled = $BUTTON_DownloadNinite.Enabled = $CHECKBOX_7zip.Checked -or $CHECKBOX_VLC.Checked -or `
        $CHECKBOX_TeamViewer.Checked -or $CHECKBOX_Chrome.Checked -or $CHECKBOX_qBittorrent.Checked -or $CHECKBOX_Malwarebytes.Checked
}


Function Set-NiniteQuery {
    [String[]]$Array = @()
    if ($CHECKBOX_7zip.Checked) { $Array += $CHECKBOX_7zip.Name }
    if ($CHECKBOX_VLC.Checked) { $Array += $CHECKBOX_VLC.Name }
    if ($CHECKBOX_TeamViewer.Checked) { $Array += $CHECKBOX_TeamViewer.Name }
    if ($CHECKBOX_Chrome.Checked) { $Array += $CHECKBOX_Chrome.Name }
    if ($CHECKBOX_qBittorrent.Checked) { $Array += $CHECKBOX_qBittorrent.Name }
    if ($CHECKBOX_Malwarebytes.Checked) { $Array += $CHECKBOX_Malwarebytes.Name }
    Return $Array -Join '-'
}


Function Set-NiniteFileName {
    [String[]]$Array = @()
    if ($CHECKBOX_7zip.Checked) { $Array += $CHECKBOX_7zip.Text }
    if ($CHECKBOX_VLC.Checked) { $Array += $CHECKBOX_VLC.Text }
    if ($CHECKBOX_TeamViewer.Checked) { $Array += $CHECKBOX_TeamViewer.Text }
    if ($CHECKBOX_Chrome.Checked) { $Array += $CHECKBOX_Chrome.Text }
    if ($CHECKBOX_qBittorrent.Checked) { $Array += $CHECKBOX_qBittorrent.Text }
    if ($CHECKBOX_Malwarebytes.Checked) { $Array += $CHECKBOX_Malwarebytes.Text }
    Return "Ninite $($Array -Join ' ') Installer.exe"
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Updates #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-StoreAppUpdate {
    Add-Log $INF 'Starting Microsoft Store apps update...'

    try { Start-ExternalProcess -Elevated -Hidden "(Get-WmiObject MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap').UpdateScanMethod()" }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-OfficeUpdate {
    Add-Log $INF 'Starting Microsoft Office update...'

    try { Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user' }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-WindowsUpdate {
    Add-Log $INF 'Starting Windows Update...'

    try { if ($OS_VERSION -gt 7) { Start-Process 'UsoClient' 'StartInteractiveScan' } else { Start-Process 'wuauclt' '/detectnow /updatenow' } }
    catch [Exception] { Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Check Hardware #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DiskCheck {
    Param([Switch][Parameter(Position = 0)]$FullScan)

    Add-Log $INF 'Starting (C:) disk health check...'

    Set-Variable -Option Constant Command "Start-Process 'chkdsk' $(if ($FullScan) { "'/B'" } elseif ($OS_VERSION -gt 7) { "'/scan /perf'" }) -NoNewWindow"
    try { Start-ExternalProcess -Elevated $Command 'Disk check running...' }
    catch [Exception] { Add-Log $ERR "Failed to check (C:) disk health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-MemoryCheckTool {
    Add-Log $INF 'Starting memory checking tool...'

    try { Start-Process 'mdsched' }
    catch [Exception] { Add-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Check Software #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    Set-Variable -Option Constant ComponentCleanup $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /StartComponentCleanup'" })
    Set-Variable -Option Constant ScanHealth "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /ScanHealth'"
    Set-Variable -Option Constant RestoreHealth $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow 'DISM' '/Online /Cleanup-Image /RestoreHealth'" })

    try { Start-ExternalProcess -Elevated -Title:'Checking Windows health...' @($ComponentCleanup, $ScanHealth, $RestoreHealth) }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-SystemFiles {
    Add-Log $INF 'Starting system file integrity check...'

    try { Start-ExternalProcess -Elevated -Title:'Checking system files...' "Start-Process -NoNewWindow 'sfc' '/scannow'" }
    catch [Exception] { Add-Log $ERR "Failed to check system file integrity: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-SecurityScan {
    if ($OS_VERSION -gt 7) {
        Add-Log $INF 'Updating security signatures...'

        try { Start-ExternalProcess -Wait -Title:'Updating security signatures...' "Start-Process '$PATH_DEFENDER_EXE' '-SignatureUpdate' -NoNewWindow" }
        catch [Exception] { Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"; Return }

        Out-Success
    }

    Add-Log $INF "Performing a security scan..."

    try { Start-ExternalProcess -Title:'Security scan is running...' "Start-Process '$PATH_DEFENDER_EXE' '-Scan -ScanType 2' -NoNewWindow" }
    catch [Exception] { Add-Log $ERR "Failed to perform a security scan: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-MalwareScan {
    Add-Log $INF "Starting malware scan..."

    try { Start-Process -Verb RunAs 'mrt' '/q /f:y' }
    catch [Exception] { Add-Log $ERR "Failed to perform malware scan: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# File Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-FileCleanup {
    Set-Variable -Option Constant LogMessage 'Removing unnecessary files...'
    Add-Log $INF $LogMessage

    Set-Variable -Option Constant ContainerJava86 "${env:ProgramFiles(x86)}\Java"
    Set-Variable -Option Constant ContainerJava "$env:ProgramFiles\Java"
    Set-Variable -Option Constant ContainerOpera "$env:ProgramFiles\Opera"
    Set-Variable -Option Constant ContainerChrome "$PATH_PROGRAM_FILES_86\Google\Chrome\Application"
    Set-Variable -Option Constant ContainerChromeBeta "$PATH_PROGRAM_FILES_86\Google\Chrome Beta\Application"
    Set-Variable -Option Constant ContainerChromeDev "$PATH_PROGRAM_FILES_86\Google\Chrome Dev\Application"
    Set-Variable -Option Constant ContainerGoogleUpdate "$PATH_PROGRAM_FILES_86\Google\Update"

    Set-Variable -Option Constant NonVersionedDirectories @('Assets', 'Download', 'Install', 'Offline', 'SetupMetrics')
    Set-Variable -Option Constant Containers @($ContainerJava86, $ContainerJava, $ContainerOpera, $ContainerChrome, $ContainerChromeBeta, $ContainerChromeDev, $ContainerGoogleUpdate)

    Set-Variable -Option Constant NewestJava86 $(if (Test-Path $ContainerJava86) { Get-ChildItem $ContainerJava86 -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 })
    Set-Variable -Option Constant NewestJava $(if (Test-Path $ContainerJava) { Get-ChildItem $ContainerJava -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 })
    Set-Variable -Option Constant NewestOpera $(if (Test-Path $ContainerOpera) { Get-ChildItem $ContainerOpera -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 })
    Set-Variable -Option Constant NewestChrome $(if (Test-Path $ContainerChrome) { Get-ChildItem $ContainerChrome -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 })
    Set-Variable -Option Constant NewestChromeBeta $(if (Test-Path $ContainerChromeBeta) { Get-ChildItem $ContainerChromeBeta -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 })
    Set-Variable -Option Constant NewestChromeDev $(if (Test-Path $ContainerChromeDev) { Get-ChildItem $ContainerChromeDev -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 })
    Set-Variable -Option Constant NewestGoogleUpdate $(if (Test-Path $ContainerGoogleUpdate) { Get-ChildItem $ContainerGoogleUpdate -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 })

    ForEach ($Path In $Containers) {
        if (Test-Path $Path) {
            Add-Log $INF "Removing older versions from $Path"

            [String]$Newest = (Get-ChildItem $Path -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1).Name
            Get-ChildItem $Path -Exclude $NonVersionedDirectories $Newest | Where-Object { $_.PSIsContainer } | ForEach-Object { $SHELL.Namespace(0).ParseName($_).InvokeVerb('delete') }

            if (Test-Path $Path) { Out-Failure } else { Out-Success }
        }
    }

    Set-Variable -Option Constant ItemsToDeleteWithExclusions -Value @(
        "$PATH_PROGRAM_FILES_86\Microsoft\Skype for Desktop\locales;en-US.pak,lv.pak,ru.pak"
        "$PATH_PROGRAM_FILES_86\Razer\Razer Services\Razer Central\locales;en-US.pak,lv.pak,ru.pak"
        "$PATH_PROGRAM_FILES_86\TeamViewer\TeamViewer_Resource*.dll;TeamViewer_Resource_en.dll,TeamViewer_Resource_ru.dll"
        "$PATH_PROGRAM_FILES_86\WinSCP\Translations;WinSCP.ru"
        "$env:ProgramFiles\7-Zip\Lang;en.ttt,lv.txt,ru.txt"
        "$env:ProgramFiles\CCleaner\Lang;lang-1049.dll,lang-1062.dll"
        "$env:ProgramFiles\Defraggler\Lang;lang-1049.dll,lang-1062.dll"
        "$env:ProgramFiles\Google\Drive\Languages;lv,ru"
        "$env:ProgramFiles\Malwarebytes\Anti-Malware\Languages;lang_ru.qm"
        "$env:ProgramFiles\Microsoft VS Code\locales;en-US.pak,lv.pak,ru.pak"
        "$env:ProgramFiles\Oracle\VirtualBox\nls;qt_ru.qm,VirtualBox_ru.qm"
        "$env:ProgramFiles\paint.net\Resources;ru"
        "$env:ProgramFiles\qBittorrent\translations;qt_lv.qm,qt_ru.qm,qtbase_lv.qm,qtbase_ru.qm"
        "$env:ProgramFiles\Recuva\Lang;lang-1049.dll,lang-1062.dll"
        "$env:ProgramFiles\VideoLAN\VLC\locale;lv,ru"
        "$NewestOpera\localization;en-US.pak,lv.pak,ru.pak"
        "$NewestChrome\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestChromeBeta\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestChromeDev\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestGoogleUpdate\goopdateres_*.dll;goopdateres_en-GB.dll,goopdateres_en-US.dll,goopdateres_lv.dll,goopdateres_ru.dll"
        "$env:LocalAppData\Microsoft\Teams\locales;en-US.pak,lv.pak,ru.pak"
        "$env:LocalAppData\Microsoft\Teams\resources\locales;locale-en-us.json,locale-lv-lv.json,locale-ru-ru.json"
    )

    ForEach ($Item In $ItemsToDeleteWithExclusions) {
        [String]$Path, [String]$Exclusions = $Item.Split(';')

        if (Test-Path $Path) {
            Add-Log $INF "Cleaning $Path"
            Get-ChildItem $Path -Exclude $Exclusions.Split(',') | ForEach-Object { $SHELL.Namespace(0).ParseName($_).InvokeVerb('delete') }
            Out-Success
        }
    }

    Set-Variable -Option Constant ItemsToDelete -Value @(
        "$NewestJava86\COPYRIGHT"
        "$NewestJava86\LICENSE"
        "$NewestJava86\release"
        "$NewestJava86\*.html"
        "$NewestJava86\*.txt"
        "$NewestJava\COPYRIGHT"
        "$NewestJava\LICENSE"
        "$NewestJava\release"
        "$NewestJava\*.html"
        "$NewestJava\*.txt"
        "$NewestChrome\default_apps"
        "$NewestChrome\default_apps\*"
        "$NewestChrome\Installer"
        "$NewestChrome\Installer\*"
        "$NewestChromeBeta\default_apps"
        "$NewestChromeBeta\default_apps\*"
        "$NewestChromeBeta\Installer"
        "$NewestChromeBeta\Installer\*"
        "$NewestChromeDev\default_apps"
        "$NewestChromeDev\default_apps\*"
        "$NewestChromeDev\Installer"
        "$NewestChromeDev\Installer\*"
        "$NewestGoogleUpdate\Recovery"
        "$NewestGoogleUpdate\Recovery\*"
        "$env:SystemDrive\Intel"
        "$env:SystemDrive\Intel\*"
        "$env:SystemDrive\Intel\Logs\*"
        "$env:SystemDrive\PerfLogs"
        "$env:SystemDrive\PerfLogs\*"
        "$env:SystemDrive\temp"
        "$env:SystemDrive\temp\*"
        "$env:ProgramData\Adobe"
        "$env:ProgramData\Adobe\*"
        "$env:ProgramData\Microsoft\Windows Defender\Scans\History\Results\Quick\*"
        "$env:ProgramData\Microsoft\Windows Defender\Scans\History\Results\Resource\*"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip\7-Zip Help.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Docs.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Sheets.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Slides.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\CCleaner\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Defraggler\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\About Java.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\License (English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\User manual (CHM, English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\User manual (PDF, English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY (64-bit)\PuTTY Manual.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY (64-bit)\PuTTY Web Site.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY\PuTTY Manual.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY\PuTTY Web Site.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Recuva\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam\Steam Support Center.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\Documentation.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\Release Notes.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\VideoLAN Website.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\VLC media player - reset preferences and cache files.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\VLC media player skinned.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR\Console RAR manual.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR\What is new in the latest version.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR\WinRAR help.lnk"
        "$env:ProgramData\Microsoft\Windows\WER\ReportArchive\*"
        "$env:ProgramData\Mozilla"
        "$env:ProgramData\Mozilla\*"
        "$env:ProgramData\NVIDIA Corporation\umdlogs"
        "$env:ProgramData\NVIDIA Corporation\umdlogs\*"
        "$env:ProgramData\NVIDIA\*.log_backup1"
        "$env:ProgramData\Oracle"
        "$env:ProgramData\Oracle\*"
        "$env:ProgramData\Package Cache"
        "$env:ProgramData\Package Cache\*"
        "$env:ProgramData\Razer\GameManager\Logs"
        "$env:ProgramData\Razer\Installer\Logs"
        "$env:ProgramData\Razer\Installer\Logs\*"
        "$env:ProgramData\Razer\Razer Central\Logs"
        "$env:ProgramData\Razer\Razer Central\Logs\*"
        "$env:ProgramData\Razer\Razer Central\WebAppCache\Service Worker\Database\*.log"
        "$env:ProgramData\Razer\Synapse3\CrashDumps"
        "$env:ProgramData\Razer\Synapse3\CrashDumps\*"
        "$env:ProgramData\Razer\Synapse3\Log"
        "$env:ProgramData\Razer\Synapse3\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Charlotte\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Charlotte\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Lib\DetectManager\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Lib\DetectManager\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Log\*"
        "$env:ProgramData\Roaming"
        "$env:ProgramData\Roaming\*"
        "$env:ProgramData\USOShared"
        "$env:ProgramData\USOShared\*"
        "$env:ProgramData\VirtualBox"
        "$env:ProgramData\VirtualBox\*"
        "$env:ProgramData\WindowsHolographicDevices"
        "$env:ProgramData\WindowsHolographicDevices\*"
        "$PATH_PROGRAM_FILES_86\7-Zip\7-zip.chm"
        "$PATH_PROGRAM_FILES_86\7-Zip\7-zip.dll.tmp"
        "$PATH_PROGRAM_FILES_86\7-Zip\descript.ion"
        "$PATH_PROGRAM_FILES_86\7-Zip\History.txt"
        "$PATH_PROGRAM_FILES_86\7-Zip\License.txt"
        "$PATH_PROGRAM_FILES_86\7-Zip\readme.txt"
        "$PATH_PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\*.pdf"
        "$PATH_PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\AcroCEF\*.txt"
        "$PATH_PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\Legal\ENU\*"
        "$PATH_PROGRAM_FILES_86\Adobe\Acrobat Reader DC\ReadMe.htm"
        "$PATH_PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Resource\ENUtxt.pdf"
        "$PATH_PROGRAM_FILES_86\CCleaner\Setup"
        "$PATH_PROGRAM_FILES_86\CCleaner\Setup\*"
        "$PATH_PROGRAM_FILES_86\FileZilla FTP Client\AUTHORS"
        "$PATH_PROGRAM_FILES_86\FileZilla FTP Client\GPL.html"
        "$PATH_PROGRAM_FILES_86\FileZilla FTP Client\NEWS"
        "$PATH_PROGRAM_FILES_86\Git\LICENSE.txt"
        "$PATH_PROGRAM_FILES_86\Git\mingw64\doc"
        "$PATH_PROGRAM_FILES_86\Git\mingw64\doc\*"
        "$PATH_PROGRAM_FILES_86\Git\ReleaseNotes.html"
        "$PATH_PROGRAM_FILES_86\Git\tmp"
        "$PATH_PROGRAM_FILES_86\Git\tmp\*"
        "$PATH_PROGRAM_FILES_86\Google\Chrome Beta\Application\SetupMetrics"
        "$PATH_PROGRAM_FILES_86\Google\Chrome Beta\Application\SetupMetrics\*"
        "$PATH_PROGRAM_FILES_86\Google\Chrome Beta\Temp"
        "$PATH_PROGRAM_FILES_86\Google\Chrome Beta\Temp\*"
        "$PATH_PROGRAM_FILES_86\Google\Chrome Dev\Application\SetupMetrics"
        "$PATH_PROGRAM_FILES_86\Google\Chrome Dev\Application\SetupMetrics\*"
        "$PATH_PROGRAM_FILES_86\Google\Chrome Dev\Temp"
        "$PATH_PROGRAM_FILES_86\Google\Chrome Dev\Temp\*"
        "$PATH_PROGRAM_FILES_86\Google\Chrome\Application\SetupMetrics"
        "$PATH_PROGRAM_FILES_86\Google\Chrome\Application\SetupMetrics\*"
        "$PATH_PROGRAM_FILES_86\Google\Chrome\Temp"
        "$PATH_PROGRAM_FILES_86\Google\Chrome\Temp\*"
        "$PATH_PROGRAM_FILES_86\Google\CrashReports"
        "$PATH_PROGRAM_FILES_86\Google\CrashReports\*"
        "$PATH_PROGRAM_FILES_86\Google\Policies"
        "$PATH_PROGRAM_FILES_86\Google\Policies\*"
        "$PATH_PROGRAM_FILES_86\Google\Update\Download"
        "$PATH_PROGRAM_FILES_86\Google\Update\Download\*"
        "$PATH_PROGRAM_FILES_86\Google\Update\Install"
        "$PATH_PROGRAM_FILES_86\Google\Update\Install\*"
        "$PATH_PROGRAM_FILES_86\Google\Update\Offline"
        "$PATH_PROGRAM_FILES_86\Google\Update\Offline\*"
        "$PATH_PROGRAM_FILES_86\Microsoft\Skype for Desktop\*.html"
        "$PATH_PROGRAM_FILES_86\Microsoft VS Code\resources\app\LICENSE.rtf"
        "$PATH_PROGRAM_FILES_86\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$PATH_PROGRAM_FILES_86\Microsoft VS Code\resources\app\licenses"
        "$PATH_PROGRAM_FILES_86\Microsoft VS Code\resources\app\licenses\*"
        "$PATH_PROGRAM_FILES_86\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$PATH_PROGRAM_FILES_86\Mozilla Firefox\install.log"
        "$PATH_PROGRAM_FILES_86\Mozilla Maintenance Service\logs"
        "$PATH_PROGRAM_FILES_86\Mozilla Maintenance Service\logs\*"
        "$PATH_PROGRAM_FILES_86\Notepad++\change.log"
        "$PATH_PROGRAM_FILES_86\Notepad++\readme.txt"
        "$PATH_PROGRAM_FILES_86\Notepad++\updater\LICENSE"
        "$PATH_PROGRAM_FILES_86\Notepad++\updater\README.md"
        "$PATH_PROGRAM_FILES_86\NVIDIA Corporation\Ansel\Tools\tools_licenses.txt"
        "$PATH_PROGRAM_FILES_86\NVIDIA Corporation\license.txt"
        "$PATH_PROGRAM_FILES_86\NVIDIA Corporation\NVSMI\nvidia-smi.1.pdf"
        "$PATH_PROGRAM_FILES_86\Oracle\VirtualBox\doc"
        "$PATH_PROGRAM_FILES_86\Oracle\VirtualBox\doc\*"
        "$PATH_PROGRAM_FILES_86\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack\ExtPack-license.*"
        "$PATH_PROGRAM_FILES_86\Oracle\VirtualBox\License_en_US.rtf"
        "$PATH_PROGRAM_FILES_86\Oracle\VirtualBox\VirtualBox.chm"
        "$PATH_PROGRAM_FILES_86\paint.net\License.txt"
        "$PATH_PROGRAM_FILES_86\paint.net\Staging"
        "$PATH_PROGRAM_FILES_86\paint.net\Staging\*"
        "$PATH_PROGRAM_FILES_86\PuTTY\LICENCE"
        "$PATH_PROGRAM_FILES_86\PuTTY\putty.chm"
        "$PATH_PROGRAM_FILES_86\PuTTY\README.txt"
        "$PATH_PROGRAM_FILES_86\PuTTY\website.url"
        "$PATH_PROGRAM_FILES_86\Steam\dumps"
        "$PATH_PROGRAM_FILES_86\Steam\dumps\*"
        "$PATH_PROGRAM_FILES_86\Steam\logs"
        "$PATH_PROGRAM_FILES_86\Steam\logs\*"
        "$PATH_PROGRAM_FILES_86\TeamViewer\*.log"
        "$PATH_PROGRAM_FILES_86\TeamViewer\*.txt"
        "$PATH_PROGRAM_FILES_86\TeamViewer\TeamViewer_Note.exe"
        "$PATH_PROGRAM_FILES_86\VideoLAN\VLC\AUTHORS.txt"
        "$PATH_PROGRAM_FILES_86\VideoLAN\VLC\COPYING.txt"
        "$PATH_PROGRAM_FILES_86\VideoLAN\VLC\Documentation.url"
        "$PATH_PROGRAM_FILES_86\VideoLAN\VLC\New_Skins.url"
        "$PATH_PROGRAM_FILES_86\VideoLAN\VLC\NEWS.txt"
        "$PATH_PROGRAM_FILES_86\VideoLAN\VLC\README.txt"
        "$PATH_PROGRAM_FILES_86\VideoLAN\VLC\THANKS.txt"
        "$PATH_PROGRAM_FILES_86\VideoLAN\VLC\VideoLAN Website.url"
        "$PATH_PROGRAM_FILES_86\WinRAR\Descript.ion"
        "$PATH_PROGRAM_FILES_86\WinRAR\License.txt"
        "$PATH_PROGRAM_FILES_86\WinRAR\Order.htm"
        "$PATH_PROGRAM_FILES_86\WinRAR\Rar.txt"
        "$PATH_PROGRAM_FILES_86\WinRAR\ReadMe.txt"
        "$PATH_PROGRAM_FILES_86\WinRAR\WhatsNew.txt"
        "$PATH_PROGRAM_FILES_86\WinRAR\WinRAR.chm"
        "$PATH_PROGRAM_FILES_86\WinSCP\PuTTY\putty.chm"
        "$env:ProgramFiles\7-Zip\7-zip.chm"
        "$env:ProgramFiles\7-Zip\7-zip.dll.tmp"
        "$env:ProgramFiles\7-Zip\descript.ion"
        "$env:ProgramFiles\7-Zip\History.txt"
        "$env:ProgramFiles\7-Zip\License.txt"
        "$env:ProgramFiles\7-Zip\readme.txt"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\*.pdf"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\AcroCEF\*.txt"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\Legal\ENU\*"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\ReadMe.htm"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Resource\ENUtxt.pdf"
        "$env:ProgramFiles\CCleaner\Setup"
        "$env:ProgramFiles\CCleaner\Setup\*"
        "$env:ProgramFiles\FileZilla FTP Client\AUTHORS"
        "$env:ProgramFiles\FileZilla FTP Client\GPL.html"
        "$env:ProgramFiles\FileZilla FTP Client\NEWS"
        "$env:ProgramFiles\Git\mingw64\doc"
        "$env:ProgramFiles\Git\ReleaseNotes.html"
        "$env:ProgramFiles\Git\tmp"
        "$env:ProgramFiles\Git\tmp\*"
        "$env:ProgramFiles\Google\Chrome Beta\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome Beta\Application\SetupMetrics\*"
        "$env:ProgramFiles\Google\Chrome Beta\Temp"
        "$env:ProgramFiles\Google\Chrome Beta\Temp\*"
        "$env:ProgramFiles\Google\Chrome Dev\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome Dev\Application\SetupMetrics\*"
        "$env:ProgramFiles\Google\Chrome Dev\Temp"
        "$env:ProgramFiles\Google\Chrome Dev\Temp\*"
        "$env:ProgramFiles\Google\Chrome\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome\Application\SetupMetrics\*"
        "$env:ProgramFiles\Google\Chrome\Temp"
        "$env:ProgramFiles\Google\Chrome\Temp\*"
        "$env:ProgramFiles\Google\CrashReports"
        "$env:ProgramFiles\Google\CrashReports\*"
        "$env:ProgramFiles\Google\Update\Download"
        "$env:ProgramFiles\Google\Update\Download\*"
        "$env:ProgramFiles\Google\Update\Install"
        "$env:ProgramFiles\Google\Update\Install\*"
        "$env:ProgramFiles\Google\Update\Offline"
        "$env:ProgramFiles\Google\Update\Offline\*"
        "$env:ProgramFiles\Microsoft\Skype for Desktop\*.html"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses\*"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$env:ProgramFiles\Mozilla Firefox\install.log"
        "$env:ProgramFiles\Mozilla Maintenance Service\logs"
        "$env:ProgramFiles\Mozilla Maintenance Service\logs\*"
        "$env:ProgramFiles\NVIDIA Corporation\NVSMI\nvidia-smi.1.pdf"
        "$env:ProgramFiles\Oracle\VirtualBox\doc"
        "$env:ProgramFiles\Oracle\VirtualBox\VirtualBox.chm"
        "$env:ProgramFiles\PuTTY\putty.chm"
        "$env:ProgramFiles\PuTTY\README.txt"
        "$env:ProgramFiles\PuTTY\website.url"
        "$env:ProgramFiles\Steam\dumps"
        "$env:ProgramFiles\Steam\dumps\*"
        "$env:ProgramFiles\Steam\logs"
        "$env:ProgramFiles\Steam\logs\*"
        "$env:ProgramFiles\TeamViewer\*.log"
        "$env:ProgramFiles\TeamViewer\*.txt"
        "$env:ProgramFiles\TeamViewer\TeamViewer_Note.exe"
        "$env:ProgramFiles\VideoLAN\VLC\Documentation.url"
        "$env:ProgramFiles\VideoLAN\VLC\New_Skins.url"
        "$env:ProgramFiles\VideoLAN\VLC\NEWS.txt"
        "$env:ProgramFiles\VideoLAN\VLC\README.txt"
        "$env:ProgramFiles\VideoLAN\VLC\THANKS.txt"
        "$env:ProgramFiles\VideoLAN\VLC\VideoLAN Website.url"
        "$env:ProgramFiles\WinRAR\Descript.ion"
        "$env:ProgramFiles\WinRAR\Order.htm"
        "$env:ProgramFiles\WinRAR\Rar.txt"
        "$env:ProgramFiles\WinRAR\ReadMe.txt"
        "$env:ProgramFiles\WinRAR\WhatsNew.txt"
        "$env:ProgramFiles\WinRAR\WinRAR.chm"
        "$env:WinDir\*.log"
        "$env:WinDir\debug\*.log"
        "$env:WinDir\INF\*.log"
        "$env:WinDir\Logs\*"
        "$env:WinDir\Microsoft.NET\Framework\*\*.log"
        "$env:WinDir\Microsoft.NET\Framework64\*\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0_32\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0_32\UsageLogs"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0_32\UsageLogs\*"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0\UsageLogs"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0\UsageLogs\*"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0_32\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs\*"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0\UsageLogs"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0\UsageLogs\*"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Temp\*"
        "$env:WinDir\SoftwareDistribution\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0_32\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0_32\UsageLogs"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0_32\UsageLogs\*"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0\UsageLogs"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0\UsageLogs\*"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0_32\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs\*"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0\UsageLogs"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0\UsageLogs\*"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Temp\*"
        "$env:WinDir\Temp\*"
        "$env:WinDir\SoftwareDistribution\Download\*"
        "$env:TMP\*"
        "$env:Public\Foxit Software"
        "$env:Public\Foxit Software\*"
        "$env:UserProfile\.VirtualBox\*.log*"
        "$env:UserProfile\MicrosoftEdgeBackups"
        "$env:UserProfile\MicrosoftEdgeBackups\*"
        "$env:AppData\Code\logs"
        "$env:AppData\Code\logs\*"
        "$env:AppData\Google"
        "$env:AppData\Google\*"
        "$env:AppData\Microsoft\Office\Recent"
        "$env:AppData\Microsoft\Office\Recent\*"
        "$env:AppData\Microsoft\Skype for Desktop\logs"
        "$env:AppData\Microsoft\Skype for Desktop\logs\*"
        "$env:AppData\Microsoft Teams\logs"
        "$env:AppData\Microsoft Teams\logs\*"
        "$env:AppData\Microsoft\Windows\Recent\*.*"
        "$env:AppData\Opera Software\Opera Stable\*.log"
        "$env:AppData\Opera Software\Opera Stable\Crash Reports"
        "$env:AppData\Opera Software\Opera Stable\Crash Reports\*"
        "$env:AppData\Skype"
        "$env:AppData\Skype\*"
        "$env:AppData\Sun"
        "$env:AppData\Sun\*"
        "$env:AppData\TeamViewer\*.log"
        "$env:AppData\Visual Studio Code"
        "$env:AppData\Visual Studio Code\*"
        "$env:AppData\vlc\art"
        "$env:AppData\vlc\art\*"
        "$env:AppData\vlc\crashdump"
        "$env:AppData\vlc\crashdump\*"
        "$env:LocalAppData\CrashDumps"
        "$env:LocalAppData\CrashDumps\*"
        "$env:LocalAppData\DBG"
        "$env:LocalAppData\DBG\*"
        "$env:LocalAppData\Deployment"
        "$env:LocalAppData\Deployment\*"
        "$env:LocalAppData\Diagnostics"
        "$env:LocalAppData\Diagnostics\*"
        "$env:LocalAppData\Google\CrashReports"
        "$env:LocalAppData\Google\CrashReports\*"
        "$env:LocalAppData\Google\Software Reporter Tool"
        "$env:LocalAppData\Google\Software Reporter Tool\*"
        "$env:LocalAppData\LocalLow\Sun"
        "$env:LocalAppData\LocalLow\Sun\*"
        "$env:LocalAppData\Microsoft\CLR_v2.0_32\*.log"
        "$env:LocalAppData\Microsoft\CLR_v2.0_32\UsageLogs"
        "$env:LocalAppData\Microsoft\CLR_v2.0_32\UsageLogs\*"
        "$env:LocalAppData\Microsoft\CLR_v2.0\*.log"
        "$env:LocalAppData\Microsoft\CLR_v2.0\UsageLogs"
        "$env:LocalAppData\Microsoft\CLR_v2.0\UsageLogs\*"
        "$env:LocalAppData\Microsoft\CLR_v4.0_32\*.log"
        "$env:LocalAppData\Microsoft\CLR_v4.0_32\UsageLogs"
        "$env:LocalAppData\Microsoft\CLR_v4.0_32\UsageLogs\*"
        "$env:LocalAppData\Microsoft\CLR_v4.0\*.log"
        "$env:LocalAppData\Microsoft\CLR_v4.0\UsageLogs"
        "$env:LocalAppData\Microsoft\CLR_v4.0\UsageLogs\*"
        "$env:LocalAppData\Microsoft\Media Player\lastplayed.wpl"
        "$env:LocalAppData\Microsoft\Office\16.0\WebServiceCache"
        "$env:LocalAppData\Microsoft\Office\16.0\WebServiceCache\*"
        "$env:LocalAppData\Microsoft\OneDrive\logs"
        "$env:LocalAppData\Microsoft\OneDrive\logs\*"
        "$env:LocalAppData\Microsoft\OneDrive\setup"
        "$env:LocalAppData\Microsoft\OneDrive\setup\*"
        "$env:LocalAppData\Microsoft\Teams\*.log"
        "$env:LocalAppData\Microsoft\Teams\*.log"
        "$env:LocalAppData\Microsoft\Teams\packages\*.nupkg"
        "$env:LocalAppData\Microsoft\Teams\packages\SquirrelTemp"
        "$env:LocalAppData\Microsoft\Teams\packages\SquirrelTemp\*"
        "$env:LocalAppData\Microsoft\Teams\previous"
        "$env:LocalAppData\Microsoft\Teams\previous\*"
        "$env:LocalAppData\Microsoft\Windows\Explorer\thumbcache_*.db"
        "$env:LocalAppData\Microsoft\Windows\SettingSync\remotemetastore\v1\*.log"
        "$env:LocalAppData\Microsoft\Windows\WebCache\*.log"
    )

    ForEach ($Item In $ItemsToDelete) {
        if (Test-Path $Item) {
            Add-Log $INF "Removing $Item"
            Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $Item
            if (Test-Path $Item) { Out-Failure } else { Out-Success }
        }
    }

    if (-not $IS_ELEVATED) {
        Add-Log $WRN 'Removal of certain files requires administrator privileges. To remove them, restart the utility'
        Add-Log $WRN '  as administrator (see Home -> This utility -> Run as administrator) and run this task again.'
    }
    else { Add-Log $INF 'Some files are in use, so they cannot be deleted.' }

    Add-Log $INF $LogMessage
    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# System Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DiskCleanup {
    Add-Log $INF 'Starting disk cleanup utility...'

    try { Start-Process -Verb RunAs 'cleanmgr' '/lowdisk' }
    catch [Exception] { Add-Log $ERR "Failed to start disk cleanup utility: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Optimization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Set-CloudFlareDNS {
    [String]$PreferredDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.1.1.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.1.1.2' } else { '1.1.1.1' } };
    [String]$AlternateDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.0.0.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.0.0.2' } else { '1.0.0.1' } };

    Add-Log $WRN 'Internet connection may get interrupted briefly'
    Add-Log $INF "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."

    if (-not (Get-NetworkAdapter)) {
        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Add-Log $ERR 'This could mean that computer is not connected'
        Return
    }

    try { Start-ExternalProcess -Elevated -Hidden "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('$PreferredDnsServer', '$AlternateDnsServer'))" }
    catch [Exception] { Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-DriveOptimization {
    Add-Log $INF "Starting $(if ($OS_VERSION -le 7) { '(C:) ' })drive optimization..."

    Set-Variable -Option Constant Command "Start-Process -NoNewWindow 'defrag' $(if ($OS_VERSION -gt 7) { "'/C /H /U /O'" } else { "'C: /H /U'" })"
    try { Start-ExternalProcess -Elevated -Title:'Optimizing drives...' $Command }
    catch [Exception] { Add-Log $ERR "Failed to optimize drives: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Draw Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

[Void]$FORM.ShowDialog()
