Set-Variable -Option Constant Version ([Version]'21.3.28')


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


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Constants #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'

Set-Variable -Option Constant REQUIRES_ELEVATION $(if (-not $IS_ELEVATED) { ' *' })


Set-Variable -Option Constant FORM_WIDTH    670
Set-Variable -Option Constant FORM_HEIGHT   625

Set-Variable -Option Constant BTN_WIDTH     167
Set-Variable -Option Constant BTN_HEIGHT    28

Set-Variable -Option Constant CBOX_WIDTH    145
Set-Variable -Option Constant CBOX_HEIGHT   20

Set-Variable -Option Constant RBTN_WIDTH    80
Set-Variable -Option Constant RBTN_HEIGHT   20

Set-Variable -Option Constant INT_SHORT     5
Set-Variable -Option Constant INT_NORMAL    15
Set-Variable -Option Constant INT_LONG      30
Set-Variable -Option Constant INT_TAB_ADJ   4
Set-Variable -Option Constant INT_GROUP_TOP 20


Set-Variable -Option Constant INT_BTN_SHORT   ($BTN_HEIGHT + $INT_SHORT)
Set-Variable -Option Constant INT_BTN_NORMAL  ($BTN_HEIGHT + $INT_NORMAL)
Set-Variable -Option Constant INT_BTN_LONG    ($BTN_HEIGHT + $INT_LONG)

Set-Variable -Option Constant INT_CBOX_SHORT  ($CBOX_HEIGHT + $INT_SHORT)
Set-Variable -Option Constant INT_CBOX_NORMAL ($CBOX_HEIGHT + $INT_NORMAL)


Set-Variable -Option Constant GRP_WIDTH ($INT_NORMAL + $BTN_WIDTH + $INT_NORMAL)

Set-Variable -Option Constant CBOX_SIZE "$CBOX_WIDTH, $CBOX_HEIGHT"
Set-Variable -Option Constant RBTN_SIZE "$RBTN_WIDTH, $RBTN_HEIGHT"

Set-Variable -Option Constant BTN_INIT_LOCATION "$INT_NORMAL, $INT_GROUP_TOP"
Set-Variable -Option Constant GRP_INIT_LOCATION "$INT_NORMAL, $INT_NORMAL"


Set-Variable -Option Constant SHIFT_BTN_SHORT    "0, $INT_BTN_SHORT"
Set-Variable -Option Constant SHIFT_BTN_NORMAL   "0, $INT_BTN_NORMAL"
Set-Variable -Option Constant SHIFT_BTN_LONG     "0, $INT_BTN_LONG"

Set-Variable -Option Constant SHIFT_CBOX_SHORT   "0, $INT_CBOX_SHORT"
Set-Variable -Option Constant SHIFT_CBOX_NORMAL  "0, $INT_CBOX_NORMAL"
Set-Variable -Option Constant SHIFT_CBOX_EXECUTE "$($INT_LONG - $INT_SHORT), $($INT_BTN_SHORT - $INT_SHORT)"

Set-Variable -Option Constant SHIFT_RBTN_QUICK_SCAN "10, $($INT_BTN_SHORT - $INT_SHORT)"
Set-Variable -Option Constant SHIFT_RBTN_FULL_SCAN  "$RBTN_WIDTH, 0"

Set-Variable -Option Constant SHIFT_GRP_HOR_NORMAL "$($GRP_WIDTH + $INT_NORMAL), 0"

Set-Variable -Option Constant SHIFT_LBL_BROWSER "$INT_LONG, $($INT_BTN_SHORT - $INT_SHORT)"


Set-Variable -Option Constant FONT_NAME 'Microsoft Sans Serif'
Set-Variable -Option Constant BTN_FONT  "$FONT_NAME, 10"


Set-Variable -Option Constant TXT_START_AFTER_DOWNLOAD 'Start after download'
Set-Variable -Option Constant TXT_OPENS_IN_BROWSER 'Opens in the browser'
Set-Variable -Option Constant TXT_UNCHECKY_INFO 'Unchecky clears adware checkboxes when installing software'
Set-Variable -Option Constant TXT_AV_WARNING "This file may trigger anti-virus false positive!`nIt is recommended to disable anti-virus software for download and subsequent use of this file!"

Set-Variable -Option Constant TIP_START_AFTER_DOWNLOAD "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"

Set-Variable -Option Constant TEMP_DIR "$env:TMP\qiiwexc"


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant FORM        (New-Object System.Windows.Forms.Form)
Set-Variable -Option Constant LOG         (New-Object System.Windows.Forms.RichTextBox)
Set-Variable -Option Constant TAB_CONTROL (New-Object System.Windows.Forms.TabControl)

Set-Variable -Option Constant TAB_HOME        (New-Object System.Windows.Forms.TabPage)
Set-Variable -Option Constant TAB_DOWNLOADS   (New-Object System.Windows.Forms.TabPage)
Set-Variable -Option Constant TAB_MAINTENANCE (New-Object System.Windows.Forms.TabPage)

$TAB_HOME.UseVisualStyleBackColor = $TAB_DOWNLOADS.UseVisualStyleBackColor = $TAB_MAINTENANCE.UseVisualStyleBackColor = $True

$TAB_CONTROL.Controls.AddRange(@($TAB_HOME, $TAB_DOWNLOADS, $TAB_MAINTENANCE))
$FORM.Controls.AddRange(@($LOG, $TAB_CONTROL))



$FORM.Text = "qiiwexc v$VERSION"
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )
$FORM.Add_FormClosing( { Reset-StateOnExit } )


$LOG.Height = 200
$LOG.Width = - $INT_SHORT + $FORM_WIDTH - $INT_SHORT
$LOG.Location = "$INT_SHORT, $($FORM_HEIGHT - $LOG.Height - $INT_SHORT)"
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True


$TAB_CONTROL.Size = "$($LOG.Width + $INT_SHORT - $INT_TAB_ADJ), $($FORM_HEIGHT - $LOG.Height - $INT_SHORT - $INT_TAB_ADJ)"
$TAB_CONTROL.Location = "$INT_SHORT, $INT_SHORT"


$TAB_HOME.Text = 'Home'
$TAB_DOWNLOADS.Text = 'Downloads'
$TAB_MAINTENANCE.Text = 'Maintenance'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - General #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_General (New-Object System.Windows.Forms.GroupBox)
$GRP_General.Text = 'General'
$GRP_General.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 2
$GRP_General.Width = $GRP_WIDTH
$GRP_General.Location = $GRP_INIT_LOCATION
$TAB_HOME.Controls.Add($GRP_General)

Set-Variable -Option Constant BTN_Elevate    (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_SystemInfo (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInfo, 'Print system information to the log')

$BTN_Elevate.Font = $BTN_SystemInfo.Font = $BTN_FONT
$BTN_Elevate.Height = $BTN_SystemInfo.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_SystemInfo.Width = $BTN_WIDTH

$GRP_General.Controls.AddRange(@($BTN_Elevate, $BTN_SystemInfo))



$BTN_Elevate.Text = "Run as administrator$REQUIRES_ELEVATION"
$BTN_Elevate.Location = $BTN_INIT_LOCATION
$BTN_Elevate.Add_Click( { Start-Elevated } )


$BTN_SystemInfo.Text = 'System information'
$BTN_SystemInfo.Location = $BTN_Elevate.Location + $SHIFT_BTN_NORMAL
$BTN_SystemInfo.Add_Click( { Out-SystemInfo } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Activators #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Activators (New-Object System.Windows.Forms.GroupBox)
$GRP_Activators.Text = 'Activators'
$GRP_Activators.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_Activators.Width = $GRP_WIDTH
$GRP_Activators.Location = $GRP_General.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_Activators)

Set-Variable -Option Constant BTN_DownloadKMSAuto (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartKMSAuto   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadAAct    (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartAAct      (New-Object System.Windows.Forms.CheckBox)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMSAuto, "Download KMSAuto Lite`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadAAct, "Download AAct`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartKMSAuto, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartAAct, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadKMSAuto.Font = $BTN_DownloadAAct.Font = $BTN_FONT
$BTN_DownloadKMSAuto.Height = $BTN_DownloadAAct.Height = $BTN_HEIGHT
$BTN_DownloadKMSAuto.Width = $BTN_DownloadAAct.Width = $BTN_WIDTH

$CBOX_StartKMSAuto.Checked = $CBOX_StartAAct.Checked = $True
$CBOX_StartKMSAuto.Size = $CBOX_StartAAct.Size = $CBOX_SIZE
$CBOX_StartKMSAuto.Text = $CBOX_StartAAct.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_Activators.Controls.AddRange(@($BTN_DownloadKMSAuto, $CBOX_StartKMSAuto, $BTN_DownloadAAct, $CBOX_StartAAct))



$BTN_DownloadKMSAuto.Text = "KMSAuto Lite$REQUIRES_ELEVATION"
$BTN_DownloadKMSAuto.Location = $BTN_INIT_LOCATION
$BTN_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CBOX_StartKMSAuto.Checked 'qiiwexc.github.io/d/KMSAuto_Lite.zip' } )

$CBOX_StartKMSAuto.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartKMSAuto.Add_CheckStateChanged( { $BTN_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$REQUIRES_ELEVATION"
$BTN_DownloadAAct.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_BTN_LONG
$BTN_DownloadAAct.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CBOX_StartAAct.Checked 'qiiwexc.github.io/d/AAct.zip' } )

$CBOX_StartAAct.Location = $BTN_DownloadAAct.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartAAct.Add_CheckStateChanged( { $BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Windows Images #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_DownloadWindows (New-Object System.Windows.Forms.GroupBox)
$GRP_DownloadWindows.Text = 'Windows Images'
$GRP_DownloadWindows.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_DownloadWindows.Width = $GRP_WIDTH
$GRP_DownloadWindows.Location = $GRP_Activators.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_DownloadWindows)

Set-Variable -Option Constant BTN_Windows10 (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_Windows10 (New-Object System.Windows.Forms.Label)

Set-Variable -Option Constant BTN_Windows7  (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_Windows7  (New-Object System.Windows.Forms.Label)

Set-Variable -Option Constant BTN_WindowsXP (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_WindowsXP (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows10, 'Download Windows 10 (v20H2) RUS-ENG x86-x64 -28in1- HWID-act (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXP, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')

$BTN_Windows10.Font = $BTN_Windows7.Font = $BTN_WindowsXP.Font = $BTN_FONT
$BTN_Windows10.Height = $BTN_Windows7.Height = $BTN_WindowsXP.Height = $BTN_HEIGHT
$BTN_Windows10.Width = $BTN_Windows7.Width = $BTN_WindowsXP.Width = $BTN_WIDTH

$LBL_Windows10.Size = $LBL_Windows7.Size = $LBL_WindowsXP.Size = $CBOX_SIZE
$LBL_Windows10.Text = $LBL_Windows7.Text = $LBL_WindowsXP.Text = $TXT_OPENS_IN_BROWSER

$GRP_DownloadWindows.Controls.AddRange(@($BTN_Windows10, $LBL_Windows10, $BTN_Windows7, $LBL_Windows7, $BTN_WindowsXP, $LBL_WindowsXP))



$BTN_Windows10.Text = 'Windows 10 (v20H2)'
$BTN_Windows10.Location = $BTN_INIT_LOCATION
$BTN_Windows10.Add_Click( { Open-InBrowser 'http://monkrus.ws/2020/11/windows-10-v20h2-rus-eng-x86-x64-28in1.html' } )

$LBL_Windows10.Location = $BTN_Windows10.Location + $SHIFT_LBL_BROWSER

$BTN_Windows7.Text = 'Windows 7 SP1'
$BTN_Windows7.Location = $BTN_Windows10.Location + $SHIFT_BTN_LONG
$BTN_Windows7.Add_Click( { Open-InBrowser 'http://monkrus.ws/2020/02/windows-7-sp1-rus-eng-x86-x64-18in1.html' } )

$LBL_Windows7.Location = $BTN_Windows7.Location + $SHIFT_LBL_BROWSER

$BTN_WindowsXP.Text = 'Windows XP SP3 (ENG)'
$BTN_WindowsXP.Location = $BTN_Windows7.Location + $SHIFT_BTN_LONG
$BTN_WindowsXP.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF' } )

$LBL_WindowsXP.Location = $BTN_WindowsXP.Location + $SHIFT_LBL_BROWSER


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Tools #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Tools (New-Object System.Windows.Forms.GroupBox)
$GRP_Tools.Text = 'Tools'
$GRP_Tools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Tools.Width = $GRP_WIDTH
$GRP_Tools.Location = $GRP_General.Location + "0, $($GRP_General.Height + $INT_NORMAL)"
$TAB_HOME.Controls.Add($GRP_Tools)

Set-Variable -Option Constant BTN_DownloadCCleaner (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartCCleaner   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadRufus    (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartRufus      (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_WindowsPE        (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_WindowsPE        (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartCCleaner, $TIP_START_AFTER_DOWNLOAD)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 10')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRufus, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadCCleaner.Font = $BTN_DownloadRufus.Font = $BTN_WindowsPE.Font = $BTN_FONT
$BTN_DownloadCCleaner.Height = $BTN_DownloadRufus.Height = $BTN_WindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_DownloadRufus.Width = $BTN_WindowsPE.Width = $BTN_WIDTH
$CBOX_StartCCleaner.Size = $CBOX_StartRufus.Size = $LBL_WindowsPE.Size = $CBOX_SIZE

$GRP_Tools.Controls.AddRange(@($BTN_DownloadCCleaner, $CBOX_StartCCleaner, $BTN_DownloadRufus, $CBOX_StartRufus, $BTN_WindowsPE, $LBL_WindowsPE))



$BTN_DownloadCCleaner.Text = "CCleaner$REQUIRES_ELEVATION"
$BTN_DownloadCCleaner.Location = $BTN_INIT_LOCATION
$BTN_DownloadCCleaner.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartCCleaner.Checked 'download.ccleaner.com/ccsetup.exe' } )

$CBOX_StartCCleaner.Checked = $True
$CBOX_StartCCleaner.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartCCleaner.Location = $BTN_DownloadCCleaner.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartCCleaner.Add_CheckStateChanged( { $BTN_DownloadCCleaner.Text = "CCleaner$(if ($CBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRufus.Text = "Rufus (bootable USB)$REQUIRES_ELEVATION"
$BTN_DownloadRufus.Location = $BTN_DownloadCCleaner.Location + $SHIFT_BTN_LONG
$BTN_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartRufus.Checked 'github.com/pbatard/rufus/releases/download/v3.13/rufus-3.13p.exe' -Params:'-g' } )

$CBOX_StartRufus.Location = $BTN_DownloadRufus.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartRufus.Checked = $True
$CBOX_StartRufus.Add_CheckStateChanged( { $BTN_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_WindowsPE.Text = 'Windows PE (Live CD)'
$BTN_WindowsPE.Location = $BTN_DownloadRufus.Location + $SHIFT_BTN_LONG
$BTN_WindowsPE.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_' } )

$LBL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsPE.Location = $BTN_WindowsPE.Location + $SHIFT_LBL_BROWSER


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Chrome Extension #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_ChromeExtensions (New-Object System.Windows.Forms.GroupBox)
$GRP_ChromeExtensions.Text = 'Chrome Extensions'
$GRP_ChromeExtensions.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 2
$GRP_ChromeExtensions.Width = $GRP_WIDTH
$GRP_ChromeExtensions.Location = $GRP_Activators.Location + "0, $($GRP_Activators.Height + $INT_NORMAL)"
$TAB_HOME.Controls.Add($GRP_ChromeExtensions)

Set-Variable -Option Constant BTN_HTTPSEverywhere (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_AdBlock         (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_HTTPSEverywhere, 'Automatically use HTTPS security on many sites')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_AdBlock, 'Block ads and pop-ups on websites')

$BTN_HTTPSEverywhere.Font = $BTN_AdBlock.Font = $BTN_FONT
$BTN_HTTPSEverywhere.Height = $BTN_AdBlock.Height = $BTN_HEIGHT
$BTN_HTTPSEverywhere.Width = $BTN_AdBlock.Width = $BTN_WIDTH

$GRP_ChromeExtensions.Controls.AddRange(@($BTN_HTTPSEverywhere, $BTN_AdBlock))


$BTN_HTTPSEverywhere.Text = 'HTTPS Everywhere'
$BTN_HTTPSEverywhere.Location = $BTN_INIT_LOCATION
$BTN_HTTPSEverywhere.Add_Click( { Start-Process $ChromeExe 'https://chrome.google.com/webstore/detail/gcbommkclmclpchllfjekcdonpmejbdp' } )

$BTN_AdBlock.Text = 'AdBlock'
$BTN_AdBlock.Location = $BTN_HTTPSEverywhere.Location + $SHIFT_BTN_NORMAL
$BTN_AdBlock.Add_Click( { Start-Process $ChromeExe 'https://chrome.google.com/webstore/detail/gighmmpiobklfepjocnamgkkbiglidom' } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Ninite (New-Object System.Windows.Forms.GroupBox)
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_GROUP_TOP + $INT_CBOX_SHORT * 7 + $INT_SHORT + $INT_BTN_LONG * 2
$GRP_Ninite.Width = $GRP_WIDTH
$GRP_Ninite.Location = $GRP_INIT_LOCATION
$TAB_DOWNLOADS.Controls.Add($GRP_Ninite)

Set-Variable -Option Constant CBOX_Chrome        (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_7zip          (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_VLC           (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_TeamViewer    (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_Skype         (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_qBittorrent   (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_Malwarebytes  (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadNinite (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartNinite   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_OpenNiniteInBrowser (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_OpenNiniteInBrowser (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadNinite, 'Download Ninite universal installer for selected applications')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartNinite, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadNinite.Font = $BTN_OpenNiniteInBrowser.Font = $BTN_FONT
$BTN_DownloadNinite.Height = $BTN_OpenNiniteInBrowser.Height = $BTN_HEIGHT
$BTN_DownloadNinite.Width = $BTN_OpenNiniteInBrowser.Width = $BTN_WIDTH

$CBOX_Chrome.Checked = $CBOX_7zip.Checked = $CBOX_VLC.Checked = $CBOX_TeamViewer.Checked = $CBOX_StartNinite.Checked = $True
$CBOX_Chrome.Size = $CBOX_7zip.Size = $CBOX_VLC.Size = $CBOX_TeamViewer.Size = $CBOX_Skype.Size = `
    $CBOX_qBittorrent.Size = $CBOX_Malwarebytes.Size = $CBOX_StartNinite.Size = $LBL_OpenNiniteInBrowser.Size = $CBOX_SIZE

$GRP_Ninite.Controls.AddRange(
    @($BTN_DownloadNinite, $BTN_OpenNiniteInBrowser, $LBL_OpenNiniteInBrowser, $CBOX_StartNinite,
        $CBOX_7zip, $CBOX_VLC, $CBOX_TeamViewer, $CBOX_Skype, $CBOX_Chrome, $CBOX_qBittorrent, $CBOX_Malwarebytes)
)



$CBOX_Chrome.Text = 'Google Chrome'
$CBOX_Chrome.Name = 'chrome'
$CBOX_Chrome.Location = $BTN_INIT_LOCATION
$CBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_7zip.Text = '7-Zip'
$CBOX_7zip.Name = '7zip'
$CBOX_7zip.Location = $CBOX_Chrome.Location + $SHIFT_CBOX_SHORT
$CBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VLC.Text = 'VLC'
$CBOX_VLC.Name = 'vlc'
$CBOX_VLC.Location = $CBOX_7zip.Location + $SHIFT_CBOX_SHORT
$CBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_TeamViewer.Text = 'TeamViewer'
$CBOX_TeamViewer.Name = 'teamviewer15'
$CBOX_TeamViewer.Location = $CBOX_VLC.Location + $SHIFT_CBOX_SHORT
$CBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_Skype.Text = 'Skype'
$CBOX_Skype.Name = 'skype'
$CBOX_Skype.Location = $CBOX_TeamViewer.Location + $SHIFT_CBOX_SHORT
$CBOX_Skype.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_qBittorrent.Text = 'qBittorrent'
$CBOX_qBittorrent.Name = 'qbittorrent'
$CBOX_qBittorrent.Location = $CBOX_Skype.Location + $SHIFT_CBOX_SHORT
$CBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_Malwarebytes.Text = 'Malwarebytes'
$CBOX_Malwarebytes.Name = 'malwarebytes'
$CBOX_Malwarebytes.Location = $CBOX_qBittorrent.Location + $SHIFT_CBOX_SHORT
$CBOX_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )


$BTN_DownloadNinite.Text = "Download selected$REQUIRES_ELEVATION"
$BTN_DownloadNinite.Location = $CBOX_Malwarebytes.Location + $SHIFT_BTN_SHORT
$BTN_DownloadNinite.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartNinite.Checked "ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) } )

$CBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartNinite.Location = $BTN_DownloadNinite.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartNinite.Add_CheckStateChanged( { $BTN_DownloadNinite.Text = "Download selected$(if ($CBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_OpenNiniteInBrowser.Text = 'View other'
$BTN_OpenNiniteInBrowser.Location = $BTN_DownloadNinite.Location + $SHIFT_BTN_LONG
$BTN_OpenNiniteInBrowser.Add_Click( {
        Set-Variable -Option Constant Query (Set-NiniteQuery); Open-InBrowser $(if ($Query) { "ninite.com/?select=$($Query)" } else { 'ninite.com' })
    } )

$LBL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_OpenNiniteInBrowser.Location = $BTN_OpenNiniteInBrowser.Location + $SHIFT_LBL_BROWSER


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Essentials #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Essentials (New-Object System.Windows.Forms.GroupBox)
$GRP_Essentials.Text = 'Essentials'
$GRP_Essentials.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3 + $INT_CBOX_SHORT - $INT_SHORT
$GRP_Essentials.Width = $GRP_WIDTH
$GRP_Essentials.Location = $GRP_Ninite.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DOWNLOADS.Controls.Add($GRP_Essentials)

Set-Variable -Option Constant BTN_DownloadSDI (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartSDI   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadUnchecky         (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartUnchecky           (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_SilentlyInstallUnchecky (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadOffice (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartOffice   (New-Object System.Windows.Forms.CheckBox)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadSDI, 'Download Snappy Driver Installer')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadUnchecky, "Download Unchecky installer`n$TXT_UNCHECKY_INFO")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadOffice, "Download Microsoft Office 2013 - 2019 C2R installer and activator`n`n$TXT_AV_WARNING")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_SilentlyInstallUnchecky, 'Perform silent installation with no prompts')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartSDI, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartUnchecky, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartOffice, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadSDI.Font = $BTN_DownloadUnchecky.Font = $BTN_DownloadOffice.Font = $BTN_FONT
$BTN_DownloadSDI.Height = $BTN_DownloadUnchecky.Height = $BTN_DownloadOffice.Height = $BTN_HEIGHT
$BTN_DownloadSDI.Width = $BTN_DownloadUnchecky.Width = $BTN_DownloadOffice.Width = $BTN_WIDTH

$CBOX_StartSDI.Checked = $CBOX_StartUnchecky.Checked = $CBOX_StartOffice.Checked = $CBOX_SilentlyInstallUnchecky.Checked = $True
$CBOX_StartSDI.Size = $CBOX_StartUnchecky.Size = $CBOX_StartOffice.Size = $CBOX_SilentlyInstallUnchecky.Size = $CBOX_SIZE
$CBOX_StartSDI.Text = $CBOX_StartUnchecky.Text = $CBOX_StartOffice.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_Essentials.Controls.AddRange(
    @($BTN_DownloadSDI, $CBOX_StartSDI, $BTN_DownloadUnchecky, $CBOX_StartUnchecky, $CBOX_SilentlyInstallUnchecky, $BTN_DownloadOffice, $CBOX_StartOffice)
)



$BTN_DownloadSDI.Text = "Snappy Driver Installer$REQUIRES_ELEVATION"
$BTN_DownloadSDI.Location = $BTN_INIT_LOCATION
$BTN_DownloadSDI.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartSDI.Checked 'sdi-tool.org/releases/SDI_R2102.zip' } )

$CBOX_StartSDI.Location = $BTN_DownloadSDI.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartSDI.Add_CheckStateChanged( { $BTN_DownloadSDI.Text = "Snappy Driver Installer$(if ($CBOX_StartSDI.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadUnchecky.Text = "Unchecky$REQUIRES_ELEVATION"
$BTN_DownloadUnchecky.Location = $BTN_DownloadSDI.Location + $SHIFT_BTN_LONG
$BTN_DownloadUnchecky.Add_Click( {
        Set-Variable -Option Constant Params $(if ($CBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
        Start-DownloadExtractExecute -Execute:$CBOX_StartUnchecky.Checked 'unchecky.com/files/unchecky_setup.exe' -Params:$Params -SilentInstall:$CBOX_SilentlyInstallUnchecky.Checked
    } )

$CBOX_StartUnchecky.Location = $BTN_DownloadUnchecky.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartUnchecky.Add_CheckStateChanged( { $CBOX_SilentlyInstallUnchecky.Enabled = $CBOX_StartUnchecky.Checked } )

$CBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CBOX_SilentlyInstallUnchecky.Location = $CBOX_StartUnchecky.Location + "0, $CBOX_HEIGHT"
$CBOX_StartUnchecky.Add_CheckStateChanged( { $BTN_DownloadUnchecky.Text = "Unchecky$(if ($CBOX_StartUnchecky.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadOffice.Text = "Office 2013 - 2019$REQUIRES_ELEVATION"
$BTN_DownloadOffice.Location = $BTN_DownloadUnchecky.Location + $SHIFT_BTN_SHORT + $SHIFT_BTN_NORMAL
$BTN_DownloadOffice.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CBOX_StartOffice.Checked 'qiiwexc.github.io/d/Office_2013-2019.zip' } )

$CBOX_StartOffice.Location = $BTN_DownloadOffice.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartOffice.Add_CheckStateChanged( { $BTN_DownloadOffice.Text = "Office 2013 - 2019$(if ($CBOX_StartOffice.Checked) {$REQUIRES_ELEVATION})" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Updates #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Updates (New-Object System.Windows.Forms.GroupBox)
$GRP_Updates.Text = 'Updates'
$GRP_Updates.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Updates.Width = $GRP_WIDTH
$GRP_Updates.Location = $GRP_Essentials.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DOWNLOADS.Controls.Add($GRP_Updates)

Set-Variable -Option Constant BTN_UpdateStoreApps (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_UpdateOffice    (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_WindowsUpdate   (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateStoreApps, 'Update Microsoft Store apps')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateOffice, 'Update Microsoft Office (for C2R installations only)')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsUpdate, 'Check for Windows updates, download and install if available')

$BTN_UpdateStoreApps.Font = $BTN_UpdateOffice.Font = $BTN_WindowsUpdate.Font = $BTN_FONT
$BTN_UpdateStoreApps.Height = $BTN_UpdateOffice.Height = $BTN_WindowsUpdate.Height = $BTN_HEIGHT
$BTN_UpdateStoreApps.Width = $BTN_UpdateOffice.Width = $BTN_WindowsUpdate.Width = $BTN_WIDTH

$GRP_Updates.Controls.AddRange(@($BTN_UpdateStoreApps, $BTN_UpdateOffice, $BTN_WindowsUpdate))



$BTN_UpdateStoreApps.Text = "Update Store apps$REQUIRES_ELEVATION"
$BTN_UpdateStoreApps.Location = $BTN_INIT_LOCATION
$BTN_UpdateStoreApps.Add_Click( { Start-StoreAppUpdate } )


$BTN_UpdateOffice.Text = "Update Microsoft Office"
$BTN_UpdateOffice.Location = $BTN_UpdateStoreApps.Location + $SHIFT_BTN_NORMAL
$BTN_UpdateOffice.Add_Click( { Start-OfficeUpdate } )


$BTN_WindowsUpdate.Text = 'Start Windows Update'
$BTN_WindowsUpdate.Location = $BTN_UpdateOffice.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsUpdate.Add_Click( { Start-WindowsUpdate } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Hardware Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Hardware (New-Object System.Windows.Forms.GroupBox)
$GRP_Hardware.Text = 'Hardware Diagnostics'
$GRP_Hardware.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2 + $INT_BTN_NORMAL
$GRP_Hardware.Width = $GRP_WIDTH
$GRP_Hardware.Location = $GRP_INIT_LOCATION
$TAB_MAINTENANCE.Controls.Add($GRP_Hardware)

Set-Variable -Option Constant BTN_CheckDisk        (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant RBTN_QuickDiskCheck  (New-Object System.Windows.Forms.RadioButton)
Set-Variable -Option Constant RBTN_FullDiskCheck   (New-Object System.Windows.Forms.RadioButton)

Set-Variable -Option Constant BTN_DownloadVictoria (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartVictoria   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_CheckRAM         (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDisk, 'Start (C:) disk health check')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_QuickDiskCheck, 'Perform a quick disk scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_FullDiskCheck, 'Schedule a full disk scan on next restart')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartVictoria, $TIP_START_AFTER_DOWNLOAD)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckRAM, 'Start RAM checking utility')

$BTN_CheckDisk.Font = $BTN_DownloadVictoria.Font = $BTN_CheckRAM.Font = $BTN_FONT
$BTN_CheckDisk.Height = $BTN_DownloadVictoria.Height = $BTN_CheckRAM.Height = $BTN_HEIGHT
$BTN_CheckDisk.Width = $BTN_DownloadVictoria.Width = $BTN_CheckRAM.Width = $BTN_WIDTH

$CBOX_StartVictoria.Checked = $RBTN_QuickDiskCheck.Checked = $True
$CBOX_StartVictoria.Size = $CBOX_SIZE
$RBTN_QuickDiskCheck.Size = $RBTN_FullDiskCheck.Size = $RBTN_SIZE
$CBOX_StartVictoria.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_Hardware.Controls.AddRange(
    @($BTN_CheckDisk, $RBTN_QuickDiskCheck, $RBTN_FullDiskCheck,
        $BTN_DownloadVictoria, $CBOX_StartVictoria, $BTN_CheckRAM)
)



$BTN_CheckDisk.Text = "Check (C:) disk health$REQUIRES_ELEVATION"
$BTN_CheckDisk.Location = $BTN_INIT_LOCATION
$BTN_CheckDisk.Add_Click( { Start-DiskCheck $RBTN_FullDiskCheck.Checked } )

$RBTN_QuickDiskCheck.Text = 'Quick scan'
$RBTN_QuickDiskCheck.Location = $BTN_CheckDisk.Location + $SHIFT_RBTN_QUICK_SCAN

$RBTN_FullDiskCheck.Text = 'Full scan'
$RBTN_FullDiskCheck.Location = $RBTN_QuickDiskCheck.Location + $SHIFT_RBTN_FULL_SCAN


$BTN_DownloadVictoria.Text = "Victoria (HDD scan)$REQUIRES_ELEVATION"
$BTN_DownloadVictoria.Location = $BTN_CheckDisk.Location + $SHIFT_BTN_LONG
$BTN_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartVictoria.Checked 'hdd.by/Victoria/Victoria536.zip' } )

$CBOX_StartVictoria.Location = $BTN_DownloadVictoria.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartVictoria.Add_CheckStateChanged( { $BTN_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_CheckRAM.Text = 'RAM checking utility'
$BTN_CheckRAM.Location = $BTN_DownloadVictoria.Location + $SHIFT_BTN_LONG
$BTN_CheckRAM.Add_Click( { Start-MemoryCheckTool } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Software Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Software (New-Object System.Windows.Forms.GroupBox)
$GRP_Software.Text = 'Software Diagnostics'
$GRP_Software.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 4
$GRP_Software.Width = $GRP_WIDTH
$GRP_Software.Location = $GRP_Hardware.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Software)

Set-Variable -Option Constant BTN_CheckWindowsHealth (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_RepairWindows      (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_CheckSystemFiles   (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_StartSecurityScan  (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWindowsHealth, 'Check Windows health')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RepairWindows, 'Attempt to restore Windows health')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckSystemFiles, 'Check system file integrity')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StartSecurityScan, 'Start security scan')

$BTN_CheckWindowsHealth.Font = $BTN_RepairWindows.Font = $BTN_CheckSystemFiles.Font = $BTN_StartSecurityScan.Font = $BTN_FONT
$BTN_CheckWindowsHealth.Height = $BTN_RepairWindows.Height = $BTN_CheckSystemFiles.Height = $BTN_StartSecurityScan.Height = $BTN_HEIGHT
$BTN_CheckWindowsHealth.Width = $BTN_RepairWindows.Width = $BTN_CheckSystemFiles.Width = $BTN_StartSecurityScan.Width = $BTN_WIDTH

$GRP_Software.Controls.AddRange(@($BTN_CheckWindowsHealth, $BTN_RepairWindows, $BTN_CheckSystemFiles, $BTN_StartSecurityScan))



$BTN_CheckWindowsHealth.Text = "Check Windows health$REQUIRES_ELEVATION"
$BTN_CheckWindowsHealth.Location = $BTN_INIT_LOCATION
$BTN_CheckWindowsHealth.Add_Click( { Test-WindowsHealth } )


$BTN_RepairWindows.Text = "Repair Windows$REQUIRES_ELEVATION"
$BTN_RepairWindows.Location = $BTN_CheckWindowsHealth.Location + $SHIFT_BTN_NORMAL
$BTN_RepairWindows.Add_Click( { Repair-Windows } )


$BTN_CheckSystemFiles.Text = "Check system files$REQUIRES_ELEVATION"
$BTN_CheckSystemFiles.Location = $BTN_RepairWindows.Location + $SHIFT_BTN_NORMAL
$BTN_CheckSystemFiles.Add_Click( { Repair-SystemFiles } )


$BTN_StartSecurityScan.Text = 'Perform a security scan'
$BTN_StartSecurityScan.Location = $BTN_CheckSystemFiles.Location + $SHIFT_BTN_NORMAL
$BTN_StartSecurityScan.Add_Click( { Start-SecurityScan } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Cleanup (New-Object System.Windows.Forms.GroupBox)
$GRP_Cleanup.Text = 'Cleanup'
$GRP_Cleanup.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 2
$GRP_Cleanup.Width = $GRP_WIDTH
$GRP_Cleanup.Location = $GRP_Software.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Cleanup)

Set-Variable -Option Constant BTN_FileCleanup (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_DiskCleanup (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_FileCleanup, 'Remove temporary files, some log files and empty directories, and some other unnecessary files')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DiskCleanup, 'Start Windows built-in disk cleanup utility')

$BTN_FileCleanup.Font = $BTN_DiskCleanup.Font = $BTN_FONT
$BTN_FileCleanup.Height = $BTN_DiskCleanup.Height = $BTN_HEIGHT
$BTN_FileCleanup.Width = $BTN_DiskCleanup.Width = $BTN_WIDTH

$GRP_Cleanup.Controls.AddRange(@($BTN_FileCleanup, $BTN_DiskCleanup))



$BTN_FileCleanup.Text = "File cleanup$REQUIRES_ELEVATION"
$BTN_FileCleanup.Location = $BTN_INIT_LOCATION
$BTN_FileCleanup.Add_Click( { Start-FileCleanup } )


$BTN_DiskCleanup.Text = 'Start disk cleanup'
$BTN_DiskCleanup.Location = $BTN_FileCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_DiskCleanup.Add_Click( { Start-DiskCleanup } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Optimization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant GRP_Optimization (New-Object System.Windows.Forms.GroupBox)
$GRP_Optimization.Text = 'Optimization'
$GRP_Optimization.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL + $INT_BTN_LONG + $INT_CBOX_SHORT - $INT_SHORT
$GRP_Optimization.Width = $GRP_WIDTH
$GRP_Optimization.Location = $GRP_Cleanup.Location + "0, $($GRP_Cleanup.Height + $INT_NORMAL)"
$TAB_MAINTENANCE.Controls.Add($GRP_Optimization)

Set-Variable -Option Constant BTN_CloudFlareDNS             (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_CloudFlareAntiMalware    (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_CloudFlareFamilyFriendly (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_OptimizeDrive (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_RunDefraggler (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS server to CouldFlare DNS')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_CloudFlareAntiMalware, 'Use CloudFlare DNS variation with malware protection (1.1.1.2)')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_CloudFlareFamilyFriendly, 'Use CloudFlare DNS variation with malware protection and adult content filtering (1.1.1.3)')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')

$BTN_CloudFlareDNS.Font = $BTN_OptimizeDrive.Font = $BTN_FONT
$BTN_CloudFlareDNS.Height = $BTN_OptimizeDrive.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_OptimizeDrive.Width = $BTN_WIDTH
$CBOX_CloudFlareAntiMalware.Size = $CBOX_CloudFlareFamilyFriendly.Size = $CBOX_SIZE

$GRP_Optimization.Controls.AddRange(@($BTN_CloudFlareDNS, $CBOX_CloudFlareAntiMalware, $CBOX_CloudFlareFamilyFriendly, $BTN_OptimizeDrive))



$BTN_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BTN_CloudFlareDNS.Location = $BTN_INIT_LOCATION
$BTN_CloudFlareDNS.Add_Click( { Set-CloudFlareDNS } )

$CBOX_CloudFlareAntiMalware.Text = 'Malware protection'
$CBOX_CloudFlareAntiMalware.Checked = $True
$CBOX_CloudFlareAntiMalware.Location = $BTN_CloudFlareDNS.Location + "$($INT_LONG - $INT_SHORT), $($INT_BTN_SHORT - $INT_SHORT)"
$CBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CBOX_CloudFlareFamilyFriendly.Enabled = $CBOX_CloudFlareAntiMalware.Checked } )

$CBOX_CloudFlareFamilyFriendly.Text = 'Adult content filtering'
$CBOX_CloudFlareFamilyFriendly.Location = $CBOX_CloudFlareAntiMalware.Location + "0, $CBOX_HEIGHT"


$BTN_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BTN_OptimizeDrive.Location = $BTN_CloudFlareDNS.Location + $SHIFT_BTN_SHORT + $SHIFT_BTN_NORMAL
$BTN_OptimizeDrive.Add_Click( { Start-DriveOptimization } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Startup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Initialize-Startup {
    $FORM.Activate()
    Write-Log "[$((Get-Date).ToString())] Initializing..."

    if ($IS_ELEVATED) {
        $FORM.Text = "$($FORM.Text): Administrator"
        $BTN_Elevate.Text = 'Running as administrator'
        $BTN_Elevate.Enabled = $False
    }

    Get-SystemInfo

    $CBOX_StartAAct.Checked = $CBOX_StartAAct.Enabled = $CBOX_StartKMSAuto.Checked = $CBOX_StartKMSAuto.Enabled = `
        $CBOX_StartOffice.Checked = $CBOX_StartOffice.Enabled = $CBOX_StartRufus.Checked = $CBOX_StartRufus.Enabled = `
        $CBOX_StartVictoria.Checked = $CBOX_StartVictoria.Enabled = $PS_VERSION -gt 2

    $BTN_RepairWindows.Enabled = $BTN_UpdateStoreApps.Enabled = $OS_VERSION -gt 7
    $BTN_StartSecurityScan.Enabled = Test-Path $DefenderExe

    Set-ButtonState

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

    if (-not (Test-Path "$PROGRAM_FILES_86\Unchecky\unchecky.exe")) {
        Add-Log $WRN 'Unchecky is not installed.'
        Add-Log $INF 'It is highly recommended to install Unchecky (see Downloads -> Essentials -> Unchecky).'
        Add-Log $INF "$TXT_UNCHECKY_INFO."
    }

    if ($OfficeInstallType -eq 'MSI' -and $OfficeVersion -ge 15) {
        Add-Log $WRN 'MSI installation of Microsoft Office is detected.'
        Add-Log $INF 'It is highly recommended to install Click-To-Run (C2R) version instead'
        Add-Log $INF '  (see Downloads -> Essentials -> Office 2013 - 2019).'
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

    try { Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest 'https://qiiwexc.github.io/d/version').ToString()) }
    catch [Exception] { Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"; Return }

    if ($LatestVersion -gt $VERSION) { Add-Log $WRN "Newer version available: v$LatestVersion"; Get-Update }
    else { Out-Status 'No updates available' }
}


Function Get-Update {
    Set-Variable -Option Constant DownloadURL 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    Set-Variable -Option Constant TargetFile $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) { Add-Log $ERR "Failed to download update: $IsNotConnected"; Return }

    try { Invoke-WebRequest $DownloadURL -OutFile $TargetFile }
    catch [Exception] { Add-Log $ERR "Failed to download update: $($_.Exception.Message)"; Return }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try { Start-Process 'PowerShell' $TargetFile }
    catch [Exception] { Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"; Return }

    Exit-Script
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Common #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Get-FreeDiskSpace { Return ($SystemPartition.FreeSpace / $SystemPartition.Size) }

Function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }

Function Get-ConnectionStatus { if (-not (Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

Function Reset-StateOnExit { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $TEMP_DIR; $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

Function Exit-Script { Reset-StateOnExit; $FORM.Close() }

Function Open-InBrowser {
    Param([String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"))
    if (-not $URL) { Return }

    Set-Variable -Option Constant UrlToOpen $(if ($URL -like 'http*') { $URL } else { 'https://' + $URL })
    Add-Log $INF "Opening URL in the default browser: $UrlToOpen"

    try { [System.Diagnostics.Process]::Start($UrlToOpen) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


Function Set-ButtonState {
    $BTN_UpdateOffice.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_HTTPSEverywhere.Enabled = $BTN_AdBlock.Enabled = Test-Path $ChromeExe
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
        Set-Variable -Option Constant IsZip ($URL.Substring($URL.Length - 4) -eq '.zip')
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
    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $DownloadURL })
    Set-Variable -Option Constant TempPath "$TEMP_DIR\$FileName"
    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$CURRENT_DIR\$FileName" })

    New-Item -Force -ItemType Directory $TEMP_DIR | Out-Null

    Add-Log $INF "Downloading from $DownloadURL"

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        if (Test-Path $SavePath) { Add-Log $WRN "Previous download found, returning it"; Return $SavePath } else { Return }
    }

    try {
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
    Set-Variable -Option Constant MultiFileArchive ($ZipName -eq 'AAct.zip' -or $ZipName -eq 'KMSAuto_Lite.zip' -or `
            $URL -Match 'hwmonitor_' -or $URL -Match 'SDI_R' -or $URL -Match 'Victoria')

    Set-Variable -Option Constant ExtractionPath $(if ($MultiFileArchive) { $ZipPath.TrimEnd('.zip') })
    Set-Variable -Option Constant TemporaryPath $(if ($ExtractionPath) { $ExtractionPath } else { $TEMP_DIR })
    Set-Variable -Option Constant TargetPath $(if ($Execute) { $TEMP_DIR } else { $CURRENT_DIR })
    Set-Variable -Option Constant ExtractionDir $(if ($ExtractionPath) { Split-Path -Leaf $ExtractionPath })

    [String]$Executable = Switch -Wildcard ($ZipName) {
        'Office_2013-2019.zip' { 'OInstall.exe' }
        'AAct.zip' { "AAct$(if ($OS_64_BIT) {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { "KMSAuto$(if ($OS_64_BIT) {' x64'}).exe" }
        'Victoria*' { 'Victoria.exe' }
        'hwmonitor_*' { "HWMonitor_$(if ($OS_64_BIT) {'x64'} else {'x32'}).exe" }
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

Function Get-SystemInfo {
    Add-Log $INF 'Gathering system information...'

    Set-Variable -Option Constant OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version)

    Set-Variable -Option Constant -Scope Script OS_NAME $OperatingSystem.Caption
    Set-Variable -Option Constant -Scope Script OS_BUILD $OperatingSystem.Version
    Set-Variable -Option Constant -Scope Script OS_64_BIT $(if ($OperatingSystem.OSArchitecture -Like '64-*') { $True })
    Set-Variable -Option Constant -Scope Script OS_VERSION $(Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } })

    Set-Variable -Option Constant -Scope Script CURRENT_DIR $(Split-Path $MyInvocation.ScriptName)
    Set-Variable -Option Constant -Scope Script PROGRAM_FILES_86 $(if ($OS_64_BIT) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles })

    New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
    Set-Variable -Option Constant WordRegPath (Get-ItemProperty 'HKCR:\Word.Application\CurVer' -ErrorAction SilentlyContinue)
    Set-Variable -Option Constant -Scope Script OfficeVersion $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' })
    Set-Variable -Option Constant -Scope Script OfficeC2RClientExe "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
    Set-Variable -Option Constant -Scope Script OfficeInstallType $(if ($OfficeVersion) { if (Test-Path $OfficeC2RClientExe) { 'C2R' } else { 'MSI' } })

    Set-Variable -Option Constant -Scope Script DefenderExe "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    Set-Variable -Option Constant -Scope Script ChromeExe "$PROGRAM_FILES_86\Google\Chrome\Application\chrome.exe"

    Set-Variable -Option Constant LogicalDisk (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'")
    Set-Variable -Option Constant -Scope Script SystemPartition ($LogicalDisk | Select-Object @{L = 'FreeSpace'; E = { '{0:N2}' -f ($_.FreeSpace / 1GB) } }, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })

    Out-Success
}


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

    if ($SystemPartition) {
        Add-Log $INF "    Free space on system partition: $($SystemPartition.FreeSpace) GB / $($SystemPartition.Size) GB ($((Get-FreeDiskSpace).ToString('P')))"
    }

    Set-Variable -Option Constant OfficeYear $(Switch ($OfficeVersion) { 16 { '2016 / 2019' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })
    Set-Variable -Option Constant Win10Release ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId)

    Add-Log $INF '  Software'
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $(if ($OS_64_BIT) { '64-bit' } else { '32-bit' })"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$Win10Release / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
    Add-Log $INF "    PowerShell version:  $PS_VERSION.$($PSVersionTable.PSVersion.Minor)"

    Set-ButtonState
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Set-NiniteButtonState {
    $CBOX_StartNinite.Enabled = $BTN_DownloadNinite.Enabled = $CBOX_7zip.Checked -or $CBOX_VLC.Checked -or `
        $CBOX_TeamViewer.Checked -or $CBOX_Skype.Checked -or $CBOX_Chrome.Checked -or $CBOX_qBittorrent.Checked -or $CBOX_Malwarebytes.Checked
}


Function Set-NiniteQuery {
    [String[]]$Array = @()
    if ($CBOX_7zip.Checked) { $Array += $CBOX_7zip.Name }
    if ($CBOX_VLC.Checked) { $Array += $CBOX_VLC.Name }
    if ($CBOX_TeamViewer.Checked) { $Array += $CBOX_TeamViewer.Name }
    if ($CBOX_Skype.Checked) { $Array += $CBOX_Skype.Name }
    if ($CBOX_Chrome.Checked) { $Array += $CBOX_Chrome.Name }
    if ($CBOX_qBittorrent.Checked) { $Array += $CBOX_qBittorrent.Name }
    if ($CBOX_Malwarebytes.Checked) { $Array += $CBOX_Malwarebytes.Name }
    Return $Array -Join '-'
}


Function Set-NiniteFileName {
    [String[]]$Array = @()
    if ($CBOX_7zip.Checked) { $Array += $CBOX_7zip.Text }
    if ($CBOX_VLC.Checked) { $Array += $CBOX_VLC.Text }
    if ($CBOX_TeamViewer.Checked) { $Array += $CBOX_TeamViewer.Text }
    if ($CBOX_Skype.Checked) { $Array += $CBOX_Skype.Text }
    if ($CBOX_Chrome.Checked) { $Array += $CBOX_Chrome.Text }
    if ($CBOX_qBittorrent.Checked) { $Array += $CBOX_qBittorrent.Text }
    if ($CBOX_Malwarebytes.Checked) { $Array += $CBOX_Malwarebytes.Text }
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

    try { Start-Process $OfficeC2RClientExe '/update user' }
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
    Set-Variable -Option Constant ScanHealth "Start-Process -NoNewWindow 'DISM' '/Online /Cleanup-Image /StartComponentCleanup'"

    try { Start-ExternalProcess -Elevated -Title:'Checking Windows health...' @($ComponentCleanup, $ScanHealth) }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-Windows {
    Add-Log $INF 'Starting Windows repair...'

    try { Start-ExternalProcess -Elevated -Title:'Repairing Windows...' "Start-Process -NoNewWindow 'DISM' '/Online /Cleanup-Image /RestoreHealth'" }
    catch [Exception] { Add-Log $ERR "Failed to repair Windows: $($_.Exception.Message)"; Return }

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

        try { Start-ExternalProcess -Wait -Title:'Updating security signatures...' "Start-Process '$DefenderExe' '-SignatureUpdate' -NoNewWindow" }
        catch [Exception] { Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"; Return }

        Out-Success
    }

    Add-Log $INF "Performing a security scan..."

    try { Start-ExternalProcess -Title:'Security scan is running...' "Start-Process '$DefenderExe' '-Scan -ScanType 2' -NoNewWindow" }
    catch [Exception] { Add-Log $ERR "Failed to perform a security scan: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# File Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-FileCleanup {
    Set-Variable -Option Constant LogMessage 'Removing unnecessary files...'
    Add-Log $INF $LogMessage

    Set-Variable -Option Constant ContainerJava86 "${env:ProgramFiles(x86)}\Java"
    Set-Variable -Option Constant ContainerJava "$env:ProgramFiles\Java"
    Set-Variable -Option Constant ContainerOpera "$env:ProgramFiles\Opera"
    Set-Variable -Option Constant ContainerChrome "$PROGRAM_FILES_86\Google\Chrome\Application"
    Set-Variable -Option Constant ContainerChromeBeta "$PROGRAM_FILES_86\Google\Chrome Beta\Application"
    Set-Variable -Option Constant ContainerChromeDev "$PROGRAM_FILES_86\Google\Chrome Dev\Application"
    Set-Variable -Option Constant ContainerGoogleUpdate "$PROGRAM_FILES_86\Google\Update"

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
        "$PROGRAM_FILES_86\Microsoft\Skype for Desktop\locales;en-US.pak,lv.pak,ru.pak"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\locales;en-US.pak,lv.pak,ru.pak"
        "$PROGRAM_FILES_86\TeamViewer\TeamViewer_Resource*.dll;TeamViewer_Resource_en.dll,TeamViewer_Resource_ru.dll"
        "$PROGRAM_FILES_86\WinSCP\Translations;WinSCP.ru"
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
        "$env:ProgramData\Razer\GameManager\Logs\*"
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
        "$PROGRAM_FILES_86\7-Zip\7-zip.chm"
        "$PROGRAM_FILES_86\7-Zip\7-zip.dll.tmp"
        "$PROGRAM_FILES_86\7-Zip\descript.ion"
        "$PROGRAM_FILES_86\7-Zip\History.txt"
        "$PROGRAM_FILES_86\7-Zip\License.txt"
        "$PROGRAM_FILES_86\7-Zip\readme.txt"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\*.pdf"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\AcroCEF\*.txt"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\Legal\ENU\*"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\ReadMe.htm"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Resource\ENUtxt.pdf"
        "$PROGRAM_FILES_86\CCleaner\Setup"
        "$PROGRAM_FILES_86\CCleaner\Setup\*"
        "$PROGRAM_FILES_86\Dolby\Dolby DAX3\API\amd64\Microsoft.VC90.CRT\README_ENU.txt"
        "$PROGRAM_FILES_86\FileZilla FTP Client\AUTHORS"
        "$PROGRAM_FILES_86\FileZilla FTP Client\GPL.html"
        "$PROGRAM_FILES_86\FileZilla FTP Client\NEWS"
        "$PROGRAM_FILES_86\Foxit Software\Foxit Reader\notice.txt"
        "$PROGRAM_FILES_86\Git\LICENSE.txt"
        "$PROGRAM_FILES_86\Git\mingw64\doc"
        "$PROGRAM_FILES_86\Git\mingw64\doc\*"
        "$PROGRAM_FILES_86\Git\ReleaseNotes.html"
        "$PROGRAM_FILES_86\Git\tmp"
        "$PROGRAM_FILES_86\Git\tmp\*"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Application\SetupMetrics\*"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Temp"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Temp\*"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Application\SetupMetrics\*"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Temp"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Temp\*"
        "$PROGRAM_FILES_86\Google\Chrome\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome\Application\SetupMetrics\*"
        "$PROGRAM_FILES_86\Google\Chrome\Temp"
        "$PROGRAM_FILES_86\Google\Chrome\Temp\*"
        "$PROGRAM_FILES_86\Google\CrashReports"
        "$PROGRAM_FILES_86\Google\CrashReports\*"
        "$PROGRAM_FILES_86\Google\Policies"
        "$PROGRAM_FILES_86\Google\Policies\*"
        "$PROGRAM_FILES_86\Google\Update\Download"
        "$PROGRAM_FILES_86\Google\Update\Download\*"
        "$PROGRAM_FILES_86\Google\Update\Install"
        "$PROGRAM_FILES_86\Google\Update\Install\*"
        "$PROGRAM_FILES_86\Google\Update\Offline"
        "$PROGRAM_FILES_86\Google\Update\Offline\*"
        "$PROGRAM_FILES_86\Microsoft\Skype for Desktop\*.html"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\LICENSE.rtf"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\licenses"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\licenses\*"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$PROGRAM_FILES_86\Mozilla Firefox\install.log"
        "$PROGRAM_FILES_86\Mozilla Maintenance Service\logs"
        "$PROGRAM_FILES_86\Mozilla Maintenance Service\logs\*"
        "$PROGRAM_FILES_86\Notepad++\change.log"
        "$PROGRAM_FILES_86\Notepad++\readme.txt"
        "$PROGRAM_FILES_86\Notepad++\updater\LICENSE"
        "$PROGRAM_FILES_86\Notepad++\updater\README.md"
        "$PROGRAM_FILES_86\NVIDIA Corporation\Ansel\Tools\tools_licenses.txt"
        "$PROGRAM_FILES_86\NVIDIA Corporation\license.txt"
        "$PROGRAM_FILES_86\NVIDIA Corporation\NVSMI\nvidia-smi.1.pdf"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\doc"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\doc\*"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack\ExtPack-license.*"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\License_en_US.rtf"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\VirtualBox.chm"
        "$PROGRAM_FILES_86\paint.net\License.txt"
        "$PROGRAM_FILES_86\paint.net\Staging"
        "$PROGRAM_FILES_86\paint.net\Staging\*"
        "$PROGRAM_FILES_86\PuTTY\LICENCE"
        "$PROGRAM_FILES_86\PuTTY\putty.chm"
        "$PROGRAM_FILES_86\PuTTY\README.txt"
        "$PROGRAM_FILES_86\PuTTY\website.url"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\Licenses"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\Licenses\*"
        "$PROGRAM_FILES_86\Steam\dumps"
        "$PROGRAM_FILES_86\Steam\dumps\*"
        "$PROGRAM_FILES_86\Steam\logs"
        "$PROGRAM_FILES_86\Steam\logs\*"
        "$PROGRAM_FILES_86\TeamViewer\*.log"
        "$PROGRAM_FILES_86\TeamViewer\*.txt"
        "$PROGRAM_FILES_86\TeamViewer\TeamViewer_Note.exe"
        "$PROGRAM_FILES_86\VideoLAN\VLC\AUTHORS.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\COPYING.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\Documentation.url"
        "$PROGRAM_FILES_86\VideoLAN\VLC\New_Skins.url"
        "$PROGRAM_FILES_86\VideoLAN\VLC\NEWS.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\README.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\THANKS.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\VideoLAN Website.url"
        "$PROGRAM_FILES_86\WinRAR\Descript.ion"
        "$PROGRAM_FILES_86\WinRAR\License.txt"
        "$PROGRAM_FILES_86\WinRAR\Order.htm"
        "$PROGRAM_FILES_86\WinRAR\Rar.txt"
        "$PROGRAM_FILES_86\WinRAR\ReadMe.txt"
        "$PROGRAM_FILES_86\WinRAR\WhatsNew.txt"
        "$PROGRAM_FILES_86\WinRAR\WinRAR.chm"
        "$PROGRAM_FILES_86\WinSCP\license.txt"
        "$PROGRAM_FILES_86\WinSCP\PuTTY\LICENCE"
        "$PROGRAM_FILES_86\WinSCP\PuTTY\putty.chm"
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
        "$env:ProgramFiles\Foxit Software\Foxit Reader\notice.txt"
        "$env:ProgramFiles\Git\LICENSE.txt"
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
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSE.rtf"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses\*"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$env:ProgramFiles\Mozilla Firefox\install.log"
        "$env:ProgramFiles\Mozilla Maintenance Service\logs"
        "$env:ProgramFiles\Mozilla Maintenance Service\logs\*"
        "$env:ProgramFiles\NVIDIA Corporation\license.txt"
        "$env:ProgramFiles\NVIDIA Corporation\NVSMI\nvidia-smi.1.pdf"
        "$env:ProgramFiles\Oracle\VirtualBox\doc"
        "$env:ProgramFiles\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack\ExtPack-license.*"
        "$env:ProgramFiles\Oracle\VirtualBox\License_en_US.rtf"
        "$env:ProgramFiles\Oracle\VirtualBox\VirtualBox.chm"
        "$env:ProgramFiles\PuTTY\LICENCE"
        "$env:ProgramFiles\PuTTY\putty.chm"
        "$env:ProgramFiles\PuTTY\README.txt"
        "$env:ProgramFiles\PuTTY\website.url"
        "$env:ProgramFiles\Razer\Razer Services\Razer Central\Licenses"
        "$env:ProgramFiles\Razer\Razer Services\Razer Central\Licenses\*"
        "$env:ProgramFiles\Steam\dumps"
        "$env:ProgramFiles\Steam\dumps\*"
        "$env:ProgramFiles\Steam\logs"
        "$env:ProgramFiles\Steam\logs\*"
        "$env:ProgramFiles\TeamViewer\*.log"
        "$env:ProgramFiles\TeamViewer\*.txt"
        "$env:ProgramFiles\TeamViewer\TeamViewer_Note.exe"
        "$env:ProgramFiles\VideoLAN\VLC\AUTHORS.txt"
        "$env:ProgramFiles\VideoLAN\VLC\COPYING.txt"
        "$env:ProgramFiles\VideoLAN\VLC\Documentation.url"
        "$env:ProgramFiles\VideoLAN\VLC\New_Skins.url"
        "$env:ProgramFiles\VideoLAN\VLC\NEWS.txt"
        "$env:ProgramFiles\VideoLAN\VLC\README.txt"
        "$env:ProgramFiles\VideoLAN\VLC\THANKS.txt"
        "$env:ProgramFiles\VideoLAN\VLC\VideoLAN Website.url"
        "$env:ProgramFiles\WinRAR\Descript.ion"
        "$env:ProgramFiles\WinRAR\License.txt"
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
        "$env:AppData\Synapse3"
        "$env:AppData\Synapse3\*"
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
    [String]$PreferredDnsServer = if ($CBOX_CloudFlareFamilyFriendly.Checked) { '1.1.1.3' } else { if ($CBOX_CloudFlareAntiMalware.Checked) { '1.1.1.2' } else { '1.1.1.1' } };
    [String]$AlternateDnsServer = if ($CBOX_CloudFlareFamilyFriendly.Checked) { '1.0.0.3' } else { if ($CBOX_CloudFlareAntiMalware.Checked) { '1.0.0.2' } else { '1.0.0.1' } };

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
