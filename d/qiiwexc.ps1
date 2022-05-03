Set-Variable -Option Constant Version ([Version]'22.5.3')


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


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Constants #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant BUTTON_WIDTH    170
Set-Variable -Option Constant BUTTON_HEIGHT   30

Set-Variable -Option Constant CHECKBOX_HEIGHT 20

Set-Variable -Option Constant INTERVAL_SHORT  5
Set-Variable -Option Constant INTERVAL_NORMAL 15
Set-Variable -Option Constant INTERVAL_LONG   30


Set-Variable -Option Constant INTERVAL_BUTTON_SHORT  ($BUTTON_HEIGHT + $INTERVAL_SHORT)
Set-Variable -Option Constant INTERVAL_BUTTON_NORMAL ($BUTTON_HEIGHT + $INTERVAL_NORMAL)

Set-Variable -Option Constant INTERVAL_CHECKBOX ($CHECKBOX_HEIGHT + $INTERVAL_SHORT)


Set-Variable -Option Constant GROUP_WIDTH ($INTERVAL_NORMAL + $BUTTON_WIDTH + $INTERVAL_NORMAL)

Set-Variable -Option Constant FORM_WIDTH  (($GROUP_WIDTH + $INTERVAL_NORMAL) * 3 + ($INTERVAL_NORMAL * 2))
Set-Variable -Option Constant FORM_HEIGHT ($INTERVAL_BUTTON_NORMAL * 14)

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON "$INTERVAL_NORMAL, 20"

Set-Variable -Option Constant SHIFT_CHECKBOX "0, $($CHECKBOX_HEIGHT + $INTERVAL_SHORT)"


Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"


Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


Set-Variable -Option Constant PATH_TEMP_DIR "$env:TMP\qiiwexc"
Set-Variable -Option Constant PATH_PROGRAM_FILES_86 $(if ($OS_64_BIT) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles })
Set-Variable -Option Constant PATH_DEFENDER_EXE "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
Set-Variable -Option Constant PATH_CHROME_EXE "$PATH_PROGRAM_FILES_86\Google\Chrome\Application\chrome.exe"
Set-Variable -Option Constant PATH_MRT_EXE "$env:windir\System32\MRT.exe"


Set-Variable -Option Constant REQUIRES_ELEVATION $(if (!$IS_ELEVATED) { ' *' } else { '' })


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Texts #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TXT_START_AFTER_DOWNLOAD 'Start after download'
Set-Variable -Option Constant TXT_UNCHECKY_INFO 'Unchecky clears adware checkboxes when installing software'
Set-Variable -Option Constant TXT_AV_WARNING "This file may trigger anti-virus false positive!`nIt is recommended to disable anti-virus software for download and subsequent use of this file!"

Set-Variable -Option Constant TXT_TIP_START_AFTER_DOWNLOAD "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"


Set-Variable -Option Constant URL_KMS_AUTO_LITE 'https://qiiwexc.github.io/d/KMSAuto_Lite.zip'
Set-Variable -Option Constant URL_AACT          'https://qiiwexc.github.io/d/AAct.zip'

Set-Variable -Option Constant URL_WINDOWS_11 'https://w14.monkrus.ws/2021/10/windows-11-v21h2-rus-eng-26in1-hwid-act_14.html'
Set-Variable -Option Constant URL_WINDOWS_10 'https://w14.monkrus.ws/2021/12/windows-10-v21h2-rus-eng-x86-x64-40in1.html'
Set-Variable -Option Constant URL_WINDOWS_7  'https://w14.monkrus.ws/2022/02/windows-7-sp1-rus-eng-x86-x64-18in1.html'
Set-Variable -Option Constant URL_WINDOWS_XP 'https://drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'

Set-Variable -Option Constant URL_CCLEANER   'https://download.ccleaner.com/ccsetup.exe'
Set-Variable -Option Constant URL_RUFUS      'https://github.com/pbatard/rufus/releases/download/v3.18/rufus-3.18p.exe'
Set-Variable -Option Constant URL_WINDOWS_PE 'https://drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'

Set-Variable -Option Constant URL_CHROME_HTTPS   'https://chrome.google.com/webstore/detail/gcbommkclmclpchllfjekcdonpmejbdp'
Set-Variable -Option Constant URL_CHROME_ADBLOCK 'https://chrome.google.com/webstore/detail/gighmmpiobklfepjocnamgkkbiglidom'
Set-Variable -Option Constant URL_CHROME_YOUTUBE 'https://chrome.google.com/webstore/detail/gebbhagfogifgggkldgodflihgfeippi'

Set-Variable -Option Constant URL_SDI      'https://sdi-tool.org/releases/SDI_R2201.zip'
Set-Variable -Option Constant URL_UNCHECKY 'https://unchecky.com/files/unchecky_setup.exe'
Set-Variable -Option Constant URL_OFFICE   'https://qiiwexc.github.io/d/Office_2013-2021.zip'

Set-Variable -Option Constant URL_VICTORIA 'https://hdd.by/Victoria/Victoria537.zip'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Initialization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Write-Host 'Initializing...'

Set-Variable -Option Constant IS_ELEVATED $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))

Set-Variable -Option Constant OLD_WINDOW_TITLE $($HOST.UI.RawUI.WindowTitle)
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"

Set-Variable -Option Constant StartedFromGUI $($MyInvocation.Line -Match 'if((Get-ExecutionPolicy ) -ne ''AllSigned'')*')
Set-Variable -Option Constant HIDE_CONSOLE ($args[0] -eq '-HideConsole' -or $StartedFromGUI -or !$MyInvocation.Line)

if ($HIDE_CONSOLE) {
    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

try { Add-Type -AssemblyName System.Windows.Forms } catch { Throw 'System not supported' }

[System.Windows.Forms.Application]::EnableVisualStyles()


Set-Variable -Option Constant PS_VERSION $($PSVersionTable.PSVersion.Major)

Set-Variable -Option Constant SHELL $(New-Object -com Shell.Application)

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


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - Structural #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-Tab {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Set-Variable -Option Constant TabPage (New-Object System.Windows.Forms.TabPage)

    $TabPage.UseVisualStyleBackColor = $True
    $TabPage.Text = $Text

    $TAB_CONTROL.Controls.Add($TabPage)

    Set-Variable -Scope Script PREVIOUS_GROUP $Null
    Set-Variable -Scope Script CURRENT_TAB $TabPage
}

Function New-GroupBox {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [Int][Parameter(Position = 1)]$IndexOverride
    )

    Set-Variable -Option Constant GroupBox (New-Object System.Windows.Forms.GroupBox)

    Set-Variable -Scope Script PREVIOUS_GROUP $CURRENT_GROUP

    [Int]$GroupIndex = 0

    if ($IndexOverride) {
        $GroupIndex = $IndexOverride
    }
    else {
        $CURRENT_TAB.Controls | ForEach-Object { $GroupIndex += $_.Length }
    }

    if ($GroupIndex -lt 3) {
        Set-Variable -Option Constant Location $(if ($GroupIndex -eq 0) { "$INTERVAL_NORMAL, $INTERVAL_NORMAL" } else { $PREVIOUS_GROUP.Location + "$($GROUP_WIDTH + $INTERVAL_NORMAL), 0" })
    }
    else {
        Set-Variable -Option Constant PreviousGroup $CURRENT_TAB.Controls[$GroupIndex - 3]
        Set-Variable -Option Constant Location ($PreviousGroup.Location + "0, $($PreviousGroup.Height + $INTERVAL_NORMAL)")
    }

    $GroupBox.Width = $GROUP_WIDTH
    $GroupBox.Text = $Text
    $GroupBox.Location = $Location

    $CURRENT_TAB.Controls.Add($GroupBox)

    Set-Variable -Scope Script PREVIOUS_BUTTON $Null
    Set-Variable -Scope Script PREVIOUS_LABEL_OR_INTERACTIVE $Null

    Set-Variable -Scope Script CURRENT_GROUP $GroupBox
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - Button #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-ButtonBrowser {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1, Mandatory = $True)]$Function,
        [String]$ToolTip
    )

    New-Button $Text $Function -ToolTip $ToolTip > $Null

    New-Label 'Opens in the browser' > $Null
}

Function New-Button {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [Switch]$Disabled,
        [Switch]$UAC,
        [String]$ToolTip
    )

    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "0, $INTERVAL_BUTTON_NORMAL"
    }

    if ($PREVIOUS_LABEL_OR_INTERACTIVE) {
        $InitialLocation.Y = $PREVIOUS_LABEL_OR_INTERACTIVE.Location.Y
        $Shift = "0, $INTERVAL_BUTTON_SHORT"
    }

    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $Button.Font = $BUTTON_FONT
    $Button.Height = $BUTTON_HEIGHT
    $Button.Width = $BUTTON_WIDTH
    $Button.Enabled = !$Disabled
    $Button.Location = $Location

    $Button.Text = if (!$UAC -or $IS_ELEVATED) { $Text } else { "$Text$REQUIRES_ELEVATION" }

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($Button, $ToolTip) }
    if ($Function) { $Button.Add_Click($Function) }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_BUTTON_NORMAL
    $CURRENT_GROUP.Controls.Add($Button)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_INTERACTIVE $Null
    Set-Variable -Scope Script PREVIOUS_BUTTON $Button

    Return $Button
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - CheckBox #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-CheckBoxRunAfterDownload {
    Param(
        [Switch]$Disabled,
        [Switch]$Checked
    )

    Return New-CheckBox $TXT_START_AFTER_DOWNLOAD  -Disabled:$Disabled -Checked:$Checked -ToolTip $TXT_TIP_START_AFTER_DOWNLOAD
}

Function New-CheckBox {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [String][Parameter(Position = 1)]$Name,
        [Switch]$Disabled,
        [Switch]$Checked,
        [String]$ToolTip
    )

    Set-Variable -Option Constant CheckBox (New-Object System.Windows.Forms.CheckBox)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "$INTERVAL_CHECKBOX, $INTERVAL_LONG"
    }

    if ($PREVIOUS_LABEL_OR_INTERACTIVE) {
        $InitialLocation.Y = $PREVIOUS_LABEL_OR_INTERACTIVE.Location.Y

        if ($CURRENT_GROUP.Text -eq "Ninite") {
            $Shift = "0, $INTERVAL_CHECKBOX"
        }
        else {
            $Shift = "$INTERVAL_CHECKBOX, $CHECKBOX_HEIGHT"
        }
    }

    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $CheckBox.Text = $Text
    $CheckBox.Name = $Name
    $CheckBox.Checked = $Checked
    $CheckBox.Enabled = !$Disabled
    $CheckBox.Size = "145, $CHECKBOX_HEIGHT"
    $CheckBox.Location = $Location

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBox, $ToolTip) }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_LONG
    $CURRENT_GROUP.Controls.Add($CheckBox)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_INTERACTIVE $CheckBox

    Return $CheckBox
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - Misc #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-Label {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Set-Variable -Option Constant Label (New-Object System.Windows.Forms.Label)

    [System.Drawing.Point]$Location = ($PREVIOUS_BUTTON.Location + "$INTERVAL_LONG, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)")

    $Label.Size = "145, $CHECKBOX_HEIGHT"
    $Label.Text = $Text
    $Label.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_LONG
    $CURRENT_GROUP.Controls.Add($Label)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_INTERACTIVE $Label
}

Function New-RadioButton {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [Switch]$Checked,
        [String]$ToolTip
    )

    Set-Variable -Option Constant RadioButton (New-Object System.Windows.Forms.RadioButton)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "10, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
    }

    if ($PREVIOUS_LABEL_OR_INTERACTIVE) {
        $InitialLocation.Y = $PREVIOUS_LABEL_OR_INTERACTIVE.Location.Y
        $Shift = "95, 0"
    }

    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $RadioButton.Text = $Text
    $RadioButton.Checked = $Checked
    $RadioButton.Size = "80, $CHECKBOX_HEIGHT"
    $RadioButton.Location = $Location

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($RadioButton, $ToolTip) }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_LONG
    $CURRENT_GROUP.Controls.Add($RadioButton)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_INTERACTIVE $RadioButton

    Return $RadioButton
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant FORM (New-Object System.Windows.Forms.Form)
$FORM.Text = $HOST.UI.RawUI.WindowTitle
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )
$FORM.Add_FormClosing( { Reset-StateOnExit } )


Set-Variable -Option Constant LOG (New-Object System.Windows.Forms.RichTextBox)
$LOG.Height = 200
$LOG.Width = - $INTERVAL_SHORT + $FORM_WIDTH - $INTERVAL_SHORT
$LOG.Location = "$INTERVAL_SHORT, $($FORM_HEIGHT - $LOG.Height - $INTERVAL_SHORT)"
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True
$FORM.Controls.Add($LOG)


Set-Variable -Option Constant TAB_CONTROL (New-Object System.Windows.Forms.TabControl)
$TAB_CONTROL.Size = "$($LOG.Width + $INTERVAL_SHORT - 4), $($FORM_HEIGHT - $LOG.Height - $INTERVAL_SHORT - 4)"
$TAB_CONTROL.Location = "$INTERVAL_SHORT, $INTERVAL_SHORT"
$FORM.Controls.Add($TAB_CONTROL)


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TAB_HOME (New-Tab 'Home')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - General #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'General'


$BUTTON_TEXT = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Run as administrator'})"
$BUTTON_TOOLTIP_TEXT = 'Restart this utility with administrator privileges'
$BUTTON_FUNCTION = { Start-Elevated }
New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT -Disabled:$IS_ELEVATED > $Null


$BUTTON_TOOLTIP_TEXT = 'Print system information to the log'
$BUTTON_FUNCTION = { Out-SystemInfo }
New-Button 'System information' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Activators #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Activators'


$BUTTON_DownloadKMSAuto = New-Button -UAC 'KMSAuto Lite' -ToolTip "Download KMSAuto Lite`nActivates Windows 7 - 11 and Office 2010 - 2021`n`n$TXT_AV_WARNING"
$BUTTON_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartKMSAuto.Checked $URL_KMS_AUTO_LITE } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartKMSAuto = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartKMSAuto.Add_CheckStateChanged( { $BUTTON_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CHECKBOX_StartKMSAuto.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadAAct = New-Button -UAC 'AAct (Win 7+, Office)' -ToolTip "Download AAct`nActivates Windows 7 - 11 and Office 2010 - 2021`n`n$TXT_AV_WARNING"
$BUTTON_DownloadAAct.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked $URL_AACT } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartAAct = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartAAct.Add_CheckStateChanged( { $BUTTON_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CHECKBOX_StartAAct.Checked) { $REQUIRES_ELEVATION })" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Windows Images #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Windows Images'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_11 }
New-ButtonBrowser 'Windows 11 (v21H2)' $BUTTON_FUNCTION -ToolTip 'Download Windows 11 (v21H2) RUS-ENG -26in1- HWID-act v2 (AIO) ISO image'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_10 }
New-ButtonBrowser 'Windows 10 (v21H2)' $BUTTON_FUNCTION -ToolTip 'Download Windows 10 (v21H1) RUS-ENG x86-x64 -28in1- HWID-act (AIO) ISO image'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_7 }
New-ButtonBrowser 'Windows 7 SP1' $BUTTON_FUNCTION -ToolTip 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v10 (AIO) ISO image'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_XP }
New-ButtonBrowser 'Windows XP SP3 (ENG)' $BUTTON_FUNCTION -ToolTip 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Tools #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Tools'


$BUTTON_DownloadCCleaner = New-Button -UAC 'CCleaner' -ToolTip 'Download CCleaner installer'
$BUTTON_DownloadCCleaner.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartCCleaner.Checked $URL_CCLEANER } )


$CHECKBOX_StartCCleaner = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartCCleaner.Add_CheckStateChanged( { $BUTTON_DownloadCCleaner.Text = "CCleaner$(if ($CHECKBOX_StartCCleaner.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadRufus = New-Button -UAC 'Rufus (bootable USB)' -ToolTip 'Download Rufus - a bootable USB creator'
$BUTTON_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartRufus.Add_CheckStateChanged( { $BUTTON_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CHECKBOX_StartRufus.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_PE }
New-ButtonBrowser 'Windows PE (Live CD)' $BUTTON_FUNCTION -ToolTip 'Download Windows PE (Live CD) ISO image based on Windows 10'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Chrome Extension #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Chrome Extensions'


$BUTTON_TOOLTIP_TEXT = 'Automatically use HTTPS security on many sites'
$BUTTON_DISABLED = !(Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_HTTPS }
New-Button 'HTTPS Everywhere' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Block ads and pop-ups on websites'
$BUTTON_DISABLED = !(Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_ADBLOCK }
New-Button 'AdBlock' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Return YouTube Dislike restores the ability to see dislikes on YouTube'
$BUTTON_DISABLED = !(Test-Path $PATH_CHROME_EXE)
$BUTTON_FUNCTION = { Start-Process $PATH_CHROME_EXE $URL_CHROME_YOUTUBE }
New-Button 'Return YouTube Dislike' $BUTTON_FUNCTION -Disabled:$BUTTON_DISABLED -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TAB_DOWNLOADS (New-Tab 'Downloads')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Ninite'


$CHECKBOX_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
$CHECKBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )


$CHECKBOX_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
$CHECKBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )


$CHECKBOX_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
$CHECKBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )


$CHECKBOX_TeamViewer = New-CheckBox 'TeamViewer' -Name 'teamviewer15' -Checked
$CHECKBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )


$CHECKBOX_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
$CHECKBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )


$CHECKBOX_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
$CHECKBOX_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )


$BUTTON_DownloadNinite = New-Button -UAC 'Download selected' -ToolTip 'Download Ninite universal installer for selected applications'
$BUTTON_DownloadNinite.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "https://ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) } )


$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartNinite.Add_CheckStateChanged( { $BUTTON_DownloadNinite.Text = "Download selected$(if ($CHECKBOX_StartNinite.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_FUNCTION = { Open-InBrowser "https://ninite.com/?select=$(Set-NiniteQuery)" }
New-ButtonBrowser 'View other' $BUTTON_FUNCTION -ToolTip 'Open Ninite universal installer web page for other installation options'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Essentials #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Essentials'


$BUTTON_DownloadSDI = New-Button -UAC 'Snappy Driver Installer' -ToolTip 'Download Snappy Driver Installer'
$BUTTON_DownloadSDI.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked $URL_SDI } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartSDI.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadUnchecky = New-Button -UAC 'Unchecky' -ToolTip "Download Unchecky installer`n$TXT_UNCHECKY_INFO"
$BUTTON_DownloadUnchecky.Add_Click( {
        Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
        Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked $URL_UNCHECKY -Params:$Params -SilentInstall:$CHECKBOX_SilentlyInstallUnchecky.Checked
    } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
        $BUTTON_DownloadUnchecky.Text = "Unchecky$(if ($CHECKBOX_StartUnchecky.Checked) { $REQUIRES_ELEVATION })"
        $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked
    } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED -ToolTip 'Perform silent installation with no prompts'
$CHECKBOX_SilentlyInstallUnchecky.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadOffice = New-Button -UAC 'Office 2013 - 2021' -ToolTip "Download Microsoft Office 2013 - 2021 C2R installer and activator`n`n$TXT_AV_WARNING"
$BUTTON_DownloadOffice.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked $URL_OFFICE } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartOffice = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartOffice.Add_CheckStateChanged( { $BUTTON_DownloadOffice.Text = "Office 2013 - 2021$(if ($CHECKBOX_StartOffice.Checked) { $REQUIRES_ELEVATION })" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Updates #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Updates'


$BUTTON_TOOLTIP_TEXT = 'Update Microsoft Store apps'
$BUTTON_DISABLED = $OS_VERSION -le 7
$BUTTON_FUNCTION = { Start-StoreAppUpdate }
New-Button -UAC 'Update Store apps' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null


$BUTTON_TOOLTIP_TEXT = 'Update Microsoft Office (for C2R installations only)'
$BUTTON_DISABLED = !$OFFICE_INSTALL_TYPE -eq 'C2R'
$BUTTON_FUNCTION = { Start-OfficeUpdate }
New-Button 'Update Microsoft Office' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT -Disabled:$BUTTON_DISABLED > $Null


$BUTTON_TOOLTIP_TEXT = 'Check for Windows updates, download and install if available'
$BUTTON_FUNCTION = { Start-WindowsUpdate }
New-Button -UAC 'Start Windows Update' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TAB_MAINTENANCE (New-Tab 'Maintenance')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Hardware Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Hardware Diagnostics'


$BUTTON_TEXT = 'Check (C:) disk health'
$BUTTON_TOOLTIP_TEXT = 'Start (C:) disk health check'
$BUTTON_FUNCTION = { Start-DiskCheck $RADIO_FullDiskCheck.Checked }
New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$RADIO_TEXT = 'Quick scan'
$RADIO_TOOLTIP_TEXT = 'Perform a quick disk scan'
$RADIO_QuickDiskCheck = New-RadioButton $RADIO_TEXT -ToolTip $RADIO_TOOLTIP_TEXT -Checked

$RADIO_TEXT = 'Full scan'
$RADIO_TOOLTIP_TEXT = 'Schedule a full disk scan on next restart'
$RADIO_FullDiskCheck = New-RadioButton $RADIO_TEXT -ToolTip $RADIO_TOOLTIP_TEXT


$BUTTON_DownloadVictoria = New-Button -UAC 'Victoria (HDD scan)' -ToolTip 'Download Victoria HDD scanner'
$BUTTON_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA } )


$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVictoria.Add_CheckStateChanged( { $BUTTON_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CHECKBOX_StartVictoria.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_TOOLTIP_TEXT = 'Start RAM checking utility'
$BUTTON_FUNCTION = { Start-MemoryCheckTool }
New-Button 'RAM checking utility' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Software Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Software Diagnostics'


$BUTTON_TOOLTIP_TEXT = 'Check Windows health'
$BUTTON_FUNCTION = { Test-WindowsHealth }
New-Button -UAC 'Check Windows health' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Remove temporary files, some log files and empty directories, and some other unnecessary files; start Windows built-in disk cleanup utility'
$BUTTON_FUNCTION = { Start-DiskCleanup }
New-Button 'Start disk cleanup' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$BUTTON_TOOLTIP_TEXT = 'Start security scans'
$BUTTON_FUNCTION = { Start-SecurityScans }
New-Button -UAC 'Perform security scans' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Optimization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Optimization'


$BUTTON_TOOLTIP_TEXT = 'Set DNS server to CouldFlare DNS'
$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-Button -UAC 'Setup CloudFlare DNS' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


$CHECKBOX_TOOLTIP = 'Use CloudFlare DNS variation with malware protection (1.1.1.2)'
$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked -ToolTip $CHECKBOX_TOOLTIP
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked } )


$CHECKBOX_TOOLTIP = 'Use CloudFlare DNS variation with malware protection and adult content filtering (1.1.1.3)'
$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering' -ToolTip $CHECKBOX_TOOLTIP


$BUTTON_TOOLTIP_TEXT = 'Perform drive optimization (SSD) or defragmentation (HDD)'
$BUTTON_FUNCTION = { Start-DriveOptimization }
New-Button -UAC 'Optimize / defrag drives' $BUTTON_FUNCTION -ToolTip $BUTTON_TOOLTIP_TEXT > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Startup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Initialize-Startup {
    $FORM.Activate()
    Write-Log "[$((Get-Date).ToString())] Initializing..."

    if ($IS_ELEVATED) {
        Set-Variable -Option Constant IE_Registry_Key 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'
        if (!(Test-Path $IE_Registry_Key)) { New-Item $IE_Registry_Key -Force | Out-Null }
        Set-ItemProperty -Path $IE_Registry_Key -Name "DisableFirstRunCustomize" -Value 1
    }

    Set-Variable -Option Constant -Scope Script PATH_CURRENT_DIR $(Split-Path $MyInvocation.ScriptName)

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

    if (!(Test-Path "$PATH_PROGRAM_FILES_86\Unchecky\unchecky.exe")) {
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
        if (!($CurrentDnsServer -Match '1.1.1.*' -and $CurrentDnsServer -Match '1.0.0.*')) {
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
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    $LOG.SelectionStart = $LOG.TextLength

    Switch ($Level) {
        $WRN { $LOG.SelectionColor = 'blue' }
        $ERR { $LOG.SelectionColor = 'red' }
        Default { $LOG.SelectionColor = 'black' }
    }

    Write-Log "`n[$((Get-Date).ToString())] $Message"
}


Function Write-Log {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$Text)

    Write-Host -NoNewline $Text
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret()
}


Function Out-Status {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$Status)

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

Function Get-ConnectionStatus { if (!(Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

Function Reset-StateOnExit { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_TEMP_DIR; $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

Function Exit-Script { Reset-StateOnExit; $FORM.Close() }


Function Open-InBrowser {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$URL)

    Add-Log $INF "Opening URL in the default browser: $URL"

    try { [System.Diagnostics.Process]::Start($URL) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


Function Start-ExternalProcess {
    Param(
        [String[]][Parameter(Position = 0, Mandatory = $True)]$Commands,
        [String][Parameter(Position = 1)]$Title,
        [Switch]$Elevated,
        [Switch]$Wait,
        [Switch]$Hidden
    )

    if ($Title) { $Commands = , "(Get-Host).UI.RawUI.WindowTitle = '$Title'" + $Commands }
    Set-Variable -Option Constant FullCommand $([String]$($Commands | Where-Object { $_ -ne '' } | ForEach-Object { "$_;" }))

    Start-Process 'PowerShell' "-Command $FullCommand" -Wait:$Wait -Verb:$(if ($Elevated) { 'RunAs' } else { 'Open' }) -WindowStyle:$(if ($Hidden) { 'Hidden' } else { 'Normal' })
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download Extract Execute #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DownloadExtractExecute {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$FileName,
        [String][Parameter(Position = 2)]$Params,
        [Switch]$AVWarning,
        [Switch]$Execute,
        [Switch]$SilentInstall
    )

    if ($AVWarning -and !$AVWarningShown) {
        Add-Log $WRN $TXT_AV_WARNING
        Add-Log $WRN 'Click the button again to continue'
        Set-Variable -Option Constant -Scope Script AVWarningShown $True
        Return
    }

    if ($PS_VERSION -le 2 -and ($URL -Match '*github.com/*' -or $URL -Match '*github.io/*')) { Open-InBrowser $URL }
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
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )

    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $URL })
    Set-Variable -Option Constant TempPath "$PATH_TEMP_DIR\$FileName"
    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$PATH_CURRENT_DIR\$FileName" })

    New-Item -Force -ItemType Directory $PATH_TEMP_DIR | Out-Null

    Add-Log $INF "Downloading from $URL"

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        if (Test-Path $SavePath) { Add-Log $WRN "Previous download found, returning it"; Return $SavePath } else { Return }
    }

    try {
        Remove-Item -Force -ErrorAction SilentlyContinue $SavePath
        (New-Object System.Net.WebClient).DownloadFile($URL, $TempPath)
        if (!$Temp) { Move-Item -Force -ErrorAction SilentlyContinue $TempPath $SavePath }

        if (Test-Path $SavePath) { Out-Success }
        else { Throw 'Possibly computer is offline or disk is full' }
    }
    catch [Exception] { Add-Log $ERR "Download failed: $($_.Exception.Message)"; Return }

    Return $SavePath
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Extract ZIP #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
        [Switch]$Execute
    )

    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
    Set-Variable -Option Constant MultiFileArchive ($ZipName -eq 'AAct.zip' -or `
            $ZipName -eq 'KMSAuto_Lite.zip' -or $URL -Match 'SDI_R' -or $URL -Match 'Victoria')

    Set-Variable -Option Constant ExtractionPath $(if ($MultiFileArchive) { $ZipPath.TrimEnd('.zip') })
    Set-Variable -Option Constant TemporaryPath $(if ($ExtractionPath) { $ExtractionPath } else { $PATH_TEMP_DIR })
    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
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

    if (!$IsDirectory) {
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryExe $TargetExe
        if ($ExtractionPath) { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath }
    }

    if (!$Execute -and $IsDirectory) {
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
        [String][Parameter(Position = 0, Mandatory = $True)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$SilentInstall
    )

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
    if (!$IS_ELEVATED) {
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

    Set-Variable -Option Constant ComponentCleanup $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /StartComponentCleanup'" } else { '' })
    Set-Variable -Option Constant ScanHealth "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /ScanHealth'"
    Set-Variable -Option Constant RestoreHealth $(if ($OS_VERSION -gt 7) { "Start-Process -NoNewWindow -Wait 'DISM' '/Online /Cleanup-Image /RestoreHealth'" } else { '' })
    Set-Variable -Option Constant SFC "Start-Process -NoNewWindow 'sfc' '/scannow'"

    try { Start-ExternalProcess -Elevated -Title:'Checking Windows health...' @($ComponentCleanup, $ScanHealth, $RestoreHealth, $SFC) }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-SecurityScans {
    Set-Variable -Option Constant SignatureUpdate $(if ($OS_VERSION -gt 7 -and (Test-Path $PATH_DEFENDER_EXE)) { "Start-Process -NoNewWindow -Wait '$PATH_DEFENDER_EXE' '-SignatureUpdate'" } else { '' })
    Set-Variable -Option Constant Scan $(if (Test-Path $PATH_DEFENDER_EXE) { "Start-Process -NoNewWindow -Wait '$PATH_DEFENDER_EXE' '-Scan -ScanType 2'" } else { '' })
    Set-Variable -Option Constant MRT "Start-Process -Verb RunAs 'mrt' '/q /f:y'"

    Add-Log $INF "Performing security scans..."
    try { Start-ExternalProcess -Elevated -Title:'Performing security scans...' @($SignatureUpdate, $Scan, $MRT) }
    catch [Exception] { Add-Log $ERR "Failed to perform security scans: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Disk Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DiskCleanup {
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
        "$PATH_PROGRAM_FILES_86\Oracle\VirtualBox\VirtualBox.chm"
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
        "$PATH_PROGRAM_FILES_86\WinRAR\Order.htm"
        "$PATH_PROGRAM_FILES_86\WinRAR\Rar.txt"
        "$PATH_PROGRAM_FILES_86\WinRAR\ReadMe.txt"
        "$PATH_PROGRAM_FILES_86\WinRAR\WhatsNew.txt"
        "$PATH_PROGRAM_FILES_86\WinRAR\WinRAR.chm"
        "$env:ProgramFiles\7-Zip\7-zip.chm"
        "$env:ProgramFiles\7-Zip\7-zip.dll.tmp"
        "$env:ProgramFiles\7-Zip\descript.ion"
        "$env:ProgramFiles\7-Zip\History.txt"
        "$env:ProgramFiles\7-Zip\License.txt"
        "$env:ProgramFiles\7-Zip\readme.txt"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\*.pdf"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\AcroCEF\*.txt"
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
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses\*"
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

    if (!$IS_ELEVATED) {
        Add-Log $WRN 'Removal of certain files requires administrator privileges. To remove them, restart the utility'
        Add-Log $WRN '  as administrator (see Home -> This utility -> Run as administrator) and run this task again.'
    }
    else { Add-Log $INF 'Some files are in use, so they cannot be deleted.' }

    Add-Log $INF $LogMessage
    Out-Success

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

    if (!(Get-NetworkAdapter)) {
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
